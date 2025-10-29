# Quick Start Guide - RISC-V32I Web IDE

## 🚀 Fast Track Setup (30 minutes)

### What You Need
- ✅ DE10-Lite FPGA board
- ✅ ESP32 development board  
- ✅ 3 jumper wires (Female-to-Female)
- ✅ 2 USB cables
- ✅ Computer with Quartus Prime and PlatformIO/Arduino IDE

---

## Step 1: Hardware Connections (5 minutes)

Connect three wires between boards:

```
DE10-Lite          ESP32
├─ Pin AB6    →   GPIO16 (RX)
├─ Pin AB5    ←   GPIO17 (TX)
└─ GND        →   GND
```

**That's it!** Just 3 wires.

---

## Step 2: Configure ESP32 (Optional - Already Set!)

**Good News**: ESP32 is pre-configured in Access Point mode! 

**Default Settings** (in `esp32_firmware/include/config.h`):
- **WiFi Network**: `RISC-V-CPU-IDE`
- **Password**: `riscv32i`
- **IP Address**: `192.168.4.1` (fixed)

You can change these if desired, but it works out of the box!

---

## Step 3: Flash ESP32 (5 minutes)

**Using PlatformIO**:
```bash
cd esp32_firmware
pio run --target upload
pio run --target uploadfs  # Upload web files
```

**Using Arduino IDE**:
- Open `esp32_firmware/src/main.cpp`
- Install libraries: ESPAsyncWebServer, ArduinoJson
- Select board: "ESP32 Dev Module"
- Click Upload

---

## Step 4: Program FPGA (10 minutes)

1. Open Quartus Prime
2. Create new project
3. Add all files from `fpga_debug/` folder
4. Add your original CPU files: `control.v`, `alu.v`
5. Set top-level: `cpu_with_debug`
6. Add pin assignments:
```tcl
set_location_assignment PIN_P11 -to clk
set_location_assignment PIN_B8 -to reset_btn
set_location_assignment PIN_AB5 -to uart_rx
set_location_assignment PIN_AB6 -to uart_tx
```
7. Compile and program FPGA

---

## Step 5: Connect to ESP32 WiFi (1 minute)

1. On your computer/phone, open WiFi settings
2. Connect to network: **`RISC-V-CPU-IDE`**
3. Password: **`riscv32i`**
4. Wait for connection (should be instant!)

**IP Address is always**: `192.168.4.1` (no need to find it!)

---

## Step 6: Access Web IDE (1 minute)

1. Open web browser (while connected to `RISC-V-CPU-IDE` WiFi)
2. Go to: **`http://192.168.4.1`**
3. You should see the IDE instantly!

**Bookmark this**: `http://192.168.4.1` (always the same!)

---

## Step 7: Test It! (2 minutes)

In the web IDE:

1. Click **"Load Example"**
2. Click **"Assemble"** (should show success)
3. Click **"Upload"** (program goes to FPGA)
4. Click **"Reset"** (start fresh)
5. Click **"Run"** (CPU executes)
6. Watch registers update in real-time!

---

## ✅ Success Checklist

You know it's working when:
- [ ] ESP32 serial monitor shows "Access Point started successfully!"
- [ ] You can see "RISC-V-CPU-IDE" WiFi network
- [ ] You can connect to the WiFi network
- [ ] Web IDE loads at http://192.168.4.1
- [ ] Green "Connected" badge in IDE header
- [ ] Example code assembles successfully
- [ ] Program uploads without errors
- [ ] Registers show changing values when running

---

## ❌ Troubleshooting

### "Cannot access IDE"
→ Ensure you're connected to **RISC-V-CPU-IDE** WiFi network  
→ Try **http://192.168.4.1** (fixed IP in AP mode)  
→ Check ESP32 serial monitor to confirm AP started

### "FPGA not responding"
→ Check 3-wire connections (TX, RX, GND)  
→ Verify FPGA is programmed (check status LEDs)  
→ Try swapping TX/RX wires

### "Assembly errors"
→ Check instruction syntax (spaces, not tabs)  
→ Verify register names: x0-x31  
→ Check for typos in instruction names

---

## 📖 Example Program

Try this simple program:

```assembly
# Add two numbers
addi x1, x0, 42    # x1 = 42
addi x2, x0, 58    # x2 = 58
add x3, x1, x2     # x3 = 100

# Result should be in x3
# Infinite loop
jal x0, 0
```

**Expected Result**: Register x3 = 100 (0x00000064)

---

## 🎯 What's Next?

**Explore Features**:
- Try different instructions
- Watch memory tab
- Use single-step mode
- Monitor all registers

**Learn More**:
- `docs/README.md` - Full documentation
- `docs/HARDWARE_SETUP.md` - Detailed pin info
- `docs/API_REFERENCE.md` - REST API docs
- `INSTRUCTION_REFERENCE.md` - All instructions

**Write Programs**:
- Fibonacci calculator
- Array sorting
- Math operations
- Control flow examples

---

## 📁 Project Structure

```
RISC-V32I-CPU/
├── fpga_debug/        ← FPGA files (Verilog)
├── esp32_firmware/    ← ESP32 code (C++)
├── web_ide/          ← Web interface (HTML/JS)
└── docs/             ← Documentation
```

---

## 🔧 Common Pin Assignments

| Board | TX Pin | RX Pin | GND |
|-------|--------|--------|-----|
| DE10-Lite | AB6 (Arduino IO[1]) | AB5 (Arduino IO[0]) | GND |
| ESP32 | GPIO17 | GPIO16 | GND |

**Remember**: TX connects to RX (crossover)

---

## 💡 Pro Tips

1. **Always stop CPU before upload** - Prevents corruption
2. **Reset after upload** - Start from PC=0
3. **Use example programs** - Learn by example
4. **Check console tab** - Shows all messages
5. **Refresh registers** - Click registers tab to update

---

## 🆘 Need Help?

1. Check serial monitor output (ESP32)
2. Check browser console (F12)
3. Verify all connections
4. Review documentation in `docs/`
5. Double-check WiFi credentials

---

## 🎉 You're Ready!

Your RISC-V CPU is now web-enabled! Start writing assembly programs and see them execute on real hardware in real-time.

**Happy Coding!** 🚀

---

**Quick Start Version**: 1.0  
**Last Updated**: October 28, 2025

