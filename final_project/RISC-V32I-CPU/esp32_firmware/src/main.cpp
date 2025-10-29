// Main ESP32 Firmware for RISC-V CPU Web IDE
// Bridges FPGA and Web Interface

#include <Arduino.h>
#include <WiFi.h>
#include <FS.h>
#include <SPIFFS.h>
#include "config.h"
#include "fpga_interface.h"
#include "web_server.h"

// Global objects
FPGAInterface fpga;
IDEWebServer *webServer = nullptr;

// Function prototypes
void setupWiFi();
void setupFileSystem();
void printSystemInfo();

void setup() {
    // Initialize serial for debugging
    Serial.begin(DEBUG_BAUD_RATE);
    delay(1000);
    
    Serial.println("\n\n========================================");
    Serial.println("RISC-V CPU Web IDE - ESP32 Firmware");
    Serial.println("========================================\n");
    
    // Initialize file system
    setupFileSystem();
    
    // Initialize WiFi
    setupWiFi();
    
    // Initialize FPGA interface
    Serial.println("[INIT] Initializing FPGA interface...");
    if (fpga.begin()) {
        Serial.println("[INIT] FPGA interface ready");
        
        // Reset CPU on startup
        fpga.cpuReset();
        delay(100);
    } else {
        Serial.println("[ERROR] Failed to initialize FPGA interface");
    }
    
    // Initialize web server
    Serial.println("[INIT] Starting web server...");
    webServer = new IDEWebServer(&fpga);
    if (webServer->begin()) {
        Serial.println("[INIT] Web server ready");
    } else {
        Serial.println("[ERROR] Failed to start web server");
    }
    
    // Print system information
    printSystemInfo();
    
    Serial.println("\n========================================");
    Serial.println("System Ready!");
    Serial.println("========================================\n");
}

void loop() {
    // Web server handles clients automatically via AsyncWebServer
    // Just keep alive and handle any periodic tasks
    
    static unsigned long lastStatusPrint = 0;
    if (millis() - lastStatusPrint > 30000) {  // Print status every 30 seconds
        lastStatusPrint = millis();
        
        Serial.println("\n[STATUS] System operational");
        Serial.println("[STATUS] Access Point: " + String(WiFi.getMode() == WIFI_AP ? "Active" : "Inactive"));
        Serial.println("[STATUS] IP: " + WiFi.softAPIP().toString());
        Serial.println("[STATUS] Connected Clients: " + String(WiFi.softAPgetStationNum()));
        Serial.println("[STATUS] FPGA: " + String(fpga.isConnected() ? "Connected" : "Disconnected"));
        
        // Print memory usage
        Serial.println("[STATUS] Free Heap: " + String(ESP.getFreeHeap()) + " bytes");
    }
    
    // Check AP status (less critical than STA mode)
    if (WiFi.getMode() != WIFI_AP && WiFi.getMode() != WIFI_AP_STA) {
        Serial.println("[WARN] Access Point stopped, restarting...");
        setupWiFi();
    }
    
    delay(100);
}

void setupWiFi() {
    Serial.println("[WIFI] Starting Access Point Mode...");
    Serial.println("[WIFI] Network Name: " + String(AP_SSID));
    
    // Configure Access Point
    WiFi.mode(WIFI_AP);
    
    // Set up the soft AP
    bool apStarted = WiFi.softAP(AP_SSID, AP_PASSWORD, AP_CHANNEL, AP_HIDDEN, AP_MAX_CONNECTIONS);
    
    if (apStarted) {
        delay(100); // Give AP time to start
        
        IPAddress IP = WiFi.softAPIP();
        Serial.println("\n[WIFI] ✓ Access Point started successfully!");
        Serial.println("[WIFI] SSID: " + String(AP_SSID));
        Serial.println("[WIFI] Password: " + String(AP_PASSWORD));
        Serial.println("[WIFI] IP Address: " + IP.toString());
        Serial.println("[WIFI] Channel: " + String(AP_CHANNEL));
        Serial.println("[WIFI] Max Connections: " + String(AP_MAX_CONNECTIONS));
        Serial.println("\n[WIFI] Connect to WiFi network '" + String(AP_SSID) + "'");
        Serial.println("[WIFI] Then open browser: http://" + IP.toString());
    } else {
        Serial.println("\n[ERROR] Failed to start Access Point!");
        Serial.println("[ERROR] Please check AP configuration in config.h");
    }
}

void setupFileSystem() {
    Serial.println("[FS] Initializing file system...");
    
    if (!SPIFFS.begin(true)) {
        Serial.println("[ERROR] Failed to mount file system");
        Serial.println("[INFO] Web interface files may not be available");
    } else {
        Serial.println("[FS] File system mounted successfully");
        
        // List files
        File root = SPIFFS.open("/");
        File file = root.openNextFile();
        Serial.println("[FS] Files in filesystem:");
        while (file) {
            Serial.println("  - " + String(file.name()) + " (" + String(file.size()) + " bytes)");
            file = root.openNextFile();
        }
    }
}

void printSystemInfo() {
    Serial.println("\n========================================");
    Serial.println("System Information");
    Serial.println("========================================");
    Serial.println("Chip Model: " + String(ESP.getChipModel()));
    Serial.println("Chip Revision: " + String(ESP.getChipRevision()));
    Serial.println("CPU Frequency: " + String(ESP.getCpuFreqMHz()) + " MHz");
    Serial.println("Flash Size: " + String(ESP.getFlashChipSize() / 1024) + " KB");
    Serial.println("Free Heap: " + String(ESP.getFreeHeap()) + " bytes");
    Serial.println("========================================");
    Serial.println("\n🌐 How to Connect:");
    Serial.println("  1. Connect to WiFi: " + String(AP_SSID));
    if (strlen(AP_PASSWORD) > 0) {
        Serial.println("  2. Password: " + String(AP_PASSWORD));
    }
    Serial.println("  3. Open Browser: http://" + WiFi.softAPIP().toString());
    Serial.println("\n📡 Access Points:");
    Serial.println("  Web IDE: http://" + WiFi.softAPIP().toString());
    Serial.println("  API Endpoint: http://" + WiFi.softAPIP().toString() + "/api/");
    Serial.println("========================================\n");
}

