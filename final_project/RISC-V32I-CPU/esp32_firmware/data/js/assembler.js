// RISC-V32I Assembler - Converts assembly code to machine code

class RISCVAssembler {
    constructor() {
        this.labels = {};
        this.instructions = [];
        this.errors = [];
        this.machineCode = [];
        
        // Register name mapping
        this.registers = {
            'zero': 0, 'x0': 0,
            'ra': 1, 'x1': 1,
            'sp': 2, 'x2': 2,
            'gp': 3, 'x3': 3,
            'tp': 4, 'x4': 4,
            't0': 5, 'x5': 5,
            't1': 6, 'x6': 6,
            't2': 7, 'x7': 7,
            's0': 8, 'fp': 8, 'x8': 8,
            's1': 9, 'x9': 9,
            'a0': 10, 'x10': 10,
            'a1': 11, 'x11': 11,
            'a2': 12, 'x12': 12,
            'a3': 13, 'x13': 13,
            'a4': 14, 'x14': 14,
            'a5': 15, 'x15': 15,
            'a6': 16, 'x16': 16,
            'a7': 17, 'x17': 17,
            's2': 18, 'x18': 18,
            's3': 19, 'x19': 19,
            's4': 20, 'x20': 20,
            's5': 21, 'x21': 21,
            's6': 22, 'x22': 22,
            's7': 23, 'x23': 23,
            's8': 24, 'x24': 24,
            's9': 25, 'x25': 25,
            's10': 26, 'x26': 26,
            's11': 27, 'x27': 27,
            't3': 28, 'x28': 28,
            't4': 29, 'x29': 29,
            't5': 30, 'x30': 30,
            't6': 31, 'x31': 31
        };
    }
    
    assemble(sourceCode) {
        this.labels = {};
        this.instructions = [];
        this.errors = [];
        this.machineCode = [];
        
        // Parse source code
        const lines = sourceCode.split('\n');
        let address = 0;
        
        // First pass: collect labels
        for (let i = 0; i < lines.length; i++) {
            const line = this.preprocessLine(lines[i]);
            if (line === '') continue;
            
            // Check for label
            const labelMatch = line.match(/^(\w+):/);
            if (labelMatch) {
                this.labels[labelMatch[1]] = address;
                const remaining = line.substring(labelMatch[0].length).trim();
                if (remaining) {
                    this.instructions.push({ line: i + 1, address, text: remaining });
                    address += 4;
                }
            } else {
                this.instructions.push({ line: i + 1, address, text: line });
                address += 4;
            }
        }
        
        // Second pass: generate machine code
        for (const instr of this.instructions) {
            try {
                const machineInstr = this.encodeInstruction(instr.text, instr.address);
                this.machineCode.push(machineInstr);
            } catch (error) {
                this.errors.push(`Line ${instr.line}: ${error.message}`);
                this.machineCode.push(0x00000013); // NOP on error
            }
        }
        
        return {
            success: this.errors.length === 0,
            machineCode: this.machineCode,
            errors: this.errors
        };
    }
    
    preprocessLine(line) {
        // Remove comments
        const commentIndex = line.indexOf('#');
        if (commentIndex !== -1) {
            line = line.substring(0, commentIndex);
        }
        return line.trim();
    }
    
    encodeInstruction(text, address) {
        const parts = text.split(/[\s,()]+/).filter(p => p);
        if (parts.length === 0) {
            throw new Error('Empty instruction');
        }
        
        const opcode = parts[0].toLowerCase();
        
        // R-Type Instructions
        if (['add', 'sub', 'and', 'or', 'xor', 'sll', 'srl', 'sra', 'slt', 'sltu'].includes(opcode)) {
            return this.encodeRType(opcode, parts);
        }
        
        // I-Type Instructions
        if (['addi', 'andi', 'ori', 'xori', 'slti', 'sltiu', 'slli', 'srli', 'srai', 'lw', 'jalr'].includes(opcode)) {
            return this.encodeIType(opcode, parts);
        }
        
        // S-Type Instructions
        if (['sw'].includes(opcode)) {
            return this.encodeSType(opcode, parts);
        }
        
        // B-Type Instructions
        if (['beq', 'bne', 'blt', 'bge', 'bltu', 'bgeu'].includes(opcode)) {
            return this.encodeBType(opcode, parts, address);
        }
        
        // U-Type Instructions
        if (['lui', 'auipc'].includes(opcode)) {
            return this.encodeUType(opcode, parts);
        }
        
        // J-Type Instructions
        if (['jal'].includes(opcode)) {
            return this.encodeJType(opcode, parts, address);
        }
        
        // Pseudo-instructions
        if (['nop', 'li', 'mv', 'j', 'ret'].includes(opcode)) {
            return this.encodePseudo(opcode, parts, address);
        }
        
        throw new Error(`Unknown instruction: ${opcode}`);
    }
    
