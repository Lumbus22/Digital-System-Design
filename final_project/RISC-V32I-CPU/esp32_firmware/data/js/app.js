// Main Application Logic

// Global instances
const assembler = new RISCVAssembler();
const api = new CPUAPI();

// State
let cpuRunning = false;
let currentPC = 0;
let updateInterval = null;
let previousRegisters = new Array(32).fill(0);

// Register ABI names
const registerNames = [
    'x0 (zero)', 'x1 (ra)', 'x2 (sp)', 'x3 (gp)', 'x4 (tp)',
    'x5 (t0)', 'x6 (t1)', 'x7 (t2)', 'x8 (s0/fp)', 'x9 (s1)',
    'x10 (a0)', 'x11 (a1)', 'x12 (a2)', 'x13 (a3)', 'x14 (a4)', 'x15 (a5)',
    'x16 (a6)', 'x17 (a7)', 'x18 (s2)', 'x19 (s3)', 'x20 (s4)', 'x21 (s5)',
    'x22 (s6)', 'x23 (s7)', 'x24 (s8)', 'x25 (s9)', 'x26 (s10)', 'x27 (s11)',
    'x28 (t3)', 'x29 (t4)', 'x30 (t5)', 'x31 (t6)'
];

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
    console.log('RISC-V CPU Web IDE Initialized');
    
    // Setup event listeners
    setupEventListeners();
    
    // Initial UI update
    updateRegistersDisplay();
    logConsole('IDE Ready. Write assembly code or load an example.', 'info');
    
    // Check connection
    checkConnection();
});

function setupEventListeners() {
    // Code Editor Buttons
    document.getElementById('btnCompile').addEventListener('click', handleCompile);
    document.getElementById('btnUpload').addEventListener('click', handleUpload);
    document.getElementById('btnLoadExample').addEventListener('click', loadExample);
    
    // CPU Control Buttons
    document.getElementById('btnRun').addEventListener('click', handleRun);
    document.getElementById('btnStop').addEventListener('click', handleStop);
    document.getElementById('btnReset').addEventListener('click', handleReset);
    document.getElementById('btnStep').addEventListener('click', handleStep);
    
    // Memory Controls
    document.getElementById('btnRefreshMemory').addEventListener('click', updateMemoryDisplay);
    
    // Console Controls
    document.getElementById('btnClearConsole').addEventListener('click', clearConsole);
}

// ===== Compilation and Upload =====

async function handleCompile() {
    logConsole('Assembling code...', 'info');
    
    const sourceCode = document.getElementById('codeEditor').value;
    const result = assembler.assemble(sourceCode);
    
    if (result.success) {
        logConsole(`✓ Assembly successful! Generated ${result.machineCode.length} instructions.`, 'success');
        
        // Display machine code
        result.machineCode.forEach((instr, i) => {
            const hex = '0x' + instr.toString(16).padStart(8, '0').toUpperCase();
            logConsole(`  [${i}] ${hex}`, 'info');
        });
        
        return result.machineCode;
    } else {
        logConsole('✗ Assembly failed:', 'error');
        result.errors.forEach(err => logConsole(`  ${err}`, 'error'));
        return null;
    }
}

async function handleUpload() {
    const machineCode = await handleCompile();
    
    if (!machineCode) {
        return;
    }
    
    try {
        logConsole('Uploading program to FPGA...', 'info');
        const response = await api.uploadProgram(machineCode);
        
        if (response.success) {
            logConsole(`✓ Program uploaded successfully! (${response.instructions} instructions)`, 'success');
            await updateInstructionDisplay();
        }
    } catch (error) {
        logConsole(`✗ Upload failed: ${error.message}`, 'error');
    }
}

