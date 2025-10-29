# Hardware Setup Guide

## Overview

This guide covers the physical connections between the DE10-Lite FPGA board and the ESP32 microcontroller, along with pin assignments and configuration.

## Required Hardware

1. **DE10-Lite FPGA Board** (Intel MAX 10)
2. **ESP32 Development Board** (ESP32-DevKitC or similar)
3. **USB Cables**: 
   - USB Mini-B for DE10-Lite
   - USB Micro-B for ESP32
4. **Jumper Wires**: At least 3 female-to-female wires
5. **Computer**: For programming both boards

## Connection Diagram

```
┌─────────────────────────┐
│      DE10-Lite FPGA     │
│                         │
│  [GPIO_TX]  ────────────┼────────────> [GPIO16 RX]
│  [GPIO_RX]  <───────────┼────────────  [GPIO17 TX]    ┌──────────────┐
│  [GND]      ────────────┼────────────  [GND]          │    ESP32     │
│                         │                              │   DevKit     │
│  [5V Supply] Optional   │                              └──────────────┘
└─────────────────────────┘
```

## Pin Assignments

### DE10-Lite FPGA Pin Assignments

Add these to your Quartus project `.qsf` file or via Pin Planner:

```tcl
# Clock (50 MHz)
set_location_assignment PIN_P11 -to clk

# Reset Button
set_location_assignment PIN_B8 -to reset_btn

# UART Interface to ESP32
set_location_assignment PIN_AB5 -to uart_rx    # FPGA RX from ESP32
set_location_assignment PIN_AB6 -to uart_tx    # FPGA TX to ESP32

# Optional: Status LEDs
set_location_assignment PIN_A8 -to status_leds[0]
set_location_assignment PIN_A9 -to status_leds[1]
set_location_assignment PIN_A10 -to status_leds[2]
set_location_assignment PIN_B10 -to status_leds[3]

# Optional: Debug Outputs (for logic analyzer)
set_location_assignment PIN_V10 -to pc_out[0]
# ... (add more as needed)

# I/O Standards
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to uart_rx
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to uart_tx
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to status_leds[*]
```

#### Recommended GPIO Pins on DE10-Lite

| Signal | DE10-Lite Pin | Arduino Header | Notes |
|--------|---------------|----------------|-------|
| uart_tx | AB6 | Arduino IO[1] | FPGA TX → ESP32 RX |
| uart_rx | AB5 | Arduino IO[0] | FPGA RX ← ESP32 TX |
| GND | GND | Arduino GND | Common ground |

**Note**: The DE10-Lite Arduino header makes connections convenient. Use the Arduino-compatible GPIO pins.

### ESP32 Pin Assignments

Configure in `esp32_firmware/include/config.h`:

```cpp
#define FPGA_UART_TX_PIN 17    // ESP32 TX → FPGA RX
#define FPGA_UART_RX_PIN 16    // ESP32 RX ← FPGA TX
```

#### ESP32 DevKit Pinout

| Signal | ESP32 Pin | Notes |
|--------|-----------|-------|
| TX to FPGA | GPIO17 | Connect to FPGA RX |
| RX from FPGA | GPIO16 | Connect to FPGA TX |
| GND | GND | Common ground |
| Power | 5V/3.3V | USB powered |

**Important**: ESP32 GPIOs are 3.3V. Ensure FPGA outputs are also 3.3V (LVTTL).

## Physical Connection Steps

### Step 1: Identify Pins

**On DE10-Lite:**
1. Locate the Arduino header (40-pin connector)
2. Find pins AB5 (Arduino IO[0]) and AB6 (Arduino IO[1])
3. Locate a GND pin on the header

**On ESP32:**
1. Locate GPIO16 and GPIO17 on the board
2. Locate a GND pin

### Step 2: Connect Wires

1. **FPGA TX → ESP32 RX**:
   - Connect DE10-Lite pin AB6 to ESP32 GPIO16

2. **FPGA RX ← ESP32 TX**:
   - Connect DE10-Lite pin AB5 to ESP32 GPIO17

3. **Ground**:
   - Connect DE10-Lite GND to ESP32 GND

### Step 3: Power Supply

**Separate Power (Recommended)**:
- Power DE10-Lite via USB from computer
- Power ESP32 via separate USB (can be same computer or USB power adapter)
- Ensure grounds are connected

**Shared Power (Advanced)**:
- DE10-Lite can provide 3.3V via Arduino header
- Check current requirements of your ESP32 board
- Most ESP32 boards need more current than DE10-Lite can provide (not recommended)

## Wiring Checklist

- [ ] FPGA programmed with `cpu_with_debug.v`
- [ ] FPGA TX (AB6) connected to ESP32 RX (GPIO16)
- [ ] FPGA RX (AB5) connected to ESP32 TX (GPIO17)
- [ ] GND connected between both boards
- [ ] Both boards powered on
- [ ] Status LEDs visible (optional)
- [ ] No shorts between power and ground

