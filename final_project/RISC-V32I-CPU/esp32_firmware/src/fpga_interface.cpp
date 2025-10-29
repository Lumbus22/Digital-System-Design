// FPGA Interface Implementation

#include "fpga_interface.h"

FPGAInterface::FPGAInterface() {
    fpgaSerial = nullptr;
    lastError = "";
}

bool FPGAInterface::begin() {
    // Initialize UART for FPGA communication
    fpgaSerial = new HardwareSerial(FPGA_UART_NUM);
    fpgaSerial->begin(FPGA_UART_BAUD, SERIAL_8N1, FPGA_UART_RX_PIN, FPGA_UART_TX_PIN);
    
    // Wait for serial to stabilize
    delay(100);
    clearSerialBuffer();
    
    Serial.println("[FPGA] Interface initialized");
    return true;
}

bool FPGAInterface::cpuStart() {
    if (!sendCommand(CMD_CPU_START)) {
        lastError = "Failed to send CPU_START command";
        return false;
    }
    uint32_t dummy;
    bool result = receiveResponse(dummy);
    if (result) {
        Serial.println("[FPGA] CPU started");
    }
    return result;
}

bool FPGAInterface::cpuStop() {
    if (!sendCommand(CMD_CPU_STOP)) {
        lastError = "Failed to send CPU_STOP command";
        return false;
    }
    uint32_t dummy;
    bool result = receiveResponse(dummy);
    if (result) {
        Serial.println("[FPGA] CPU stopped");
    }
    return result;
}

bool FPGAInterface::cpuReset() {
    if (!sendCommand(CMD_CPU_RESET)) {
        lastError = "Failed to send CPU_RESET command";
        return false;
    }
    uint32_t dummy;
    bool result = receiveResponse(dummy);
    if (result) {
        Serial.println("[FPGA] CPU reset");
    }
    return result;
}

bool FPGAInterface::cpuStep() {
    if (!sendCommand(CMD_CPU_STEP)) {
        lastError = "Failed to send CPU_STEP command";
        return false;
    }
    uint32_t dummy;
    return receiveResponse(dummy);
}

bool FPGAInterface::readPC(uint32_t &pc) {
    if (!sendCommand(CMD_READ_PC)) {
        lastError = "Failed to send READ_PC command";
        return false;
    }
    return receiveResponse(pc);
}

bool FPGAInterface::readInstruction(uint32_t &instr) {
    if (!sendCommand(CMD_READ_INSTR)) {
        lastError = "Failed to send READ_INSTR command";
        return false;
    }
    return receiveResponse(instr);
}

bool FPGAInterface::readRegister(uint8_t reg_num, uint32_t &value) {
    if (reg_num >= NUM_REGISTERS) {
        lastError = "Invalid register number";
        return false;
    }
    if (!sendCommand(CMD_READ_REG, reg_num)) {
        lastError = "Failed to send READ_REG command";
        return false;
    }
    return receiveResponse(value);
}

bool FPGAInterface::readInstructionMemory(uint8_t addr, uint32_t &value) {
    if (addr >= IMEM_SIZE) {
        lastError = "Invalid instruction memory address";
        return false;
    }
    if (!sendCommand(CMD_READ_IMEM, addr)) {
        lastError = "Failed to send READ_IMEM command";
        return false;
    }
    return receiveResponse(value);
}

bool FPGAInterface::readDataMemory(uint8_t addr, uint32_t &value) {
    if (addr >= DMEM_SIZE) {
        lastError = "Invalid data memory address";
        return false;
    }
    if (!sendCommand(CMD_READ_DMEM, addr)) {
        lastError = "Failed to send READ_DMEM command";
        return false;
    }
    return receiveResponse(value);
}

bool FPGAInterface::getStatus(uint8_t &status) {
    if (!sendCommand(CMD_GET_STATUS)) {
        lastError = "Failed to send GET_STATUS command";
        return false;
    }
    uint32_t statusWord;
    if (!receiveResponse(statusWord)) {
        return false;
    }
    status = statusWord & 0xFF;
    return true;
}

bool FPGAInterface::writeInstructionMemory(uint8_t addr, uint32_t value) {
    if (addr >= IMEM_SIZE) {
        lastError = "Invalid instruction memory address";
        return false;
    }
    if (!sendCommand(CMD_WRITE_IMEM, addr, value)) {
        lastError = "Failed to send WRITE_IMEM command";
        return false;
    }
    uint32_t dummy;
    return receiveResponse(dummy);
}

