// API Communication Layer
// Handles all communication with ESP32 backend

class CPUAPI {
    constructor(baseUrl = '') {
        this.baseUrl = baseUrl;
    }
    
    // CPU Control
    async cpuStart() {
        return await this.post('/api/cpu/start');
    }
    
    async cpuStop() {
        return await this.post('/api/cpu/stop');
    }
    
    async cpuReset() {
        return await this.post('/api/cpu/reset');
    }
    
    async cpuStep() {
        return await this.post('/api/cpu/step');
    }
    
    async getCPUStatus() {
        return await this.get('/api/cpu/status');
    }
    
    // Register Operations
    async getRegisters() {
        return await this.get('/api/registers');
    }
    
    async getRegister(num) {
        return await this.get(`/api/registers/${num}`);
    }
    
    // Memory Operations
    async getInstructionMemory() {
        return await this.get('/api/memory/instruction');
    }
    
    async getDataMemory() {
        return await this.get('/api/memory/data');
    }
    
    async getPC() {
        return await this.get('/api/pc');
    }
    
    async getCurrentInstruction() {
        return await this.get('/api/instruction');
    }
    
    // Program Upload
    async uploadProgram(machineCode) {
        // Convert array of 32-bit integers to binary data
        const buffer = new ArrayBuffer(machineCode.length * 4);
        const view = new DataView(buffer);
        
        for (let i = 0; i < machineCode.length; i++) {
            view.setUint32(i * 4, machineCode[i], true); // little-endian
        }
        
        return await this.postBinary('/api/program/upload', buffer);
    }
    
    // HTTP Methods
    async get(endpoint) {
        try {
            const response = await fetch(this.baseUrl + endpoint);
            const data = await response.json();
            
            if (!response.ok) {
                throw new Error(data.error || 'Request failed');
            }
            
            return data;
        } catch (error) {
            console.error('API GET Error:', error);
            throw error;
        }
    }
    
    async post(endpoint, data = {}) {
        try {
            const response = await fetch(this.baseUrl + endpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
            });
            
            const responseData = await response.json();
            
            if (!response.ok) {
                throw new Error(responseData.error || 'Request failed');
            }
            
            return responseData;
        } catch (error) {
            console.error('API POST Error:', error);
            throw error;
        }
    }
    
    async postBinary(endpoint, buffer) {
        try {
            const response = await fetch(this.baseUrl + endpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/octet-stream',
                },
                body: buffer
            });
            
            const data = await response.json();
            
            if (!response.ok) {
                throw new Error(data.error || 'Request failed');
            }
            
            return data;
        } catch (error) {
            console.error('API Binary POST Error:', error);
            throw error;
        }
    }
}

