# RISC-V 32I Instruction Reference

## Instruction Format Quick Reference

### R-Type Format
```
[31:25] [24:20] [19:15] [14:12] [11:7] [6:0]
funct7   rs2     rs1    funct3   rd    opcode
```

### I-Type Format
```
[31:20]        [19:15] [14:12] [11:7] [6:0]
imm[11:0]       rs1    funct3   rd    opcode
```

### S-Type Format
```
[31:25]      [24:20] [19:15] [14:12] [11:7]      [6:0]
imm[11:5]     rs2     rs1    funct3  imm[4:0]   opcode
```

### B-Type Format
```
[31:25]           [24:20] [19:15] [14:12] [11:7]            [6:0]
imm[12|10:5]      rs2     rs1    funct3  imm[4:1|11]      opcode
```

### U-Type Format
```
[31:12]              [11:7] [6:0]
imm[31:12]            rd    opcode
```

### J-Type Format
```
[31:12]                     [11:7] [6:0]
imm[20|10:1|11|19:12]        rd    opcode
```

## Implemented Instructions

### Arithmetic Operations

| Instruction | Format | Opcode | funct3 | funct7 | Operation |
|-------------|--------|--------|--------|--------|-----------|
| ADD rd, rs1, rs2 | R | 0110011 | 000 | 0000000 | rd = rs1 + rs2 |
| SUB rd, rs1, rs2 | R | 0110011 | 000 | 0100000 | rd = rs1 - rs2 |
| ADDI rd, rs1, imm | I | 0010011 | 000 | - | rd = rs1 + imm |

### Logical Operations

| Instruction | Format | Opcode | funct3 | funct7 | Operation |
|-------------|--------|--------|--------|--------|-----------|
| AND rd, rs1, rs2 | R | 0110011 | 111 | 0000000 | rd = rs1 & rs2 |
| OR rd, rs1, rs2 | R | 0110011 | 110 | 0000000 | rd = rs1 \| rs2 |
| XOR rd, rs1, rs2 | R | 0110011 | 100 | 0000000 | rd = rs1 ^ rs2 |
| ANDI rd, rs1, imm | I | 0010011 | 111 | - | rd = rs1 & imm |
| ORI rd, rs1, imm | I | 0010011 | 110 | - | rd = rs1 \| imm |
| XORI rd, rs1, imm | I | 0010011 | 100 | - | rd = rs1 ^ imm |

### Shift Operations

| Instruction | Format | Opcode | funct3 | funct7 | Operation |
|-------------|--------|--------|--------|--------|-----------|
| SLL rd, rs1, rs2 | R | 0110011 | 001 | 0000000 | rd = rs1 << rs2[4:0] |
| SRL rd, rs1, rs2 | R | 0110011 | 101 | 0000000 | rd = rs1 >> rs2[4:0] |
| SRA rd, rs1, rs2 | R | 0110011 | 101 | 0100000 | rd = rs1 >>> rs2[4:0] |
| SLLI rd, rs1, shamt | I | 0010011 | 001 | 0000000 | rd = rs1 << shamt |
| SRLI rd, rs1, shamt | I | 0010011 | 101 | 0000000 | rd = rs1 >> shamt |
| SRAI rd, rs1, shamt | I | 0010011 | 101 | 0100000 | rd = rs1 >>> shamt |

### Comparison Operations

| Instruction | Format | Opcode | funct3 | funct7 | Operation |
|-------------|--------|--------|--------|--------|-----------|
| SLT rd, rs1, rs2 | R | 0110011 | 010 | 0000000 | rd = (rs1 < rs2) ? 1 : 0 (signed) |
| SLTU rd, rs1, rs2 | R | 0110011 | 011 | 0000000 | rd = (rs1 < rs2) ? 1 : 0 (unsigned) |
| SLTI rd, rs1, imm | I | 0010011 | 010 | - | rd = (rs1 < imm) ? 1 : 0 (signed) |
| SLTIU rd, rs1, imm | I | 0010011 | 011 | - | rd = (rs1 < imm) ? 1 : 0 (unsigned) |

### Memory Operations

| Instruction | Format | Opcode | funct3 | Operation |
|-------------|--------|--------|--------|-----------|
| LW rd, offset(rs1) | I | 0000011 | 010 | rd = mem[rs1 + offset] |
| SW rs2, offset(rs1) | S | 0100011 | 010 | mem[rs1 + offset] = rs2 |

### Branch Operations

| Instruction | Format | Opcode | funct3 | Condition |
|-------------|--------|--------|--------|-----------|
| BEQ rs1, rs2, offset | B | 1100011 | 000 | if (rs1 == rs2) PC += offset |
| BNE rs1, rs2, offset | B | 1100011 | 001 | if (rs1 != rs2) PC += offset |
| BLT rs1, rs2, offset | B | 1100011 | 100 | if (rs1 < rs2) PC += offset (signed) |
| BGE rs1, rs2, offset | B | 1100011 | 101 | if (rs1 >= rs2) PC += offset (signed) |
| BLTU rs1, rs2, offset | B | 1100011 | 110 | if (rs1 < rs2) PC += offset (unsigned) |
| BGEU rs1, rs2, offset | B | 1100011 | 111 | if (rs1 >= rs2) PC += offset (unsigned) |

