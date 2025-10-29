# FPGA Connection Troubleshooting Guide

## Current Status
- ✅ ESP32 programmed and web server working
- ✅ FPGA programmed with debug interface
- ✅ Pin assignments verified correct
- ❌ ESP32 cannot communicate with FPGA

## Pin Verification

### ESP32 Pins
```
GPIO17 (TX) → FPGA Pin AB5 (RX)
GPIO16 (RX) ← FPGA Pin AB6 (TX)
GND        → GND
```

### FPGA Pins (DE10-Lite)
```
AB5 (uart_rx) ← ESP32 GPIO17
AB6 (uart_tx) → ESP32 GPIO16
```

## Troubleshooting Procedure

### Step 1: Visual Inspection
- [ ] Check all 3 wires are firmly connected
- [ ] Verify no loose connections
- [ ] Check wires aren't damaged
- [ ] Confirm correct pins (AB5, AB6, not other nearby pins)
- [ ] Verify GND is connected

### Step 2: Check ESP32 Serial Monitor

Open serial monitor (115200 baud) and look for:

**When you click controls in web IDE, you should see:**
```
[FPGA] Sending command...
[FPGA] Timeout waiting for response
```

**If you see timeouts**: UART isn't working
**If you see nothing**: Commands aren't being sent

### Step 3: Test FPGA UART with Loopback

**On FPGA board**, temporarily short TX and RX together:
- Connect Pin AB5 to Pin AB6 (loopback)
- This creates UART echo

If loopback works, FPGA UART is functional.

### Step 4: Check FPGA Compilation Report

In Quartus, check:
1. **Compilation Report → Fitter → Resource Section**
   - Verify uart_rx and uart_tx pins are assigned
   
2. **Pin Planner** (Assignments → Pin Planner)
   - Check AB5 shows "uart_rx"
   - Check AB6 shows "uart_tx"
   - Verify both are "3.3-V LVTTL"

### Step 5: Voltage Level Check (Advanced)

Use multimeter or logic analyzer:
- **FPGA AB6 (TX)**: Should be ~3.3V when idle
- **ESP32 GPIO17 (TX)**: Should be ~3.3V when idle
- Both should pulse when sending data

### Step 6: Check FPGA Clock

Verify FPGA is running:
- Check if any LEDs blink (if programmed to blink)
- Status LEDs should show something
- Clock should be 50MHz

### Step 7: Test with Simple FPGA Program

Create a minimal UART echo test on FPGA to verify UART works.

## Common Issues and Fixes

### Issue 1: Wrong Arduino Header Pins

**DE10-Lite Arduino Header:**
```
Digital IO[0] = AB5  ✓ (This is correct for RX)
Digital IO[1] = AB6  ✓ (This is correct for TX)
```

Some boards label these differently. Double-check your specific board's pinout.

### Issue 2: Swapped TX/RX

Even though connections look right, try swapping:
```
Swap: AB5 ↔ AB6
```

Sometimes board documentation has errors.

### Issue 3: Ground Not Connected

**Critical**: GND MUST be connected!
- Find any GND pin on DE10-Lite Arduino header
- Connect to ESP32 GND
- Use multimeter to verify continuity

### Issue 4: FPGA Not Actually Running Debug Code

Verify in Quartus **Programmer**:
- Device shows "10M50DAF484C7G"
- Programming succeeded
- Check "Verify" option and reprogram

### Issue 5: Baud Rate Mismatch

Both are set to 115200, but verify:

**FPGA** (`uart_tx.v` and `uart_rx.v`):
```verilog
parameter CLOCK_FREQ = 50000000,  // 50 MHz
parameter BAUD_RATE = 115200
```

**ESP32** (`config.h`):
```cpp
#define FPGA_UART_BAUD 115200
```

If FPGA clock isn't 50MHz, baud rate will be wrong!

### Issue 6: FPGA Reset Stuck

Try:
- Press and release FPGA reset button
- Power cycle FPGA board
- Reprogram FPGA

### Issue 7: ESP32 UART Not Initialized

Check ESP32 serial monitor for:
```
[FPGA] Interface initialized
```

If missing, ESP32 UART didn't start properly.

## Diagnostic Commands

### Check in Browser Console (F12)

In the web IDE, open browser console and try:
```javascript
// Try to get CPU status
fetch('http://192.168.4.1/api/cpu/status')
  .then(r => r.json())
  .then(d => console.log(d));
```

Should return timeout or error message.

### Check ESP32 Logs

In ESP32 serial monitor, manually test FPGA connection:

The ESP32 tries to communicate when:
- Web page loads (reads status)
- Any button clicked in IDE

Watch for UART activity in logs.

## Hardware Test: LED Blink

Modify FPGA code to blink an LED to confirm it's running:

```verilog
// Add to cpu_with_debug.v
reg [25:0] counter;
always @(posedge clk)
    counter <= counter + 1;
    
assign status_leds[0] = counter[25]; // Blinks every ~1.3 seconds
```

If LED blinks, FPGA is running. If not, FPGA program isn't working.

## Advanced: Logic Analyzer Testing

If you have a logic analyzer:
1. Connect to AB5 (FPGA RX)
2. Connect to AB6 (FPGA TX)
3. Connect to ESP32 GPIO17 (TX)
4. Connect to ESP32 GPIO16 (RX)
5. Trigger on any edge
6. Look for 115200 baud UART frames

Should see:
- ESP32 sends: Start bit + 8 data bits + Stop bit
- FPGA responds: Same format

## Quick Test: Swap Pins in Config

Try changing ESP32 pins to different GPIOs:

In `config.h`:
```cpp
#define FPGA_UART_TX_PIN 22  // Try different pins
#define FPGA_UART_RX_PIN 23
```

Then move wires to match. Sometimes GPIO16/17 have issues.

## Last Resort: Use Different FPGA Pins

Try different FPGA pins:
```tcl
# In cpu.qsf, try:
set_location_assignment PIN_V10 -to uart_rx
set_location_assignment PIN_W10 -to uart_tx
```

These are on the PMOD connector (easier to access).

## Expected Working Behavior

When everything works:
1. Web IDE loads at 192.168.4.1 ✅
2. Green "Connected" badge appears
3. CPU controls respond
4. Registers can be read
5. Programs can be uploaded
6. CPU executes code

## Current Working Status
- [x] Web IDE loads
- [x] ESP32 Access Point works
- [x] FPGA programmed
- [ ] ESP32-FPGA communication ← **YOU ARE HERE**
- [ ] CPU control working
- [ ] Program execution

---

## Next Steps

1. **Check ESP32 serial monitor** - Look for timeout messages
2. **Try swapping TX/RX** - Just to rule it out
3. **Verify GND connection** - Use multimeter for continuity
4. **Check pin voltage** - Should be 3.3V when idle
5. **Add LED blink to FPGA** - Confirm FPGA is actually running

Report back what you see in the ESP32 serial monitor when you click buttons in the web IDE!

