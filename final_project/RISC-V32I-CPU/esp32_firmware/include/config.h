// Configuration File for ESP32 RISC-V IDE Firmware

#ifndef CONFIG_H
#define CONFIG_H

// ===== WiFi Configuration =====
// Access Point Mode - ESP32 creates its own WiFi network
#define AP_SSID "RISC-V-CPU-IDE"           // Network name (SSID)
#define AP_PASSWORD "riscv32i"              // Password (min 8 chars, use "" for open network)
#define AP_CHANNEL 6                        // WiFi channel (1-13)
#define AP_MAX_CONNECTIONS 4                // Max simultaneous connections
#define AP_HIDDEN false                     // false = visible network

// Station Mode (Optional - for connecting to existing network)
// Uncomment these and change WiFi.mode() in main.cpp to use STA mode
// #define WIFI_SSID "YOUR_WIFI_SSID"
// #define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"
// #define WIFI_HOSTNAME "riscv-cpu-ide"

// ===== UART Configuration (FPGA Communication) =====
#define FPGA_UART_NUM 2                    // Use UART2 for FPGA
#define FPGA_UART_TX_PIN 17                // ESP32 TX -> FPGA RX
#define FPGA_UART_RX_PIN 16                // ESP32 RX <- FPGA TX
#define FPGA_UART_BAUD 115200
#define FPGA_UART_TIMEOUT 1000             // Milliseconds

// ===== Web Server Configuration =====
#define WEB_SERVER_PORT 80
#define WEBSOCKET_PORT 8080

// ===== FPGA Command Protocol =====
#define CMD_NOP              0x00
#define CMD_CPU_START        0x01
#define CMD_CPU_STOP         0x02
#define CMD_CPU_RESET        0x03
#define CMD_CPU_STEP         0x04
#define CMD_READ_PC          0x10
#define CMD_READ_INSTR       0x11
#define CMD_READ_REG         0x20
#define CMD_READ_IMEM        0x30
#define CMD_WRITE_IMEM       0x31
#define CMD_READ_DMEM        0x40
#define CMD_GET_STATUS       0x50

#define RESP_OK              0xAA
#define RESP_ERROR           0xEE

// ===== Memory Sizes =====
#define IMEM_SIZE 64                       // 64 instructions
#define DMEM_SIZE 64                       // 64 words
#define NUM_REGISTERS 32                   // 32 registers

// ===== Debug Settings =====
#define DEBUG_SERIAL_ENABLED true
#define DEBUG_BAUD_RATE 115200

#endif // CONFIG_H

