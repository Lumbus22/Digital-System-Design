# Quick Connection Guide

## 🎯 How to Connect - 3 Simple Steps!

---

## Step 1: Power On ESP32 ⚡

Plug in ESP32 via USB. It automatically creates a WiFi hotspot.

**Serial Monitor Output**:
```
[WIFI] ✓ Access Point started successfully!
[WIFI] SSID: RISC-V-CPU-IDE
[WIFI] IP Address: 192.168.4.1
```

---

## Step 2: Connect to WiFi 📶

**On Your Computer/Phone/Tablet:**

### Windows
1. Click WiFi icon in taskbar
2. Find network: **`RISC-V-CPU-IDE`**
3. Click Connect
4. Enter password: **`riscv32i`**
5. Click Next

### Mac
1. Click WiFi icon in menu bar
2. Select: **`RISC-V-CPU-IDE`**
3. Enter password: **`riscv32i`**
4. Click Join

### Linux
1. Click Network icon
2. Select: **`RISC-V-CPU-IDE`**
3. Enter password: **`riscv32i`**
4. Click Connect

### iOS (iPhone/iPad)
1. Settings → WiFi
2. Select: **`RISC-V-CPU-IDE`**
3. Enter password: **`riscv32i`**
4. Tap Join

### Android
1. Settings → WiFi
2. Select: **`RISC-V-CPU-IDE`**
3. Enter password: **`riscv32i`**
4. Tap Connect

---

## Step 3: Open Web IDE 🌐

**Open any web browser and go to:**

# **http://192.168.4.1**

**Bookmark it!** This address never changes.

---

## Visual Guide

```
┌─────────────────────────────────────────────────────────┐
│  Your Computer/Phone                                    │
│                                                          │
│  1. Connect to WiFi: "RISC-V-CPU-IDE"                  │
│     Password: riscv32i                                  │
│                                                          │
│  2. Open Browser: http://192.168.4.1                   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  🌐 RISC-V32I CPU Web IDE                        │  │
│  │  ┌────────────────┐  ┌─────────────────────────┐│  │
│  │  │ Code Editor    │  │ CPU Controls            ││  │
│  │  │                │  │ [Run] [Stop] [Reset]    ││  │
│  │  │ # Assembly     │  │                         ││  │
│  │  │ addi x1, x0, 10│  │ Registers | Memory      ││  │
│  │  │                │  │                         ││  │
│  │  └────────────────┘  └─────────────────────────┘│  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
                          │ WiFi
                          │
                          ▼
           ┌──────────────────────────┐
           │      ESP32 Board         │
           │                          │
           │  Access Point Active     │
           │  SSID: RISC-V-CPU-IDE   │
           │  IP: 192.168.4.1        │
           └──────────────────────────┘
                          │
                          │ UART (3 wires)
                          │
                          ▼
           ┌──────────────────────────┐
           │   DE10-Lite FPGA Board   │
           │                          │
           │    RISC-V CPU Running    │
           └──────────────────────────┘
```

---

## Connection States

### ✅ Connected Successfully
You should see:
- Computer WiFi shows: "Connected to RISC-V-CPU-IDE"
- Web browser loads IDE interface
- Green "Connected" badge in IDE

### ⚠️ Connection Issues

**"Can't find network"**
- ESP32 not powered on
- ESP32 still booting (wait 5 seconds)
- Your device WiFi is turned off

**"Wrong password"**
- Password is: `riscv32i` (all lowercase)
- Try typing it carefully

**"Connected but can't access IDE"**
- Type: `http://192.168.4.1` (not https)
- Disable VPN if active
- Try different browser
- Check firewall settings

---

## Multiple Users

**Can multiple people connect?**

Yes! Up to **4 devices** can connect simultaneously:
- All users see the same CPU
- First user to click "Run" controls execution
- All users can upload programs
- Best for demos and teaching

