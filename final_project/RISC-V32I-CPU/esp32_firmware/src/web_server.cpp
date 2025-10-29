// Web Server Implementation

#include "web_server.h"
#include <FS.h>
#include <SPIFFS.h>

IDEWebServer::IDEWebServer(FPGAInterface *fpga) {
    fpgaInterface = fpga;
    server = nullptr;
    running = false;
}

bool IDEWebServer::begin() {
    server = new AsyncWebServer(WEB_SERVER_PORT);
    
    // Setup routes
    setupRoutes();
    
    // Enable CORS for all responses
    DefaultHeaders::Instance().addHeader("Access-Control-Allow-Origin", "*");
    DefaultHeaders::Instance().addHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    DefaultHeaders::Instance().addHeader("Access-Control-Allow-Headers", "Content-Type");
    
    // Start server
    server->begin();
    running = true;
    
    Serial.println("[WEB] Server started on port " + String(WEB_SERVER_PORT));
    Serial.println("[WEB] Access IDE at: http://" + WiFi.localIP().toString());
    
    return true;
}

void IDEWebServer::setupRoutes() {
    // ===== CPU Control API ===== (Define API routes BEFORE static files!)
    // API routes must be registered before serveStatic to take priority
    server->on("/api/cpu/start", HTTP_POST, [this](AsyncWebServerRequest *request) {
        this->handleCPUStart(request);
    });
    
    server->on("/api/cpu/stop", HTTP_POST, [this](AsyncWebServerRequest *request) {
        this->handleCPUStop(request);
    });
    
    server->on("/api/cpu/reset", HTTP_POST, [this](AsyncWebServerRequest *request) {
        this->handleCPUReset(request);
    });
    
    server->on("/api/cpu/step", HTTP_POST, [this](AsyncWebServerRequest *request) {
        this->handleCPUStep(request);
    });
    
    server->on("/api/cpu/status", HTTP_GET, [this](AsyncWebServerRequest *request) {
        this->handleCPUStatus(request);
    });
    
    // ===== Register API =====
    server->on("/api/registers", HTTP_GET, [this](AsyncWebServerRequest *request) {
        this->handleGetRegisters(request);
    });
    
    server->on("^\\/api\\/registers\\/([0-9]+)$", HTTP_GET, [this](AsyncWebServerRequest *request) {
        this->handleGetRegister(request);
    });
    
    // ===== Memory API =====
    server->on("/api/memory/instruction", HTTP_GET, [this](AsyncWebServerRequest *request) {
        this->handleGetMemory(request);
    });
    
    server->on("/api/memory/data", HTTP_GET, [this](AsyncWebServerRequest *request) {
        this->handleGetDataMemory(request);
    });
    
    server->on("/api/pc", HTTP_GET, [this](AsyncWebServerRequest *request) {
        this->handleGetPC(request);
    });
    
    server->on("/api/instruction", HTTP_GET, [this](AsyncWebServerRequest *request) {
        this->handleGetInstruction(request);
    });
    
    // ===== Program Upload API =====
    server->on("/api/program/upload", HTTP_POST,
        [](AsyncWebServerRequest *request) {
            // Don't send response here - handleProgramUpload will send it after processing body
        },
        NULL,
        [this](AsyncWebServerRequest *request, uint8_t *data, size_t len, size_t index, size_t total) {
            this->handleProgramUpload(request, data, len, index, total);
        }
    );
    
    // Serve static files LAST (so API routes take priority)
    server->serveStatic("/", SPIFFS, "/").setDefaultFile("index.html");
    
    // 404 Handler
    server->onNotFound([](AsyncWebServerRequest *request) {
        request->send(404, "application/json", "{\"error\":\"Not found\"}");
    });
}

void IDEWebServer::handleClient() {
    // AsyncWebServer handles clients automatically
}

bool IDEWebServer::isRunning() {
    return running;
}

String IDEWebServer::getIPAddress() {
    return WiFi.localIP().toString();
}

