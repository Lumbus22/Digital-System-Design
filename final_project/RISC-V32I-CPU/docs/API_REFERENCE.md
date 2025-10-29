## REST API Reference

# RISC-V CPU Web IDE API Documentation

**Base URL**: `http://<ESP32_IP_ADDRESS>/api/`  
**Protocol**: HTTP/1.1  
**Content-Type**: `application/json`

## Authentication

Currently, no authentication is required. The API is open to all clients on the same network.

## Response Format

All API responses follow this structure:

**Success Response**:
```json
{
    "success": true,
    "message": "Operation completed",
    "data": { /* result data */ }
}
```

**Error Response**:
```json
{
    "success": false,
    "error": "Error message description"
}
```

## API Endpoints

### CPU Control

#### Start CPU Execution

**Endpoint**: `POST /api/cpu/start`

Starts continuous CPU execution.

**Request**: No body required

**Response**:
```json
{
    "success": true,
    "message": "CPU started"
}
```

**Example**:
```javascript
fetch('http://192.168.1.100/api/cpu/start', { method: 'POST' })
    .then(response => response.json())
    .then(data => console.log(data));
```

---

#### Stop CPU Execution

**Endpoint**: `POST /api/cpu/stop`

Halts CPU execution.

**Request**: No body required

**Response**:
```json
{
    "success": true,
    "message": "CPU stopped"
}
```

---

#### Reset CPU

**Endpoint**: `POST /api/cpu/reset`

Resets CPU to initial state (PC=0, all registers cleared).

**Request**: No body required

**Response**:
```json
{
    "success": true,
    "message": "CPU reset"
}
```

---

#### Single Step

**Endpoint**: `POST /api/cpu/step`

Executes one instruction and halts.

**Request**: No body required

**Response**:
```json
{
    "success": true,
    "message": "CPU stepped"
}
```

---

#### Get CPU Status

**Endpoint**: `GET /api/cpu/status`

Retrieves current CPU state.

**Response**:
```json
{
    "success": true,
    "status": 1,
    "running": true,
    "pc": 16,
    "current_instruction": 2147483667
}
```

**Fields**:
- `status` (uint8): Status byte (bit 0 = running)
- `running` (boolean): True if CPU is executing
- `pc` (uint32): Current program counter value
- `current_instruction` (uint32): Instruction at current PC

---

### Register Operations

#### Get All Registers

**Endpoint**: `GET /api/registers`

Retrieves all 32 register values.

**Response**:
```json
{
    "success": true,
    "registers": [
        0, 192, 10, 20, 30, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0
    ]
}
```

**Fields**:
- `registers` (array[32]): Register values x0-x31

**Notes**:
- x0 (zero) always returns 0
- Values are unsigned 32-bit integers

---

#### Get Single Register

**Endpoint**: `GET /api/registers/{reg_num}`

Retrieves a specific register value.

**Parameters**:
- `reg_num` (path): Register number (0-31)

**Response**:
```json
{
    "success": true,
    "register": 10,
    "value": 255
}
```

**Example**:
```javascript
// Read register x10 (a0)
fetch('http://192.168.1.100/api/registers/10')
    .then(response => response.json())
    .then(data => console.log('x10 =', data.value));
```

---

### Memory Operations

#### Get Instruction Memory

**Endpoint**: `GET /api/memory/instruction`

Retrieves all instruction memory contents (64 words).

**Response**:
```json
{
    "success": true,
    "memory": [
        147, 275, 403, 531, 659, /* ... 59 more values */
    ]
}
```

**Fields**:
- `memory` (array[64]): Instruction memory contents

**Notes**:
- Each element is a 32-bit instruction
- Index represents instruction address / 4
- Address 0 = memory[0], Address 4 = memory[1], etc.

---

#### Get Data Memory

**Endpoint**: `GET /api/memory/data`

Retrieves all data memory contents (64 words).

**Response**:
```json
{
    "success": true,
    "memory": [
        0, 1, 1, 2, 3, 5, 8, 13, /* ... */
    ]
}
```

**Fields**:
- `memory` (array[64]): Data memory contents

---

#### Get Program Counter

**Endpoint**: `GET /api/pc`

Retrieves current PC value.

**Response**:
```json
{
    "success": true,
    "pc": 48
}
```

---

#### Get Current Instruction

**Endpoint**: `GET /api/instruction`

Retrieves the instruction at current PC.

**Response**:
```json
{
    "success": true,
    "instruction": 2147483667
}
```

---

### Program Operations

#### Upload Program

**Endpoint**: `POST /api/program/upload`

Uploads a compiled program to instruction memory.

**Request**:
- **Content-Type**: `application/octet-stream`
- **Body**: Binary data (machine code instructions)
- **Format**: Little-endian 32-bit words

**Response**:
```json
{
    "success": true,
    "message": "Program uploaded successfully",
    "instructions": 53
}
```

**Fields**:
- `instructions` (int): Number of instructions uploaded