function loadExample() {
    const exampleCode = `# Example: Fibonacci Sequence Calculator
# Calculates first 8 Fibonacci numbers

# Initialize variables
addi x1, x0, 0      # x1 = 0 (fib[0])
addi x2, x0, 1      # x2 = 1 (fib[1])
addi x3, x0, 2      # x3 = 2 (counter)
addi x4, x0, 8      # x4 = 8 (loop limit)

loop:
    add x5, x1, x2  # x5 = fib[n-2] + fib[n-1]
    mv x1, x2       # x1 = x2 (shift values)
    mv x2, x5       # x2 = x5 (new value)
    addi x3, x3, 1  # x3++ (increment counter)
    blt x3, x4, loop # if counter < 8, loop

# Store result marker
addi x10, x0, 255   # x10 = 0xFF (done)

# Infinite loop
end:
    jal x0, end
`;
    
    document.getElementById('codeEditor').value = exampleCode;
    logConsole('Example program loaded.', 'info');
}

// ===== CPU Control =====

async function handleRun() {
    try {
        await api.cpuStart();
        cpuRunning = true;
        updateCPUStatus(true);
        logConsole('CPU started.', 'success');
        
        // Start periodic updates
        if (updateInterval) clearInterval(updateInterval);
        updateInterval = setInterval(updateCPUState, 200);
    } catch (error) {
        logConsole(`Failed to start CPU: ${error.message}`, 'error');
    }
}

async function handleStop() {
    try {
        await api.cpuStop();
        cpuRunning = false;
        updateCPUStatus(false);
        logConsole('CPU stopped.', 'info');
        
        // Stop periodic updates
        if (updateInterval) {
            clearInterval(updateInterval);
            updateInterval = null;
        }
        
        // Final state update
        await updateCPUState();
    } catch (error) {
        logConsole(`Failed to stop CPU: ${error.message}`, 'error');
    }
}

async function handleReset() {
    try {
        await api.cpuReset();
        cpuRunning = false;
        currentPC = 0;
        updateCPUStatus(false);
        logConsole('CPU reset.', 'info');
        
        // Clear previous register values
        previousRegisters.fill(0);
        
        // Update displays
        await updateCPUState();
    } catch (error) {
        logConsole(`Failed to reset CPU: ${error.message}`, 'error');
    }
}

async function handleStep() {
    try {
        await api.cpuStep();
        logConsole('CPU stepped one instruction.', 'info');
        
        // Update displays
        await updateCPUState();
    } catch (error) {
        logConsole(`Failed to step CPU: ${error.message}`, 'error');
    }
}

// ===== Display Updates =====

async function updateCPUState() {
    try {
        // Get status
        const status = await api.getCPUStatus();
        
        if (status.success) {
            currentPC = status.pc;
            updatePCDisplay(status.pc);
            updateCurrentInstructionDisplay(status.current_instruction);
        }
        
        // Update registers
        await updateRegistersDisplay();
        
    } catch (error) {
        console.error('Error updating CPU state:', error);
    }
}

async function updateRegistersDisplay() {
    try {
        const response = await api.getRegisters();
        
        if (response.success) {
            const registers = response.registers;
            const container = document.getElementById('registerDisplay');
            container.innerHTML = '';
            
            for (let i = 0; i < 32; i++) {
                const regDiv = document.createElement('div');
                regDiv.className = 'register-item';
                
                // Highlight changed registers
                if (registers[i] !== previousRegisters[i] && i !== 0) {
                    regDiv.classList.add('changed');
                }
                
                const hex = '0x' + registers[i].toString(16).padStart(8, '0').toUpperCase();
                const dec = registers[i];
                
                regDiv.innerHTML = `
                    <span class="register-name">${registerNames[i]}</span>
                    <span class="register-value">${hex} (${dec})</span>
                `;
                
                container.appendChild(regDiv);
            }
            
            // Update previous values
            previousRegisters = [...registers];
        }
    } catch (error) {
        console.error('Error updating registers:', error);
    }
}