    encodeRType(opcode, parts) {
        if (parts.length !== 4) {
            throw new Error(`${opcode} requires 3 operands`);
        }
        
        const rd = this.parseRegister(parts[1]);
        const rs1 = this.parseRegister(parts[2]);
        const rs2 = this.parseRegister(parts[3]);
        
        let funct7 = 0x00;
        let funct3 = 0x0;
        
        switch (opcode) {
            case 'add': funct7 = 0x00; funct3 = 0x0; break;
            case 'sub': funct7 = 0x20; funct3 = 0x0; break;
            case 'and': funct7 = 0x00; funct3 = 0x7; break;
            case 'or':  funct7 = 0x00; funct3 = 0x6; break;
            case 'xor': funct7 = 0x00; funct3 = 0x4; break;
            case 'sll': funct7 = 0x00; funct3 = 0x1; break;
            case 'srl': funct7 = 0x00; funct3 = 0x5; break;
            case 'sra': funct7 = 0x20; funct3 = 0x5; break;
            case 'slt': funct7 = 0x00; funct3 = 0x2; break;
            case 'sltu': funct7 = 0x00; funct3 = 0x3; break;
        }
        
        return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | 0x33;
    }
    
    encodeIType(opcode, parts) {
        let rd, rs1, imm, funct3, opcodeVal;
        
        if (opcode === 'lw') {
            // lw rd, offset(rs1)
            if (parts.length !== 3) throw new Error(`${opcode} requires format: rd, offset(rs1)`);
            rd = this.parseRegister(parts[1]);
            imm = this.parseImmediate(parts[2]);
            rs1 = this.parseRegister(parts[3]);
            funct3 = 0x2;
            opcodeVal = 0x03;
        } else if (opcode === 'jalr') {
            // jalr rd, rs1, offset or jalr rd, offset(rs1)
            if (parts.length === 4 && parts[3].match(/^\d/)) {
                rd = this.parseRegister(parts[1]);
                rs1 = this.parseRegister(parts[2]);
                imm = this.parseImmediate(parts[3]);
            } else if (parts.length === 3) {
                rd = this.parseRegister(parts[1]);
                imm = this.parseImmediate(parts[2]);
                rs1 = this.parseRegister(parts[3]);
            } else {
                throw new Error(`${opcode} requires format: rd, rs1, offset`);
            }
            funct3 = 0x0;
            opcodeVal = 0x67;
        } else {
            // Normal I-type: op rd, rs1, imm
            if (parts.length !== 4) throw new Error(`${opcode} requires 3 operands`);
            rd = this.parseRegister(parts[1]);
            rs1 = this.parseRegister(parts[2]);
            imm = this.parseImmediate(parts[3]);
            opcodeVal = 0x13;
            
            switch (opcode) {
                case 'addi': funct3 = 0x0; break;
                case 'andi': funct3 = 0x7; break;
                case 'ori': funct3 = 0x6; break;
                case 'xori': funct3 = 0x4; break;
                case 'slti': funct3 = 0x2; break;
                case 'sltiu': funct3 = 0x3; break;
                case 'slli': funct3 = 0x1; imm = imm & 0x1F; break;
                case 'srli': funct3 = 0x5; imm = imm & 0x1F; break;
                case 'srai': funct3 = 0x5; imm = (imm & 0x1F) | 0x400; break;
            }
        }
        
        imm = imm & 0xFFF;  // 12-bit immediate
        return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcodeVal;
    }
    