**Example** (JavaScript):
```javascript
// machineCode is array of uint32 values
const buffer = new ArrayBuffer(machineCode.length * 4);
const view = new DataView(buffer);

for (let i = 0; i < machineCode.length; i++) {
    view.setUint32(i * 4, machineCode[i], true); // little-endian
}

fetch('http://192.168.1.100/api/program/upload', {
    method: 'POST',
    headers: { 'Content-Type': 'application/octet-stream' },
    body: buffer
})
.then(response => response.json())
.then(data => console.log(data));
```

**Notes**:
- CPU is automatically stopped during upload
- Maximum 64 instructions (256 bytes)
- Remaining memory filled with NOPs

---

## Error Codes

| HTTP Status | Meaning | Typical Cause |
|-------------|---------|---------------|
| 200 | Success | Request completed successfully |
| 400 | Bad Request | Invalid parameters or data |
| 404 | Not Found | Invalid endpoint |
| 500 | Internal Server Error | FPGA communication failure |
| 503 | Service Unavailable | ESP32 not ready |

## Error Response Examples

### Invalid Register Number
```json
{
    "success": false,
    "error": "Invalid register number"
}
```

### FPGA Communication Timeout
```json
{
    "success": false,
    "error": "Timeout waiting for response"
}
```

### Program Too Large
```json
{
    "success": false,
    "error": "Program too large"
}
```

## Rate Limiting

Currently, no rate limiting is enforced. However, recommended limits:
- **CPU Control**: Max 10 requests/second
- **Register/Memory Reads**: Max 20 requests/second
- **Program Upload**: Max 1 request/5 seconds

Excessive requests may cause timeouts or missed updates.

## CORS (Cross-Origin Resource Sharing)

API supports CORS with the following headers:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type
```

This allows the IDE to be hosted on a different server than the ESP32.

## WebSocket Support (Future)

Currently, the API is REST-based (request/response). Future versions may add WebSocket support for:
- Real-time register updates
- Streaming execution trace
- Breakpoint notifications

## API Usage Examples

### Complete Workflow Example

```javascript
const API_BASE = 'http://192.168.1.100/api';

// 1. Reset CPU
async function resetCPU() {
    const response = await fetch(`${API_BASE}/cpu/reset`, { method: 'POST' });
    return await response.json();
}

// 2. Upload program
async function uploadProgram(machineCode) {
    const buffer = new ArrayBuffer(machineCode.length * 4);
    const view = new DataView(buffer);
    
    for (let i = 0; i < machineCode.length; i++) {
        view.setUint32(i * 4, machineCode[i], true);
    }
    
    const response = await fetch(`${API_BASE}/program/upload`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/octet-stream' },
        body: buffer
    });
    
    return await response.json();
}

// 3. Start execution
async function startCPU() {
    const response = await fetch(`${API_BASE}/cpu/start`, { method: 'POST' });
    return await response.json();
}

// 4. Monitor registers
async function monitorRegisters() {
    setInterval(async () => {
        const response = await fetch(`${API_BASE}/registers`);
        const data = await response.json();
        console.log('Registers:', data.registers);
    }, 500); // Update every 500ms
}

// Execute workflow
async function main() {
    await resetCPU();
    await uploadProgram([0x00000093, 0x00100113, ...]); // Example instructions
    await startCPU();
    monitorRegisters();
}

main();
```

### Python Example

```python
import requests
import struct

API_BASE = 'http://192.168.1.100/api'

def reset_cpu():
    response = requests.post(f'{API_BASE}/cpu/reset')
    return response.json()

def upload_program(machine_code):
    # Convert list of integers to binary
    binary_data = b''.join(struct.pack('<I', instr) for instr in machine_code)
    
    response = requests.post(
        f'{API_BASE}/program/upload',
        data=binary_data,
        headers={'Content-Type': 'application/octet-stream'}
    )
    return response.json()

def get_registers():
    response = requests.get(f'{API_BASE}/registers')
    return response.json()

# Example usage
reset_cpu()
program = [0x00000093, 0x00100113, 0x002081B3]  # Simple ADD program
upload_program(program)
requests.post(f'{API_BASE}/cpu/start')

# Read results
import time
time.sleep(1)
registers = get_registers()
print(f"x3 = {registers['registers'][3]}")
```

## Timing Considerations

Typical API response times:
- CPU control commands: 10-50ms
- Single register read: 5-10ms
- All registers read: 150-300ms
- Memory read: 150-300ms
- Program upload: 300-500ms (64 instructions)

For real-time monitoring, poll at reasonable intervals (100-500ms) to avoid overwhelming the ESP32.

## Best Practices

1. **Stop CPU before upload**: Always stop execution before uploading new program
2. **Check success field**: Always verify `success` field before using data
3. **Handle errors gracefully**: Network issues can occur, implement retry logic
4. **Batch operations**: Read all registers at once instead of individual reads
5. **Reasonable polling**: Don't poll faster than 10Hz for live updates
6. **Timeout handling**: Implement timeouts for all API calls (2-5 seconds)

## API Versioning

Current API version: **v1.0**

Version info available at: `GET /api/version` (future feature)

---

**Last Updated**: October 2025  
**API Version**: 1.0.0