bool FPGAInterface::uploadProgram(uint32_t *program, uint8_t length) {
    if (length > IMEM_SIZE) {
        lastError = "Program too large";
        return false;
    }
    
    // Stop CPU before uploading
    if (!cpuStop()) {
        return false;
    }
    
    // Upload each instruction
    for (uint8_t i = 0; i < length; i++) {
        if (!writeInstructionMemory(i, program[i])) {
            lastError = String("Failed to write instruction at address ") + String(i);
            return false;
        }
        delay(5);  // Small delay between writes
    }
    
    // Fill remaining with NOPs
    for (uint8_t i = length; i < IMEM_SIZE; i++) {
        if (!writeInstructionMemory(i, 0x00000013)) {  // NOP = addi x0, x0, 0
            return false;
        }
        delay(5);
    }
    
    Serial.println("[FPGA] Program uploaded successfully");
    return true;
}

bool FPGAInterface::readAllRegisters(uint32_t *registers) {
    for (uint8_t i = 0; i < NUM_REGISTERS; i++) {
        if (!readRegister(i, registers[i])) {
            lastError = String("Failed to read register ") + String(i);
            return false;
        }
    }
    return true;
}

bool FPGAInterface::readAllDataMemory(uint32_t *memory, uint8_t length) {
    if (length > DMEM_SIZE) {
        length = DMEM_SIZE;
    }
    for (uint8_t i = 0; i < length; i++) {
        if (!readDataMemory(i, memory[i])) {
            lastError = String("Failed to read memory at ") + String(i);
            return false;
        }
    }
    return true;
}

bool FPGAInterface::isConnected() {
    // Try to read status as a connectivity check
    uint8_t status;
    return getStatus(status);
}

String FPGAInterface::getLastError() {
    return lastError;
}

// ===== Private Methods =====

bool FPGAInterface::sendCommand(uint8_t cmd) {
    clearSerialBuffer();
    fpgaSerial->write(cmd);
    fpgaSerial->flush();
    return true;
}

bool FPGAInterface::sendCommand(uint8_t cmd, uint8_t addr) {
    clearSerialBuffer();
    fpgaSerial->write(cmd);
    fpgaSerial->write(addr);
    fpgaSerial->flush();
    return true;
}

bool FPGAInterface::sendCommand(uint8_t cmd, uint8_t addr, uint32_t data) {
    clearSerialBuffer();
    fpgaSerial->write(cmd);
    fpgaSerial->write(addr);
    // Send data little-endian
    fpgaSerial->write((data >> 0) & 0xFF);
    fpgaSerial->write((data >> 8) & 0xFF);
    fpgaSerial->write((data >> 16) & 0xFF);
    fpgaSerial->write((data >> 24) & 0xFF);
    fpgaSerial->flush();
    return true;
}

bool FPGAInterface::receiveResponse(uint32_t &data) {
    // Wait for response byte
    if (!waitForResponse(RESP_OK, FPGA_UART_TIMEOUT)) {
        lastError = "Did not receive OK response";
        return false;
    }
    
    // Read 4 bytes of data (little-endian)
    uint8_t bytes[4];
    unsigned long startTime = millis();
    for (int i = 0; i < 4; i++) {
        while (!fpgaSerial->available()) {
            if (millis() - startTime > FPGA_UART_TIMEOUT) {
                lastError = String("Timeout waiting for data byte ") + String(i);
                return false;
            }
            delay(1);
        }
        bytes[i] = fpgaSerial->read();
    }
    
    // Reconstruct 32-bit value
    data = (uint32_t)bytes[0] |
           ((uint32_t)bytes[1] << 8) |
           ((uint32_t)bytes[2] << 16) |
           ((uint32_t)bytes[3] << 24);
    
    return true;
}

bool FPGAInterface::waitForResponse(uint8_t expected, uint32_t timeout_ms) {
    unsigned long startTime = millis();
    while (millis() - startTime < timeout_ms) {
        if (fpgaSerial->available()) {
            uint8_t response = fpgaSerial->read();
            if (response == expected) {
                return true;
            }
            else if (response == RESP_ERROR) {
                lastError = "FPGA returned error response";
                Serial.println("[FPGA] ✗ Error response from FPGA");
                return false;
            }
            Serial.printf("[FPGA] ⚠ Unexpected response: 0x%02X (expected 0x%02X)\n", response, expected);
        }
        delay(1);
    }
    lastError = "Timeout waiting for response";
    Serial.println("[FPGA] ✗ TIMEOUT - No response");
    return false;
}

void FPGAInterface::clearSerialBuffer() {
    while (fpgaSerial->available()) {
        fpgaSerial->read();
    }
}