    encodeSType(opcode, parts) {
        // sw rs2, offset(rs1)
        if (parts.length !== 3) throw new Error(`${opcode} requires format: rs2, offset(rs1)`);
        
        const rs2 = this.parseRegister(parts[1]);
        const imm = this.parseImmediate(parts[2]);
        const rs1 = this.parseRegister(parts[3]);
        
        const imm11_5 = (imm >> 5) & 0x7F;
        const imm4_0 = imm & 0x1F;
        
        return (imm11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (0x2 << 12) | (imm4_0 << 7) | 0x23;
    }
    
    encodeBType(opcode, parts, address) {
        if (parts.length !== 4) throw new Error(`${opcode} requires 3 operands`);
        
        const rs1 = this.parseRegister(parts[1]);
        const rs2 = this.parseRegister(parts[2]);
        
        let offset;
        if (parts[3] in this.labels) {
            offset = this.labels[parts[3]] - address;
        } else {
            offset = this.parseImmediate(parts[3]);
        }
        
        let funct3;
        switch (opcode) {
            case 'beq': funct3 = 0x0; break;
            case 'bne': funct3 = 0x1; break;
            case 'blt': funct3 = 0x4; break;
            case 'bge': funct3 = 0x5; break;
            case 'bltu': funct3 = 0x6; break;
            case 'bgeu': funct3 = 0x7; break;
        }
        
        const imm12 = (offset >> 12) & 0x1;
        const imm10_5 = (offset >> 5) & 0x3F;
        const imm4_1 = (offset >> 1) & 0xF;
        const imm11 = (offset >> 11) & 0x1;
        
        return (imm12 << 31) | (imm10_5 << 25) | (rs2 << 20) | (rs1 << 15) | 
               (funct3 << 12) | (imm4_1 << 8) | (imm11 << 7) | 0x63;
    }
    
    encodeUType(opcode, parts) {
        if (parts.length !== 3) throw new Error(`${opcode} requires 2 operands`);
        
        const rd = this.parseRegister(parts[1]);
        const imm = this.parseImmediate(parts[2]) & 0xFFFFF;
        
        const opcodeVal = (opcode === 'lui') ? 0x37 : 0x17;
        return (imm << 12) | (rd << 7) | opcodeVal;
    }
    
    encodeJType(opcode, parts, address) {
        if (parts.length !== 3) throw new Error(`${opcode} requires 2 operands`);
        
        const rd = this.parseRegister(parts[1]);
        
        let offset;
        if (parts[2] in this.labels) {
            offset = this.labels[parts[2]] - address;
        } else {
            offset = this.parseImmediate(parts[2]);
        }
        
        const imm20 = (offset >> 20) & 0x1;
        const imm10_1 = (offset >> 1) & 0x3FF;
        const imm11 = (offset >> 11) & 0x1;
        const imm19_12 = (offset >> 12) & 0xFF;
        
        return (imm20 << 31) | (imm19_12 << 12) | (imm11 << 20) | (imm10_1 << 21) | (rd << 7) | 0x6F;
    }
    
    encodePseudo(opcode, parts, address) {
        switch (opcode) {
            case 'nop':
                return 0x00000013; // addi x0, x0, 0
            
            case 'li': // li rd, imm -> addi rd, x0, imm
                if (parts.length !== 3) throw new Error('li requires 2 operands');
                return this.encodeIType('addi', ['addi', parts[1], 'x0', parts[2]]);
            
            case 'mv': // mv rd, rs -> addi rd, rs, 0
                if (parts.length !== 3) throw new Error('mv requires 2 operands');
                return this.encodeIType('addi', ['addi', parts[1], parts[2], '0']);
            
            case 'j': // j offset -> jal x0, offset
                if (parts.length !== 2) throw new Error('j requires 1 operand');
                return this.encodeJType('jal', ['jal', 'x0', parts[1]], address);
            
            case 'ret': // ret -> jalr x0, x1, 0
                return this.encodeIType('jalr', ['jalr', 'x0', 'x1', '0']);
            
            default:
                throw new Error(`Unknown pseudo-instruction: ${opcode}`);
        }
    }
    
    parseRegister(reg) {
        reg = reg.toLowerCase().trim();
        if (reg in this.registers) {
            return this.registers[reg];
        }
        throw new Error(`Invalid register: ${reg}`);
    }
    
    parseImmediate(imm) {
        imm = imm.trim();
        
        // Hexadecimal
        if (imm.startsWith('0x')) {
            return parseInt(imm, 16);
        }
        
        // Binary
        if (imm.startsWith('0b')) {
            return parseInt(imm.substring(2), 2);
        }
        
        // Decimal
        const num = parseInt(imm, 10);
        if (isNaN(num)) {
            throw new Error(`Invalid immediate value: ${imm}`);
        }
        return num;
    }
}

