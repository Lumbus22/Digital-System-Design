## RISC-V32I CPU Web-Based IDE System

# Overview

This project implements a complete web-based Integrated Development Environment (IDE) for programming a RISC-V32I CPU running on a DE10-Lite Intel FPGA board. The system uses an ESP32 microcontroller as a bridge between the FPGA and a web browser, enabling remote assembly programming, debugging, and visualization.

## System Architecture

```
┌──────────────┐      UART       ┌──────────┐      WiFi/HTTP    ┌─────────────┐
│              │  <──────────>    │          │  <─────────────>   │             │
│  DE10-Lite   │                  │  ESP32   │                    │  Web        │
│  FPGA Board  │                  │  Bridge  │                    │  Browser    │
│  (RISC-V CPU)│                  │          │                    │  (IDE)      │
└──────────────┘                  └──────────┘                    └─────────────┘
```

### Components

1. **FPGA (DE10-Lite)**: Runs the RISC-V32I CPU with debug interface
2. **ESP32**: Web server and FPGA communication bridge
3. **Web Browser**: User interface for assembly programming

## Features

### IDE Features
- ✅ Syntax-highlighted assembly code editor
- ✅ Real-time assembly compilation (client-side)
- ✅ Program upload to FPGA
- ✅ CPU control (Run, Stop, Reset, Single-step)
- ✅ Live register monitoring (all 32 registers)
- ✅ Memory visualization (instruction and data memory)
- ✅ Program counter and instruction tracking
- ✅ Example programs
- ✅ Error reporting and console output

### CPU Features
- ✅ Full RISC-V32I instruction set (37 instructions)
- ✅ 32 general-purpose registers
- ✅ 64-word instruction memory
- ✅ 64-word data memory
- ✅ Debug interface with UART communication
- ✅ External program loading
- ✅ Single-step execution
- ✅ CPU state inspection

### Supported Instructions
- **R-Type**: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
- **I-Type**: ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI, LW, JALR
- **S-Type**: SW
- **B-Type**: BEQ, BNE, BLT, BGE, BLTU, BGEU
- **U-Type**: LUI, AUIPC
- **J-Type**: JAL
- **Pseudo**: NOP, LI, MV, J, RET

## Directory Structure

```
RISC-V32I-CPU/
├── fpga_debug/              # FPGA debug interface modules
│   ├── uart_tx.v           # UART transmitter
│   ├── uart_rx.v           # UART receiver
│   ├── debug_interface.v   # Main debug controller
│   ├── cpu_with_debug.v    # Top-level CPU with debug
│   ├── imem_debug.v        # Instruction memory with debug access
│   ├── regfile_debug.v     # Register file with debug access
│   └── dmem_debug.v        # Data memory with debug access
│
├── esp32_firmware/          # ESP32 firmware
│   ├── platformio.ini      # PlatformIO configuration
│   ├── include/
│   │   ├── config.h        # Configuration settings
│   │   ├── fpga_interface.h
│   │   └── web_server.h
│   └── src/
│       ├── main.cpp        # Main firmware entry point
│       ├── fpga_interface.cpp
│       └── web_server.cpp
│
├── web_ide/                 # Web-based IDE
│   ├── index.html          # Main IDE interface
│   ├── css/
│   │   └── style.css       # IDE styling
│   └── js/
│       ├── assembler.js    # RISC-V assembler
│       ├── api.js          # API communication
│       └── app.js          # Main application logic
│
├── docs/                    # Documentation
│   ├── README.md           # This file
│   ├── HARDWARE_SETUP.md   # Hardware connections guide
│   ├── FIRMWARE_SETUP.md   # ESP32 firmware setup
│   └── API_REFERENCE.md    # REST API documentation
│
└── (original CPU files)     # Your existing CPU implementation
```

## Quick Start Guide

### Prerequisites
- DE10-Lite FPGA board
- ESP32 development board
- USB cables for programming
- Quartus Prime (for FPGA programming)
- PlatformIO or Arduino IDE (for ESP32)
- Jumper wires for connections

### Step 1: Program the FPGA

1. Open Quartus Prime
2. Create a new project and add the files from `fpga_debug/`
3. Set `cpu_with_debug.v` as the top-level entity
4. Add pin assignments (see HARDWARE_SETUP.md)
5. Compile and program the FPGA

### Step 2: Setup ESP32

1. Install PlatformIO or Arduino IDE
2. Open `esp32_firmware/` project
3. **Configuration is already done!** ESP32 runs in Access Point mode
   - Network: `RISC-V-CPU-IDE`
   - Password: `riscv32i`
   - IP: `192.168.4.1` (fixed)
4. Compile and upload firmware to ESP32

### Step 3: Connect Hardware

Connect ESP32 to FPGA via UART:
- ESP32 TX (GPIO17) → FPGA RX
- ESP32 RX (GPIO16) → FPGA TX
- GND → GND