### Jump Operations

| Instruction | Format | Opcode | Operation |
|-------------|--------|--------|-----------|
| JAL rd, offset | J | 1101111 | rd = PC + 4; PC += offset |
| JALR rd, rs1, offset | I | 1100111 | rd = PC + 4; PC = (rs1 + offset) & ~1 |

### Upper Immediate Operations

| Instruction | Format | Opcode | Operation |
|-------------|--------|--------|-----------|
| LUI rd, imm | U | 0110111 | rd = imm << 12 |
| AUIPC rd, imm | U | 0010111 | rd = PC + (imm << 12) |

## Example Instruction Encodings

### ADDI x1, x0, 5
```
Encoding: 0x00500093
Binary: 0000_0000_0101_00000_000_00001_0010011
        [   imm=5   ][ rs1 ][fn3][ rd  ][opcode]
```

### ADD x3, x1, x2
```
Encoding: 0x002081b3
Binary: 0000000_00010_00001_000_00011_0110011
        [funct7][ rs2 ][ rs1 ][fn3][ rd  ][opcode]
```

### BEQ x20, x21, 8
```
Encoding: 0x015a0463
Binary: 0_000010_10101_10100_000_0100_0_1100011
        [imm[12|10:5]][rs2][rs1][fn3][imm[4:1|11]][opcode]
```

### JAL x1, 8
```
Encoding: 0x008000ef
Binary: 0_0000000100_0_00000000_00001_1101111
        [imm[20|10:1|11|19:12]][ rd  ][opcode]
```

## Register Convention (ABI Names)

| Register | ABI Name | Description | Saved by |
|----------|----------|-------------|----------|
| x0 | zero | Hard-wired zero | - |
| x1 | ra | Return address | Caller |
| x2 | sp | Stack pointer | Callee |
| x3 | gp | Global pointer | - |
| x4 | tp | Thread pointer | - |
| x5-x7 | t0-t2 | Temporary registers | Caller |
| x8 | s0/fp | Saved register / Frame pointer | Callee |
| x9 | s1 | Saved register | Callee |
| x10-x11 | a0-a1 | Function args / return values | Caller |
| x12-x17 | a2-a7 | Function arguments | Caller |
| x18-x27 | s2-s11 | Saved registers | Callee |
| x28-x31 | t3-t6 | Temporary registers | Caller |

## Immediate Encoding Notes

### I-Type Immediate (12 bits)
- Sign-extended to 32 bits
- Range: -2048 to 2047

### S-Type Immediate (12 bits)
- Split: [31:25] and [11:7]
- Sign-extended to 32 bits
- Range: -2048 to 2047

### B-Type Immediate (13 bits)
- Encodes multiples of 2 (implicit 0 in bit 0)
- Sign-extended to 32 bits
- Range: -4096 to 4094 (even numbers only)

### U-Type Immediate (20 bits)
- Placed in upper 20 bits [31:12]
- Lower 12 bits are zeros
- Can represent any 32-bit value when combined with I-type

### J-Type Immediate (21 bits)
- Encodes multiples of 2 (implicit 0 in bit 0)
- Sign-extended to 32 bits
- Range: -1,048,576 to 1,048,574 (even numbers only)

## Control Signal Summary

| Signal | Active When | Purpose |
|--------|-------------|---------|
| RegWrite | 1 | Enable write to register file |
| MemRead | 1 | Enable read from data memory |
| MemWrite | 1 | Enable write to data memory |
| MemToReg | 1 | Select memory data for write-back |
| ALUSrc | 1 | Select immediate as ALU input (vs rs2) |
| Branch | 1 | Instruction is a branch |
| Jump | 1 | Instruction is JAL or JALR |
| JALRSel | 1 | Instruction is JALR (vs JAL) |
| LUISel | 1 | Select immediate for LUI write-back |
| AUIPCSel | 1 | Select PC+imm for AUIPC write-back |

## ALU Control Codes

| ALUOp | Binary | Operation |
|-------|--------|-----------|
| 0 | 0000 | ADD |
| 1 | 0001 | SUB |
| 2 | 0010 | AND |
| 3 | 0011 | OR |
| 4 | 0100 | XOR |
| 5 | 0101 | SLT |
| 6 | 0110 | SLTU |
| 7 | 0111 | SLL |
| 8 | 1000 | SRL |
| 9 | 1001 | SRA |
| 10 | 1010 | BLT (comparison) |
| 11 | 1011 | BGE (comparison) |
| 12 | 1100 | BLTU (comparison) |
| 13 | 1101 | BGEU (comparison) |