## Voltage Level Considerations

Both DE10-Lite (MAX 10 FPGA) and ESP32 operate at 3.3V logic levels, so direct connection is safe.

**Verify**:
- DE10-Lite GPIO pins set to "3.3-V LVTTL" in Quartus
- ESP32 GPIO16/17 are 3.3V compatible (they are by default)

## Testing the Connection

### 1. Visual Test
- Power on both boards
- Check for status LEDs on DE10-Lite
- Check for power LED on ESP32

### 2. Serial Monitor Test
Open ESP32 serial monitor (115200 baud):
```
Expected output:
========================================
RISC-V CPU Web IDE - ESP32 Firmware
========================================

[INIT] Initializing FPGA interface...
[FPGA] Interface initialized
[INIT] FPGA interface ready
...
```

### 3. Communication Test
From serial monitor or web IDE:
- Try reading PC: Should return 0x00000000 after reset
- Try reading status: Should not return error
- Try reset command: Should succeed

### 4. Loopback Test (Advanced)
For UART troubleshooting:
1. Disconnect ESP32 from FPGA
2. Connect ESP32 TX to ESP32 RX (loopback)
3. Send test data and verify echo
4. If loopback works, issue is likely FPGA-side

## Common Connection Issues

### Issue: No Communication

**Symptoms**: ESP32 reports FPGA timeout errors

**Checks**:
1. **Swap TX/RX**: Most common mistake - TX must go to RX
2. **Check GND**: Without common ground, UART won't work
3. **Verify pins**: Double-check pin numbers in code and hardware
4. **Check baud rate**: Must be 115200 on both sides
5. **FPGA programmed?**: Ensure FPGA has debug interface loaded

### Issue: Intermittent Communication

**Symptoms**: Sometimes works, sometimes fails

**Checks**:
1. **Wire quality**: Use good quality jumper wires
2. **Wire length**: Keep under 30cm for reliability
3. **Noise**: Route wires away from power supplies
4. **Loose connections**: Ensure wires are firmly inserted

### Issue: ESP32 Won't Program

**Symptoms**: Upload fails during flashing

**Solution**:
- Disconnect GPIO0/GPIO15/GPIO2 if connected
- These pins affect boot mode
- Program ESP32 first, then make connections

### Issue: FPGA Pin Assignment Conflicts

**Symptoms**: Quartus compilation errors about pins

**Solution**:
- Use Quartus Pin Planner to verify available pins
- Check for conflicts with other peripherals
- Consult DE10-Lite User Manual for pin functions

## Alternative Pin Configurations

If you need different pins due to conflicts:

### Option 1: Use Different GPIO Expansion Pins
```tcl
set_location_assignment PIN_Y15 -to uart_rx
set_location_assignment PIN_Y16 -to uart_tx
```

### Option 2: Use PMOD Connectors
DE10-Lite has PMOD connectors that can be used:
```tcl
set_location_assignment PIN_V10 -to uart_rx    # PMOD GPIO[0]
set_location_assignment PIN_W10 -to uart_tx    # PMOD GPIO[1]
```

## Advanced: Adding Hardware Flow Control

For more reliable communication, add RTS/CTS:

```tcl
# FPGA side
set_location_assignment PIN_AB7 -to uart_rts
set_location_assignment PIN_AB8 -to uart_cts
```

```cpp
// ESP32 side
#define FPGA_UART_RTS_PIN 18
#define FPGA_UART_CTS_PIN 19
```

Modify UART initialization to enable flow control.

## Electrical Specifications

| Parameter | DE10-Lite | ESP32 | Compatible? |
|-----------|-----------|-------|-------------|
| Logic High | 2.4V - 3.3V | 2.64V - 3.3V | ✓ Yes |
| Logic Low | 0V - 0.8V | 0V - 0.66V | ✓ Yes |
| Max Current per Pin | 8mA | 40mA | ✓ Yes |
| Input Impedance | High | High | ✓ Yes |

## Safety Notes

⚠️ **Important Safety Information**:

1. **Never connect 5V to 3.3V pins** - Will damage components
2. **Check polarity** - Incorrect power connections can destroy boards
3. **Static protection** - Use ESD strap when handling boards
4. **Hot plugging** - Avoid connecting/disconnecting while powered
5. **Short circuits** - Double-check wiring before power on

## Enclosure Recommendations

For a permanent setup:
1. Mount both boards in a project box
2. Use a small breadboard for wire management
3. Add status LEDs for visual feedback
4. Consider adding a power switch
5. Label all connections

## Next Steps

Once hardware is connected:
1. Program FPGA with debug interface
2. Upload ESP32 firmware
3. Verify communication via serial monitor
4. Access web IDE
5. Start programming!

---

**Need Help?** Check troubleshooting section or consult:
- DE10-Lite User Manual
- ESP32 Datasheet
- RISC-V CPU Web IDE documentation

