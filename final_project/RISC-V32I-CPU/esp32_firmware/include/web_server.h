// Web Server - Handles HTTP requests and serves IDE interface

#ifndef WEB_SERVER_H
#define WEB_SERVER_H

#include <Arduino.h>
#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <AsyncTCP.h>
#include <ArduinoJson.h>
#include "fpga_interface.h"
#include "config.h"

class IDEWebServer {
public:
    IDEWebServer(FPGAInterface *fpga);
    
    // Initialize web server
    bool begin();
    
    // Handle client connections
    void handleClient();
    
    // Get server status
    bool isRunning();
    String getIPAddress();
    
private:
    AsyncWebServer *server;
    FPGAInterface *fpgaInterface;
    bool running;
    
    // Setup routes
    void setupRoutes();
    
    // API Handlers - CPU Control
    void handleCPUStart(AsyncWebServerRequest *request);
    void handleCPUStop(AsyncWebServerRequest *request);
    void handleCPUReset(AsyncWebServerRequest *request);
    void handleCPUStep(AsyncWebServerRequest *request);
    void handleCPUStatus(AsyncWebServerRequest *request);
    
    // API Handlers - Register Operations
    void handleGetRegisters(AsyncWebServerRequest *request);
    void handleGetRegister(AsyncWebServerRequest *request);
    
    // API Handlers - Memory Operations
    void handleGetMemory(AsyncWebServerRequest *request);
    void handleGetDataMemory(AsyncWebServerRequest *request);
    void handleGetPC(AsyncWebServerRequest *request);
    void handleGetInstruction(AsyncWebServerRequest *request);
    
    // API Handlers - Program Upload
    void handleProgramUpload(AsyncWebServerRequest *request, uint8_t *data, size_t len, size_t index, size_t total);
    
    // Utility
    void sendJsonResponse(AsyncWebServerRequest *request, int code, const String &message, const JsonDocument &data);
    void sendErrorResponse(AsyncWebServerRequest *request, int code, const String &message);
};

#endif // WEB_SERVER_H