// ===== API Handlers =====

void IDEWebServer::handleCPUStart(AsyncWebServerRequest *request) {
    if (fpgaInterface->cpuStart()) {
        StaticJsonDocument<200> doc;
        doc["success"] = true;
        doc["message"] = "CPU started";
        
        String response;
        serializeJson(doc, response);
        request->send(200, "application/json", response);
    } else {
        sendErrorResponse(request, 500, fpgaInterface->getLastError());
    }
}

void IDEWebServer::handleCPUStop(AsyncWebServerRequest *request) {
    if (fpgaInterface->cpuStop()) {
        StaticJsonDocument<200> doc;
        doc["success"] = true;
        doc["message"] = "CPU stopped";
        
        String response;
        serializeJson(doc, response);
        request->send(200, "application/json", response);
    } else {
        sendErrorResponse(request, 500, fpgaInterface->getLastError());
    }
}

void IDEWebServer::handleCPUReset(AsyncWebServerRequest *request) {
    if (fpgaInterface->cpuReset()) {
        StaticJsonDocument<200> doc;
        doc["success"] = true;
        doc["message"] = "CPU reset";
        
        String response;
        serializeJson(doc, response);
        request->send(200, "application/json", response);
    } else {
        sendErrorResponse(request, 500, fpgaInterface->getLastError());
    }
}

void IDEWebServer::handleCPUStep(AsyncWebServerRequest *request) {
    if (fpgaInterface->cpuStep()) {
        StaticJsonDocument<200> doc;
        doc["success"] = true;
        doc["message"] = "CPU stepped";
        
        String response;
        serializeJson(doc, response);
        request->send(200, "application/json", response);
    } else {
        sendErrorResponse(request, 500, fpgaInterface->getLastError());
    }
}

void IDEWebServer::handleCPUStatus(AsyncWebServerRequest *request) {
    uint8_t status;
    uint32_t pc, instr;
    
    if (fpgaInterface->getStatus(status) && 
        fpgaInterface->readPC(pc) && 
        fpgaInterface->readInstruction(instr)) {
        
        StaticJsonDocument<300> doc;
        doc["success"] = true;
        doc["status"] = status;
        doc["running"] = (status & 0x01) ? true : false;
        doc["pc"] = pc;
        doc["current_instruction"] = instr;
        
        String response;
        serializeJson(doc, response);
        request->send(200, "application/json", response);
    } else {
        sendErrorResponse(request, 500, fpgaInterface->getLastError());
    }
}

void IDEWebServer::handleGetRegisters(AsyncWebServerRequest *request) {
    uint32_t registers[NUM_REGISTERS];
    
    if (fpgaInterface->readAllRegisters(registers)) {
        DynamicJsonDocument doc(2048);
        doc["success"] = true;
        JsonArray regArray = doc.createNestedArray("registers");
        
        for (int i = 0; i < NUM_REGISTERS; i++) {
            regArray.add(registers[i]);
        }
        
        String response;
        serializeJson(doc, response);
        request->send(200, "application/json", response);
    } else {
        sendErrorResponse(request, 500, fpgaInterface->getLastError());
    }
}

void IDEWebServer::handleGetRegister(AsyncWebServerRequest *request) {
    String regNumStr = request->pathArg(0);
    int regNum = regNumStr.toInt();
    
    if (regNum < 0 || regNum >= NUM_REGISTERS) {
        sendErrorResponse(request, 400, "Invalid register number");
        return;
    }
    
    uint32_t value;
    if (fpgaInterface->readRegister(regNum, value)) {
        StaticJsonDocument<200> doc;
        doc["success"] = true;
        doc["register"] = regNum;
        doc["value"] = value;
        
        String response;
        serializeJson(doc, response);
        request->send(200, "application/json", response);
    } else {
        sendErrorResponse(request, 500, fpgaInterface->getLastError());
    }
}