async function updateMemoryDisplay() {
    try {
        logConsole('Refreshing memory...', 'info');
        const response = await api.getDataMemory();
        
        if (response.success) {
            const memory = response.memory;
            const container = document.getElementById('memoryDisplay');
            container.innerHTML = '';
            
            for (let i = 0; i < memory.length; i++) {
                const memDiv = document.createElement('div');
                memDiv.className = 'memory-row';
                
                const addr = (i * 4).toString(16).padStart(4, '0').toUpperCase();
                const value = '0x' + memory[i].toString(16).padStart(8, '0').toUpperCase();
                
                memDiv.innerHTML = `
                    <span class="memory-addr">[${addr}]</span>
                    <span class="memory-value">${value}</span>
                `;
                
                container.appendChild(memDiv);
            }
            
            logConsole('Memory refreshed.', 'success');
        }
    } catch (error) {
        logConsole(`Failed to read memory: ${error.message}`, 'error');
    }
}

async function updateInstructionDisplay() {
    try {
        const response = await api.getInstructionMemory();
        
        if (response.success) {
            const memory = response.memory;
            const container = document.getElementById('instructionDisplay');
            container.innerHTML = '';
            
            for (let i = 0; i < memory.length; i++) {
                const instrDiv = document.createElement('div');
                instrDiv.className = 'instruction-item';
                
                // Highlight current instruction
                if (i * 4 === currentPC) {
                    instrDiv.classList.add('current');
                }
                
                const addr = (i * 4).toString(16).padStart(4, '0').toUpperCase();
                const hex = '0x' + memory[i].toString(16).padStart(8, '0').toUpperCase();
                const asm = disassemble(memory[i]);
                
                instrDiv.innerHTML = `
                    <span class="instruction-addr">[${addr}]</span>
                    <span class="instruction-hex">${hex}</span>
                    <span class="instruction-asm">${asm}</span>
                `;
                
                container.appendChild(instrDiv);
            }
        }
    } catch (error) {
        console.error('Error updating instructions:', error);
    }
}

// Simple disassembler (basic implementation)
function disassemble(instruction) {
    if (instruction === 0x00000013) return 'nop';
    if (instruction === 0x0000006F) return 'jal x0, 0';
    
    const opcode = instruction & 0x7F;
    
    // More complete disassembly would go here
    // For now, just show hex
    return '...';
}

function updatePCDisplay(pc) {
    document.getElementById('pcDisplay').textContent = `PC: 0x${pc.toString(16).padStart(8, '0').toUpperCase()}`;
}

function updateCurrentInstructionDisplay(instr) {
    document.getElementById('currentInstr').textContent = '0x' + instr.toString(16).padStart(8, '0').toUpperCase();
}

function updateCPUStatus(running) {
    const statusElem = document.getElementById('cpuStatus');
    statusElem.textContent = running ? 'CPU: Running' : 'CPU: Stopped';
    statusElem.className = running ? 'text-success' : 'text-warning';
}

// ===== Console =====

function logConsole(message, type = 'info') {
    const console = document.getElementById('console');
    const line = document.createElement('div');
    line.className = `console-line ${type}`;
    line.textContent = `[${new Date().toLocaleTimeString()}] ${message}`;
    console.appendChild(line);
    console.scrollTop = console.scrollHeight;
}

function clearConsole() {
    document.getElementById('console').innerHTML = '';
}

// ===== Connection Check =====

async function checkConnection() {
    try {
        await api.getCPUStatus();
        document.getElementById('connectionStatus').innerHTML = '<i class="fas fa-circle"></i> Connected';
        document.getElementById('connectionStatus').className = 'badge bg-success me-2';
    } catch (error) {
        document.getElementById('connectionStatus').innerHTML = '<i class="fas fa-circle"></i> Disconnected';
        document.getElementById('connectionStatus').className = 'badge bg-danger me-2';
        logConsole('Connection to FPGA failed. Check ESP32 connection.', 'error');
    }
}

// Periodic connection check
setInterval(checkConnection, 5000);