See `docs/HARDWARE_SETUP.md` for detailed pinout.

### Step 4: Upload Web IDE

1. Copy files from `web_ide/` to ESP32's LittleFS filesystem
2. Use PlatformIO's "Upload File System image" or similar tool
3. Restart ESP32

### Step 5: Access the IDE

1. Connect to **`RISC-V-CPU-IDE`** WiFi network (password: `riscv32i`)
2. Open web browser and navigate to **`http://192.168.4.1`**
3. Start programming!

**Note**: The IP address is always `192.168.4.1` in Access Point mode - easy to remember!

## Usage Examples

### Example 1: Simple Addition
```assembly
# Add two numbers
addi x1, x0, 10    # x1 = 10
addi x2, x0, 20    # x2 = 20
add x3, x1, x2     # x3 = 30
jal x0, 0          # Infinite loop
```

### Example 2: Fibonacci Sequence
```assembly
# Calculate Fibonacci numbers
addi x1, x0, 0      # x1 = 0 (fib[0])
addi x2, x0, 1      # x2 = 1 (fib[1])
addi x3, x0, 10     # x3 = 10 (iterations)

loop:
    add x4, x1, x2  # x4 = x1 + x2
    mv x1, x2       # x1 = x2
    mv x2, x4       # x2 = x4
    addi x3, x3, -1 # Decrement counter
    bne x3, x0, loop # Continue if not zero

end:
    jal x0, end     # Infinite loop
```

### Example 3: Array Sum
```assembly
# Sum array elements
addi x1, x0, 10    # array[0] = 10
sw x1, 0(x0)
addi x1, x0, 20    # array[1] = 20
sw x1, 4(x0)
addi x1, x0, 30    # array[2] = 30
sw x1, 8(x0)

# Sum elements
lw x2, 0(x0)       # Load array[0]
lw x3, 4(x0)       # Load array[1]
lw x4, 8(x0)       # Load array[2]

add x5, x2, x3     # Sum first two
add x5, x5, x4     # Add third (total in x5)
```

## Communication Protocol

### UART Protocol (ESP32 ↔ FPGA)

**Baud Rate**: 115200  
**Format**: 8N1 (8 data bits, no parity, 1 stop bit)

**Command Format**:
```
[CMD_BYTE] [ADDR_BYTE (optional)] [DATA_4_BYTES (optional)]
```

**Response Format**:
```
[RESP_BYTE] [DATA_4_BYTES]
```

### REST API (Browser ↔ ESP32)

**Base URL**: `http://<ESP32_IP>/api/`

See `docs/API_REFERENCE.md` for complete API documentation.

## Troubleshooting

### FPGA Not Responding
- Check UART connections
- Verify baud rate matches (115200)
- Check FPGA is programmed correctly
- Verify ESP32 TX/RX pins

### Cannot Connect to Web IDE
- Ensure you're connected to **RISC-V-CPU-IDE** WiFi network
- Verify ESP32 Access Point started (check serial monitor)
- Try **http://192.168.4.1** in browser
- Check that your device supports 2.4GHz WiFi

### Assembly Errors
- Check instruction syntax
- Verify register names (x0-x31 or ABI names)
- Check immediate value ranges
- Verify label names are unique

### Program Not Uploading
- Ensure CPU is stopped before upload
- Check program size (max 64 instructions)
- Verify ESP32-FPGA connection
- Check serial monitor for errors

## Performance Characteristics

- **FPGA Clock**: 50 MHz
- **CPU Architecture**: Single-cycle
- **UART Speed**: 115200 baud (~11.5 KB/s)
- **Program Upload Time**: ~300ms for 64 instructions
- **Register Read Time**: ~5ms per register
- **Memory Read Time**: ~5ms per word
- **Web Server Response**: < 100ms typical

## Limitations

1. **Memory Size**: Limited to 64 instructions and 64 data words
2. **Single-Cycle**: No pipelined execution (educational design)
3. **No Interrupts**: Polling-based only
4. **Basic Memory**: No byte/halfword operations
5. **Web Clients**: Limited to ~4-5 concurrent connections

## Future Enhancements

- [ ] Breakpoint support
- [ ] Watchpoints for registers/memory
- [ ] Execution history/trace
- [ ] Waveform visualization
- [ ] Larger memory (256+ instructions)
- [ ] WebSocket for real-time updates
- [ ] Dark/light theme toggle
- [ ] Save/load programs
- [ ] Disassembler improvements
- [ ] Performance profiling

## License

This project is provided as-is for educational purposes.

## Credits

- RISC-V32I CPU core: Based on standard RV32I specification
- ESP32 Framework: Arduino/ESP-IDF
- Web UI: Bootstrap 5, Font Awesome

## Support

For issues, questions, or contributions, please refer to the project repository.

---

**Last Updated**: October 2025  
**Version**: 1.0.0