void IDEWebServer::handleGetMemory(AsyncWebServerRequest *request) {
    uint32_t memory[IMEM_SIZE];
    
    for (int i = 0; i < IMEM_SIZE; i++) {
        if (!fpgaInterface->readInstructionMemory(i, memory[i])) {
            sendErrorResponse(request, 500, fpgaInterface->getLastError());
            return;
        }
    }
    
    DynamicJsonDocument doc(4096);
    doc["success"] = true;
    JsonArray memArray = doc.createNestedArray("memory");
    
    for (int i = 0; i < IMEM_SIZE; i++) {
        memArray.add(memory[i]);
    }
    
    String response;
    serializeJson(doc, response);
    request->send(200, "application/json", response);
}

void IDEWebServer::handleGetDataMemory(AsyncWebServerRequest *request) {
    uint32_t memory[DMEM_SIZE];
    
    if (fpgaInterface->readAllDataMemory(memory, DMEM_SIZE)) {
        DynamicJsonDocument doc(4096);
        doc["success"] = true;
        JsonArray memArray = doc.createNestedArray("memory");
        
        for (int i = 0; i < DMEM_SIZE; i++) {
            memArray.add(memory[i]);
        }
        
        String response;
        serializeJson(doc, response);
        request->send(200, "application/json", response);
    } else {
        sendErrorResponse(request, 500, fpgaInterface->getLastError());
    }
}

void IDEWebServer::handleGetPC(AsyncWebServerRequest *request) {
    uint32_t pc;
    
    if (fpgaInterface->readPC(pc)) {
        StaticJsonDocument<200> doc;
        doc["success"] = true;
        doc["pc"] = pc;
        
        String response;
        serializeJson(doc, response);
        request->send(200, "application/json", response);
    } else {
        sendErrorResponse(request, 500, fpgaInterface->getLastError());
    }
}

void IDEWebServer::handleGetInstruction(AsyncWebServerRequest *request) {
    uint32_t instr;
    
    if (fpgaInterface->readInstruction(instr)) {
        StaticJsonDocument<200> doc;
        doc["success"] = true;
        doc["instruction"] = instr;
        
        String response;
        serializeJson(doc, response);
        request->send(200, "application/json", response);
    } else {
        sendErrorResponse(request, 500, fpgaInterface->getLastError());
    }
}

void IDEWebServer::handleProgramUpload(AsyncWebServerRequest *request, uint8_t *data, size_t len, size_t index, size_t total) {
    static uint32_t program[IMEM_SIZE];
    static size_t receivedBytes = 0;
    
    // First chunk
    if (index == 0) {
        receivedBytes = 0;
        memset(program, 0, sizeof(program));
        Serial.println("[WEB] Starting program upload, total size: " + String(total));
    }
    
    // Copy data
    memcpy((uint8_t*)program + index, data, len);
    receivedBytes += len;
    
    // Last chunk
    if (index + len == total) {
        uint8_t numInstructions = total / 4;
        if (numInstructions > IMEM_SIZE) {
            numInstructions = IMEM_SIZE;
        }
        
        Serial.println("[WEB] Upload complete, uploading " + String(numInstructions) + " instructions to FPGA");
        
        if (fpgaInterface->uploadProgram(program, numInstructions)) {
            StaticJsonDocument<200> doc;
            doc["success"] = true;
            doc["message"] = "Program uploaded successfully";
            doc["instructions"] = numInstructions;
            
            String response;
            serializeJson(doc, response);
            request->send(200, "application/json", response);
        } else {
            sendErrorResponse(request, 500, fpgaInterface->getLastError());
        }
    }
}

// ===== Utility Methods =====

void IDEWebServer::sendErrorResponse(AsyncWebServerRequest *request, int code, const String &message) {
    StaticJsonDocument<200> doc;
    doc["success"] = false;
    doc["error"] = message;
    
    String response;
    serializeJson(doc, response);
    request->send(code, "application/json", response);
}