**Example Scenarios**:
- Teacher's laptop + 3 student tablets
- Desktop + laptop + phone + iPad
- 4 students working together

---

## Network Information

| Setting | Value |
|---------|-------|
| **Network Name (SSID)** | RISC-V-CPU-IDE |
| **Password** | riscv32i |
| **IP Address** | 192.168.4.1 (fixed) |
| **DHCP Range** | 192.168.4.2 - 192.168.4.5 |
| **Max Connections** | 4 devices |
| **WiFi Channel** | 6 (2.4 GHz) |
| **Security** | WPA2-PSK |

---

## Common Questions

### Q: Do I need internet?
**A: No!** The ESP32 creates its own network. No internet required.

### Q: What if I'm already connected to WiFi?
**A: Disconnect** from your current network and connect to `RISC-V-CPU-IDE`.

### Q: Will this work on my phone?
**A: Yes!** Works on any device with WiFi and a web browser.

### Q: Can I change the network name?
**A: Yes!** Edit `AP_SSID` in `esp32_firmware/include/config.h`.

### Q: Can I remove the password?
**A: Yes!** Set `AP_PASSWORD` to `""` in config.h (not recommended).

### Q: What if IP address doesn't work?
**A: Always use** `http://192.168.4.1` (not https, not .com).

### Q: Can I use Ethernet instead of WiFi?
**A: No**, ESP32 uses WiFi only. For wired connection, you'd need a different board.

---

## Alternative Access Methods

### 1. Direct IP Access
```
http://192.168.4.1
```
Most common and reliable.

### 2. Using Hostname (may not work on all devices)
```
http://riscv-cpu-ide.local
```
Works on some systems with mDNS support.

### 3. API Direct Access
```
http://192.168.4.1/api/cpu/status
```
For programmatic access or testing.

---

## Verification Checklist

Before connecting, verify:

- [ ] ESP32 is powered on (USB connected)
- [ ] Serial monitor shows "Access Point started successfully"
- [ ] FPGA is powered and programmed
- [ ] 3 wires connected (TX, RX, GND)
- [ ] Your device WiFi is enabled
- [ ] Your device supports 2.4GHz WiFi

After connecting:

- [ ] WiFi shows "Connected to RISC-V-CPU-IDE"
- [ ] Browser loads http://192.168.4.1
- [ ] IDE interface appears
- [ ] Green "Connected" badge visible
- [ ] Console shows "IDE Ready"

---

## Troubleshooting Flowchart

```
Can't connect to IDE?
    │
    ├─→ Can't see WiFi network?
    │   ├─→ Is ESP32 powered? → Power on ESP32
    │   └─→ Check serial monitor → Should show "AP started"
    │
    ├─→ See network but can't connect?
    │   ├─→ Wrong password? → Use "riscv32i"
    │   └─→ Too many users? → Max 4 connections
    │
    └─→ Connected but no IDE?
        ├─→ Try http://192.168.4.1 (not https)
        ├─→ Disable VPN
        └─→ Try different browser
```

---

## Quick Reference Card

Cut this out and keep near your desk:

```
┌─────────────────────────────────────────────┐
│     RISC-V CPU Web IDE - Quick Access       │
│                                              │
│  1. Connect to WiFi:                        │
│     SSID: RISC-V-CPU-IDE                   │
│     Password: riscv32i                      │
│                                              │
│  2. Open Browser:                           │
│     http://192.168.4.1                     │
│                                              │
│  3. Start Programming!                      │
│                                              │
│  Troubleshooting:                           │
│  - Check ESP32 powered on                   │
│  - Use 2.4GHz WiFi only                    │
│  - Type http:// (not https://)             │
│                                              │
│  Max Users: 4 simultaneous                  │
│  Works Offline: Yes                         │
│  Internet Required: No                      │
└─────────────────────────────────────────────┘
```

---

**Last Updated**: October 28, 2025  
**Works With**: All ESP32 variants in AP mode

