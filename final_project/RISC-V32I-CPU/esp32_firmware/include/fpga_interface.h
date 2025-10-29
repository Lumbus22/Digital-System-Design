// FPGA Interface - Handles communication with FPGA via UART

#ifndef FPGA_INTERFACE_H
#define FPGA_INTERFACE_H

#include <Arduino.h>
#include "config.h"

class FPGAInterface {
public:
    FPGAInterface();
    
    // Initialize UART communication
    bool begin();
    
    // CPU Control Commands
    bool cpuStart();
    bool cpuStop();
    bool cpuReset();
    bool cpuStep();
    
    // Read Operations
    bool readPC(uint32_t &pc);
    bool readInstruction(uint32_t &instr);
    bool readRegister(uint8_t reg_num, uint32_t &value);
    bool readInstructionMemory(uint8_t addr, uint32_t &value);
    bool readDataMemory(uint8_t addr, uint32_t &value);
    bool getStatus(uint8_t &status);
    
    // Write Operations
    bool writeInstructionMemory(uint8_t addr, uint32_t value);
    
    // Bulk Operations
    bool uploadProgram(uint32_t *program, uint8_t length);
    bool readAllRegisters(uint32_t *registers);
    bool readAllDataMemory(uint32_t *memory, uint8_t length);
    
    // Status
    bool isConnected();
    String getLastError();
    
private:
    HardwareSerial *fpgaSerial;
    String lastError;
    
    // Low-level communication
    bool sendCommand(uint8_t cmd);
    bool sendCommand(uint8_t cmd, uint8_t addr);
    bool sendCommand(uint8_t cmd, uint8_t addr, uint32_t data);
    bool receiveResponse(uint32_t &data);
    bool waitForResponse(uint8_t expected, uint32_t timeout_ms);
    
    // Utility
    void clearSerialBuffer();
};

#endif // FPGA_INTERFACE_H

