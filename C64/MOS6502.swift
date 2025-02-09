//
//  6502.swift
//  C64 Emulator
//
//  Created by Holger Becker on 28.01.25.
//

import Foundation

typealias Byte = UInt8
typealias Word = UInt16

class MOS6502 {
    var c64: C64!
    
    var PC: Word        //Program counter
    
    var SP: Byte         //Stack Pointer
    
    var OP: Word        //Operand Pointer
    var OPZP: Byte       //Operand Zeropage Pointer
    
    var A, X, Y: Byte   //registers
    
    // Status flags
    var C: Bool
    var Z: Bool
    var I: Bool
    var D: Bool
    var B: Bool
    var V: Bool
    var N: Bool
    
    var INT = false
    var NMI = false
    
    var addressBus = 0
    
    var write = false
    
    private var TC = false // buffer for a binary
    
    var cycles = 0
    
    var timerMos6502: Timer?
    
    init() {
        print("MOS6502")
        PC = 0xFFFC
        SP = 0xFF
        OP = 0x00
        OPZP = 0x00
        A = 0; X = 0; Y = 0;
        C = false; Z = false; I = false; D = false; B = false; V = false; N = false;
    }
        
    func reset() {
        print("6502 Reset")
        PC = 0xFFFC
        SP = 0xFF
        
        C = false; Z = false; I = false; D = false; B = false; V = false; N = false;
        
        c64.memory[0x00] = 0xEF
        c64.memory[0x01] = 0x37
 
        PC = fetchAddressAbsolutePC() // load reset vector
    
        cycles = 0
    }
    
    func NMIhandler() {
        
    }
    
    func INThandler() {
        if I { return }
        c64.memory[Int(SP) + 0x100] = Byte(PC>>8 & 0xFF)
        SP -= 1
        c64.memory[Int(SP) + 0x100] = Byte(PC & 0xFF)
        SP -= 1
        c64.memory[Int(SP) + 0x100] = PStoByte()
        SP -= 1
        I = true
        INT = false
        PC = fetchAddressAbsolute(address: 0xFFFE)
    }
    
    private func PStoByte()->Byte {
        var ps: Byte = 0x00
        if (N) { ps |= 1 << 7 }
        if (V) { ps |= 1 << 6 }
        if (B) { ps |= 1 << 4 }
        if (D) { ps |= 1 << 3 }
        if (I) { ps |= 1 << 2 }
        if (Z) { ps |= 1 << 1 }
        if (C) { ps |= 1 << 0 }
        return ps
    }
    
    private func ByteToPS(ps: Byte) {
        N = ps & (1 << 7) != 0
        V = ps & (1 << 6) != 0
        B = ps & (1 << 4) != 0
        D = ps & (1 << 3) != 0
        I = ps & (1 << 2) != 0
        Z = ps & (1 << 1) != 0
        C = ps & (1 << 0) != 0
    }
    
    var stop = 0
    @objc func execute() {        
        if INT { INThandler() }
        
        if D == true
        {
            stop += 1
        }
        let instruction = fetchByteImmediatePC() // one cycle
        switch instruction {
            // MARK: - Control Operations
        case HALT:
            cycles -= 1
            return
        case BRK:
            PC += 2
            c64.memory[Int(SP) + 0x100] = Byte(PC>>8 & 0xFF)
            SP -= 1
            c64.memory[Int(SP) + 0x100] = Byte(PC & 0xFF)
            SP -= 1
            B = true
            I = true
            c64.memory[Int(SP) + 0x100] = PStoByte()
            SP -= 1
            PC = fetchAddressAbsolute(address: 0xFFFE)
        case JMP_AB:
            PC = fetchAddressAbsolutePC()
        case JMP_ABI:
            PC = fetchAddressAbsolutePCIndirect()
        case JSR_AB:
            c64.memory[Int(SP) + 0x100] = Byte(((PC + 2)>>8) & 0xFF)
            SP -= 1
            c64.memory[Int(SP) + 0x100] = Byte((PC + 2) & 0xFF)
            SP -= 1
            PC = fetchAddressAbsolutePC()
            cycles += 3
        case RTI:
            SP += 1
            ByteToPS(ps: c64.memory[Int(SP) + 0x100])
            SP += 1
            let lowByte = Word(c64.memory[Int(SP) + 0x100])
            SP += 1
            let highByte = Word(c64.memory[Int(SP) + 0x100])<<8
            PC = highByte | lowByte
            I = false
            cycles += 5
        case RTS:
            SP += 1
            let lowByte = Word(c64.memory[Int(SP) + 0x100])
            SP += 1
            let highByte = Word(c64.memory[Int(SP) + 0x100])<<8
            PC = highByte | lowByte
            cycles += 5
        case NOP:
            cycles += 1
            
            // MARK: - Flag Operations
        case CLC:
            C = false
        case CLD:
            D = false
        case CLI:
            I = false
        case CLV:
            V = false
        case SEC:
            C = true
        case SED:
            D = true
        case SEI:
            I = true
            
            
            // MARK: - Branch Operations
        case BCC:
            branch(cond: !C)
        case BCS:
            branch(cond: C)
        case BEQ:
            branch(cond: Z)
        case BMI:
            branch(cond: N)
        case BNE:
            branch(cond: !Z)
        case BPL:
            branch(cond: !N)
        case BVC:
            branch(cond: !V)
        case BVS:
            branch(cond: V)
            
            // MARK: - Load Operations
        case LDA_IM:
            A = fetchByteImmediatePC()
            Z = A == 0
            N = A & 0b10000000 > 0
        case LDA_AB:
            A = fetchByteAbsolutePC()
            Z = A == 0
            N = A & 0b10000000 > 0
        case LDA_XAB:
            A = fetchByteAbsolutePCindexedX()
            Z = A == 0
            N = A & 0b10000000 > 0
        case LDA_YAB:
            A = fetchByteAbsolutePCindexedY()
            Z = A == 0
            N = A & 0b10000000 > 0
        case LDA_ZP:
            A = fetchByteZeropage()
            Z = A == 0
            N = A & 0b10000000 > 0
        case LDA_XZP:
            A = fetchByteXindexedZeropage()
            Z = A == 0
            N = A & 0b10000000 > 0
        case LDA_XZPI:
            A = fetchByteXindexedZeropageIndirect()
            Z = A == 0
            N = A & 0b10000000 > 0
        case LDA_ZPYI:
            A = fetchByteZeropageIndirectYindexed()
            Z = A == 0
            N = A & 0b10000000 > 0
        case LDX_IM:
            X = fetchByteImmediatePC()
            Z = X == 0
            N = X & 0b10000000 > 0
        case LDX_AB:
            X = fetchByteAbsolutePC()
            Z = X == 0
            N = X & 0b10000000 > 0
        case LDX_YAB:
            X = fetchByteAbsolutePCindexedY()
            Z = X == 0
            N = X & 0b10000000 > 0
        case LDX_ZP:
            X = fetchByteZeropage()
            Z = X == 0
            N = X & 0b10000000 > 0
        case LDX_YZP:
            X = fetchByteYindexedZeropage()
            Z = X == 0
            N = X & 0b10000000 > 0
            
        case LDY_IM:
            Y = fetchByteImmediatePC()
            Z = Y == 0
            N = Y & 0b10000000 > 0
        case LDY_AB:
            Y = fetchByteAbsolutePC()
            Z = Y == 0
            N = Y & 0b10000000 > 0
        case LDY_XAB:
            Y = fetchByteAbsolutePCindexedX()
            Z = Y == 0
            N = Y & 0b10000000 > 0
        case LDY_ZP:
            Y = fetchByteZeropage()
            Z = Y == 0
            N = Y & 0b10000000 > 0
        case LDY_XZP:
            Y = fetchByteXindexedZeropage()
            Z = Y == 0
            N = Y & 0b10000000 > 0
            
            // MARK: - Store Operations
        case STA_AB:
            StoreByteAbsolutePC(byte: A)
        case STA_XAB:
            StoreByteAbsolutePCIndexedX(byte: A)
        case STA_YAB:
            StoreByteAbsolutePCIndexedY(byte: A)
        case STA_ZP:
            StoreByteZeropage(byte: A)
        case STA_XZP:
            StoreByteXindexedZeropage(byte: A)
        case STA_XZPI:
            StoreByteXindexedZeropageIndirect(byte: A)
        case STA_ZPYI:
            storeByteZeropageIndirectYindexed(byte: A)
        case STX_AB:
            StoreByteAbsolutePC(byte: X)
        case STX_ZP:
            StoreByteZeropage(byte: X)
        case STX_YZP:
            StoreByteYindexedZeropage(byte: X)
        case STY_AB:
            StoreByteAbsolutePC(byte: Y)
        case STY_ZP:
            StoreByteZeropage(byte: Y)
        case STY_XZP:
            StoreByteXindexedZeropage(byte: Y)
            
            //MARK: - Transfer Operations
        case TAX:
            X = A
            Z = X == 0
            N = X & 0b10000000 > 0
            cycles += 1
        case TAY:
            Y = A
            Z = Y == 0
            N = Y & 0b10000000 > 0
            cycles += 1
        case TSX:
            X = SP
            Z = X == 0
            N = X & 0b10000000 > 0
            cycles += 1
        case TXA:
            A = X
            Z = A == 0
            N = A & 0b10000000 > 0
            cycles += 1
        case TXS:
            SP = X
            Z = SP == 0
            N = SP & 0b10000000 > 0
            cycles += 1
        case TYA:
            A = Y
            Z = A == 0
            N = A & 0b10000000 > 0
            cycles += 1
            
            //MARK: - Stack Operations
        case PHA:
            c64.memory[Int(SP) + 0x100] = A
            SP -= 1
            cycles += 2
        case PHP:
            c64.memory[Int(SP) + 0x100] = PStoByte()
            SP -= 1
            cycles += 2
        case PLA:
            SP += 1
            A = c64.memory[Int(SP) + 0x100]
            Z = A == 0
            N = A & 0b10000000 > 0
            cycles += 3
        case PLP:
            SP += 1
            ByteToPS(ps: c64.memory[Int(SP) + 0x100])
            cycles += 3
            
            //MARK: - Shift Operations
        case ASL_A:
            let a: Word = Word(A) << 1
            C = a & 0b100000000 > 0
            A = A << 1
            Z = A == 0
            N = A & 0b10000000 > 0
            cycles += 1
        case ASL_AB:
            var op = fetchByteAbsolutePC()
            let a: Word = Word(op) << 1
            C = a & 0b100000000 > 0
            op = op << 1
            Z = op == 0
            N = op & 0b10000000 > 0
            writeByteToMemory(address: (OP), byte: op)
            cycles += 2
        case ASL_XAB:
            var op = fetchByteAbsolutePCindexedX()
            let a: Word = Word(op) << 1
            C = a & 0b100000000 > 0
            op = op << 1
            Z = op == 0
            N = op & 0b10000000 > 0
            writeByteToMemory(address: (OP), byte: op)
            cycles += 3
        case ASL_ZP:
            var op = fetchByteZeropage()
            let a: Word = Word(op) << 1
            C = a & 0b100000000 > 0
            op = op << 1
            Z = op == 0
            N = op & 0b10000000 > 0
            c64.memory[Int(OPZP)] = op
            cycles += 2
        case ASL_XZP:
            var op = fetchByteXindexedZeropage()
            let a: Word = Word(op) << 1
            C = a & 0b100000000 > 0
            op = op << 1
            Z = op == 0
            N = op & 0b10000000 > 0
            c64.memory[Int(OPZP)] = op
            cycles += 2
        case LSR_A:
            C = A & 0b00000001 > 0
            A = A >> 1
            Z = A == 0
            N = false
            cycles += 1
        case LSR_AB:
            var op = fetchByteAbsolutePC()
            C = op & 0b00000001 > 0
            op = op >> 1
            Z = op == 0
            N = false
            writeByteToMemory(address: OP, byte: op)
            cycles += 2
        case LSR_XAB:
            var op = fetchByteAbsolutePCindexedX()
            C = op & 0b00000001 > 0
            op = op >> 1
            Z = op == 0
            N = false
            writeByteToMemory(address: OP, byte: op)
            cycles += 3
        case LSR_ZP:
            var op = fetchByteZeropage()
            C = op & 0b00000001 > 0
            op = op >> 1
            Z = op == 0
            N = false
            c64.memory[Int(OPZP)] = op
            cycles += 2
        case LSR_XZP:
            var op = fetchByteXindexedZeropage()
            C = op & 0b00000001 > 0
            op = op >> 1
            Z = op == 0
            N = false
            c64.memory[Int(OPZP)] = op
            cycles += 2
            
        case ROL_A:
            TC = A & 0b10000000 > 0
            A = A << 1
            if C { A = A | 0b00000001}
            C = TC
            Z = A == 0
            N = A & 0b10000000 > 0
            cycles += 1
        case ROL_AB:
            var op = fetchByteAbsolutePC()
            TC = op & 0b10000000 > 0
            op = op << 1
            if C { op = op | 0x00000001}
            C = TC
            Z = op == 0
            N = op & 0b10000000 > 0
            writeByteToMemory(address: OP, byte: op)
            cycles += 2
        case ROL_XAB:
            var op = fetchByteAbsolutePCindexedX()
            TC = op & 0b10000000 > 0
            op = op << 1
            if C { op = op | 0x00000001}
            C = TC
            Z = op == 0
            N = op & 0b10000000 > 0
            writeByteToMemory(address: OP, byte: op)
            cycles += 3
        case ROL_ZP:
            var op = fetchByteZeropage()
            TC = op & 0b10000000 > 0
            op = op << 1
            if C { op = op | 0x00000001}
            C = TC
            Z = op == 0
            N = op & 0b10000000 > 0
            c64.memory[Int(OPZP)] = op
            cycles += 2
        case ROL_XZP:
            var op = fetchByteXindexedZeropage()
            TC = op & 0b10000000 > 0
            op = op << 1
            if C { op = op | 0x00000001}
            C = TC
            Z = op == 0
            N = op & 0b10000000 > 0
            c64.memory[Int(OPZP)] = op
            cycles += 2
            
        case ROR_A:
            TC = A & 0b00000001 > 0
            A = A >> 1
            if C { A = A | 0b10000000}
            C = TC
            Z = A == 0
            N = A & 0b10000000 > 0
            cycles += 1
        case ROR_AB:
            var op = fetchByteAbsolutePC()
            TC = op & 0b00000001 > 0
            op = op >> 1
            if C { op = op | 0b10000000}
            C = TC
            Z = op == 0
            N = op & 0b10000000 > 0
            writeByteToMemory(address: OP, byte: op)
            cycles += 2
        case ROR_XAB:
            var op = fetchByteAbsolutePCindexedX()
            TC = op & 0b00000001 > 0
            op = op >> 1
            if C { op = op | 0b10000000}
            C = TC
            Z = op == 0
            N = op & 0b10000000 > 0
            writeByteToMemory(address: OP, byte: op)
            cycles += 3
        case ROR_ZP:
            var op = fetchByteZeropage()
            TC = op & 0b00000001 > 0
            op = op >> 1
            if C { op = op | 0b10000000}
            C = TC
            Z = op == 0
            N = op & 0b10000000 > 0
            c64.memory[Int(OPZP)] = op
            cycles += 2
        case ROR_XZP:
            var op = fetchByteXindexedZeropage()
            TC = op & 0b00000001 > 0
            op = op >> 1
            if C { op = op | 0b10000000}
            C = TC
            Z = op == 0
            N = op & 0b10000000 > 0
            c64.memory[Int(OPZP)] = op
            cycles += 2
            
            //MARK: - Logical Operations
        case AND_IM:
            let op = fetchByteImmediatePC()
            A = A & op
            Z = A == 0
            N = A & 0b10000000 > 0
        case AND_AB:
            let op = fetchByteAbsolutePC()
            A = A & op
            Z = A == 0
            N = A & 0b10000000 > 0
        case AND_XAB:
            let op = fetchByteAbsolutePCindexedX()
            A = A & op
            Z = A == 0
            N = A & 0b10000000 > 0
        case AND_YAB:
            let op = fetchByteAbsolutePCindexedY()
            A = A & op
            Z = A == 0
            N = A & 0b10000000 > 0
        case AND_ZP:
            let op = fetchByteZeropage()
            A = A & op
            Z = A == 0
            N = A & 0b10000000 > 0
        case AND_XZP:
            let op = fetchByteXindexedZeropage()
            A = A & op
            Z = A == 0
            N = A & 0b10000000 > 0
        case AND_XZPI:
            let op = fetchByteXindexedZeropageIndirect()
            A = A & op
            Z = A == 0
            N = A & 0b10000000 > 0
        case AND_ZPYI:
            let op = fetchByteZeropageIndirectYindexed()
            A = A & op
            Z = A == 0
            N = A & 0b10000000 > 0
            
        case BIT_AB:
            let op = fetchByteAbsolutePC()
            N = op & 0b10000000 > 0
            V = op & 0b01000000 > 0
            A = A & op
            Z = A == 0
        case BIT_ZP:
            let op = fetchByteZeropage()
            N = op & 0b10000000 > 0
            V = op & 0b01000000 > 0
            A = A & op
            Z = A == 0
            
        case EOR_IM:
            let op = fetchByteImmediatePC()
            A = A ^ op
            Z = A == 0
            N = A & 0b10000000 > 0
        case EOR_AB:
            let op = fetchByteAbsolutePC()
            A = A ^ op
            Z = A == 0
            N = A & 0b10000000 > 0
        case EOR_XAB:
            let op = fetchByteAbsolutePCindexedX()
            A = A ^ op
            Z = A == 0
            N = A & 0b10000000 > 0
        case EOR_YAB:
            let op = fetchByteAbsolutePCindexedY()
            A = A ^ op
            Z = A == 0
            N = A & 0b10000000 > 0
        case EOR_ZP:
            let op = fetchByteZeropage()
            A = A ^ op
            Z = A == 0
            N = A & 0b10000000 > 0
        case EOR_XZP:
            let op = fetchByteXindexedZeropage()
            A = A ^ op
            Z = A == 0
            N = A & 0b10000000 > 0
        case EOR_XZPI:
            let op = fetchByteXindexedZeropageIndirect()
            A = A ^ op
            Z = A == 0
            N = A & 0b10000000 > 0
        case EOR_ZPYI:
            let op = fetchByteZeropageIndirectYindexed()
            A = A ^ op
            Z = A == 0
            N = A & 0b10000000 > 0
            
        case ORA_IM:
            let op = fetchByteImmediatePC()
            A = A | op
            Z = A == 0
            N = A & 0b10000000 > 0
        case ORA_AB:
            let op = fetchByteAbsolutePC()
            A = A | op
            Z = A == 0
            N = A & 0b10000000 > 0
        case ORA_XAB:
            let op = fetchByteAbsolutePCindexedX()
            A = A | op
            Z = A == 0
            N = A & 0b10000000 > 0
        case ORA_YAB:
            let op = fetchByteAbsolutePCindexedY()
            A = A | op
            Z = A == 0
            N = A & 0b10000000 > 0
        case ORA_ZP:
            let op = fetchByteZeropage()
            A = A | op
            Z = A == 0
            N = A & 0b10000000 > 0
        case ORA_XZP:
            let op = fetchByteXindexedZeropage()
            A = A | op
            Z = A == 0
            N = A & 0b10000000 > 0
        case ORA_XZPI:
            let op = fetchByteXindexedZeropageIndirect()
            A = A | op
            Z = A == 0
            N = A & 0b10000000 > 0
        case ORA_ZPYI:
            let op = fetchByteZeropageIndirectYindexed()
            A = A | op
            Z = A == 0
            N = A & 0b10000000 > 0
            
            //MARK: - Arythmetical Operations
        case ADC_IM:
            adc(operand: fetchByteImmediatePC())
        case ADC_AB:
            adc(operand: fetchByteAbsolutePC())
        case ADC_XAB:
            adc(operand: fetchByteAbsolutePCindexedX())
        case ADC_YAB:
            adc(operand: fetchByteAbsolutePCindexedY())
        case ADC_ZP:
            adc(operand: fetchByteZeropage())
        case ADC_XZP:
            adc(operand: fetchByteXindexedZeropage())
        case ADC_XZPI:
            adc(operand: fetchByteXindexedZeropageIndirect())
        case ADC_ZPYI:
            adc(operand: fetchByteZeropageIndirectYindexed())
            
        case CMP_IM:
            cmp(operand: fetchByteImmediatePC(), register: A)
        case CMP_AB:
            cmp(operand: fetchByteAbsolutePC(), register: A)
        case CMP_XAB:
            cmp(operand: fetchByteAbsolutePCindexedX(), register: A)
        case CMP_YAB:
            cmp(operand: fetchByteAbsolutePCindexedY(), register: A)
        case CMP_ZP:
            cmp(operand: fetchByteZeropage(), register: A)
        case CMP_XZP:
            cmp(operand: fetchByteXindexedZeropage(), register: A)
        case CMP_XZPI:
            cmp(operand: fetchByteXindexedZeropageIndirect(), register: A)
        case CMP_ZPYI:
            cmp(operand: fetchByteZeropageIndirectYindexed(), register: A)
            
        case CPX_IM:
            cmp(operand: fetchByteImmediatePC(), register: X)
        case CPX_AB:
            cmp(operand: fetchByteAbsolutePC(), register: X)
        case CPX_ZP:
            cmp(operand: fetchByteZeropage(), register: X)
            
        case CPY_IM:
            cmp(operand: fetchByteImmediatePC(), register: Y)
        case CPY_AB:
            cmp(operand: fetchByteAbsolutePC(), register: Y)
        case CPY_ZP:
            cmp(operand: fetchByteZeropage(), register: Y)
            
        case SBC_IM:
            sbc(operand: fetchByteImmediatePC())
        case SBC_AB:
            sbc(operand: fetchByteAbsolutePC())
        case SBC_XAB:
            sbc(operand: fetchByteAbsolutePCindexedX())
        case SBC_YAB:
            sbc(operand: fetchByteAbsolutePCindexedY())
        case SBC_ZP:
            sbc(operand: fetchByteZeropage())
        case SBC_XZP:
            sbc(operand: fetchByteXindexedZeropage())
        case SBC_XZPI:
            sbc(operand: fetchByteXindexedZeropageIndirect())
        case SBC_ZPYI:
            sbc(operand: fetchByteZeropageIndirectYindexed())
            
            //MARK: - Incremental Operations
        case DEC_AB:
            var op = fetchByteAbsolutePC()
            op &-= 1
            Z = op == 0
            N = op & 0b10000000 > 0
            writeByteToMemory(address: OP, byte: op)
            cycles += 2
        case DEC_XAB:
            var op = fetchByteAbsolutePCindexedX()
            op &-= 1
            Z = op == 0
            N = op & 0b10000000 > 0
            writeByteToMemory(address: OP, byte: op)
            cycles += 3
        case DEC_ZP:
            var op = fetchByteZeropage()
            op &-= 1
            Z = op == 0
            N = op & 0b10000000 > 0
            c64.memory[Int(OPZP)] = op
            cycles += 2
        case DEC_XZP:
            var op = fetchByteXindexedZeropage()
            op &-= 1
            Z = op == 0
            N = op & 0b10000000 > 0
            c64.memory[Int(OPZP)] = op
            cycles += 2
        case DEX:
            X &-= 1
            Z = X == 0
            N = X & 0b10000000 > 0
            cycles += 1
        case DEY:
            Y &-= 1
            Z = Y == 0
            N = Y & 0b10000000 > 0
            cycles += 1
            
        case INC_AB:
            var op = fetchByteAbsolutePC()
            op &+= 1
            Z = op == 0
            N = op & 0b10000000 > 0
            writeByteToMemory(address: OP, byte: op)
            cycles += 2
        case INC_XAB:
            var op = fetchByteAbsolutePCindexedX()
            op &+= 1
            Z = op == 0
            N = op & 0b10000000 > 0
            writeByteToMemory(address: OP, byte: op)
            cycles += 3
        case INC_ZP:
            var op = fetchByteZeropage()
            op &+= 1
            Z = op == 0
            N = op & 0b10000000 > 0
            c64.memory[Int(OPZP)] = op
            cycles += 2
        case INC_XZP:
            var op = fetchByteXindexedZeropage()
            op &+= 1
            Z = op == 0
            N = op & 0b10000000 > 0
            c64.memory[Int(OPZP)] = op
            cycles += 2
        case INX:
            X &+= 1
            Z = X == 0
            N = X & 0b10000000 > 0
            cycles += 1
        case INY:
            Y &+= 1
            Z = Y == 0
            N = Y & 0b10000000 > 0
            cycles += 1
            
        default:
            print("unknown instruction")
            return
        }
    }
    //MARK: - functions
    func branch(cond: Bool) {
        let distance = Int(Int8(bitPattern: fetchByteImmediatePC()))
        if(cond) {
            if distance + Int(PC & 0xFF) > 0xFF { cycles += 1}
            PC = Word(Int(PC) + distance)
            cycles += 1
        }
    }
    func readByteFromMemory(address: Word)->Byte {
        return c64.readByteFromAddress(address)
    }
    
    func writeByteToMemory(address: Word, byte: Byte) {
        c64.writeByteToAddress(address, byte: byte)
    }
        
    func fetchByteImmediatePC()->Byte {
        let data = readByteFromMemory(address: PC)
        PC += 1
        cycles += 1
        return data
    }
    
    func fetchByteAbsolutePC()->Byte {
        let addressLowByte = fetchByteImmediatePC()
        let addressHighByte = fetchByteImmediatePC()
        OP = Word(addressHighByte) << 8
        OP = OP | Word(addressLowByte)
        cycles += 1
        return readByteFromMemory(address: OP)
    }
    
    func fetchByteAbsolutePCindexedX()->Byte {
        let addressLowByte = fetchByteImmediatePC()
        let addressHighByte = fetchByteImmediatePC()
        OP = Word(addressHighByte) << 8
        OP = OP | Word(addressLowByte)
        OP += Word(X)
        cycles += 1
        if OP & 0x00FF < Word(X) {
            cycles += 1
        }
        return readByteFromMemory(address: OP)
    }
    
    func fetchByteAbsolutePCindexedY()->Byte {
        let addressLowByte = fetchByteImmediatePC()
        let addressHighByte = fetchByteImmediatePC()
        var address: Word = Word(addressHighByte) << 8
        address = address | Word(addressLowByte)
        address += Word(Y)
        cycles += 1
        if address & 0x00FF < Word(Y) {
            cycles += 1
        }
        return readByteFromMemory(address: address)
    }
    
    func fetchAddressAbsolute(address: Word)->Word {
        let addressLowByte = readByteFromMemory(address: address)
        let addressHighByte = readByteFromMemory(address: address + 1)
        var address: Word = Word(addressHighByte) << 8
        address = address | Word(addressLowByte)
        cycles += 6
        return address
    }
    
    func fetchAddressAbsolutePC()->Word {
        let addressLowByte = fetchByteImmediatePC()
        let addressHighByte = fetchByteImmediatePC()
        var address: Word = Word(addressHighByte) << 8
        address = address | Word(addressLowByte)
        return address
    }
    
    func fetchAddressAbsolutePCIndirect()->Word {
        let addressIndirect = fetchAddressAbsolutePC()
        let addressLowByte = readByteFromMemory(address: addressIndirect)
        let addressHighByte = readByteFromMemory(address: addressIndirect + 1)
        let address: Word = Word(addressHighByte) << 8
        cycles += 2
        return address | Word(addressLowByte)
    }
    
    func fetchByteZeropage()->Byte {
        OPZP = readByteFromMemory(address: PC)
        PC += 1
        cycles += 2
        return  readByteFromMemory(address: Word(OPZP))
    }
    
    func fetchByteXindexedZeropage()->Byte {
        let addressZeropage = Word(readByteFromMemory(address: PC)) + Word(X)
        OPZP = Byte(addressZeropage & 0x00FF)
        PC += 1
        cycles += 3
        return  readByteFromMemory(address: Word(OPZP))
    }
    
    func fetchByteYindexedZeropage()->Byte {
        var addressZeropage = Word(readByteFromMemory(address: PC)) + Word(Y)
        addressZeropage = addressZeropage & 0x00FF
        PC += 1
        cycles += 3
        return  readByteFromMemory(address: addressZeropage)
    }
    
    func fetchByteXindexedZeropageIndirect()->Byte {
        var addressZeropage = Word(readByteFromMemory(address: PC)) + Word(X)
        addressZeropage = addressZeropage & 0x00FF
        let addressLowByte = readByteFromMemory(address: addressZeropage)
        let addressHighByte = readByteFromMemory(address: addressZeropage + 1)
        var address: Word = Word(addressHighByte) << 8
        address = address | Word(addressLowByte)
        PC += 1
        cycles += 5
        return  readByteFromMemory(address: address)
    }
    
    func fetchByteZeropageIndirectYindexed()->Byte {
        let addressZeropage = Int(readByteFromMemory(address: PC))
        let addressLowByte = readByteFromMemory(address: Word(addressZeropage))
        let addressHighByte = readByteFromMemory(address: Word(addressZeropage + 1))
        var address: Word = Word(addressHighByte) << 8
        address = address | Word(addressLowByte)
        address += Word(Y)
        PC += 1
        cycles += 4
        if address & 0x00FF < Word(Y) {
            cycles += 1
        }
        return  readByteFromMemory(address: address)
    }
    
    func StoreByteAbsolutePC(byte: Byte) {
        let addressLowByte = fetchByteImmediatePC()
        let addressHighByte = fetchByteImmediatePC()
        var address: Word = Word(addressHighByte) << 8
        address = address | Word(addressLowByte)
        cycles += 3
        writeByteToMemory(address: address, byte: byte)
    }
    
    func StoreByteAbsolutePCIndexedX(byte: Byte) {
        let addressLowByte = fetchByteImmediatePC()
        let addressHighByte = fetchByteImmediatePC()
        var address: Word = Word(addressHighByte) << 8
        address = address | Word(addressLowByte)
        cycles += 4
        writeByteToMemory(address: address + Word(X), byte: byte)
    }
    
    func StoreByteAbsolutePCIndexedY(byte: Byte) {
        let addressLowByte = fetchByteImmediatePC()
        let addressHighByte = fetchByteImmediatePC()
        var address: Word = Word(addressHighByte) << 8
        address = address | Word(addressLowByte)
        cycles += 4
        writeByteToMemory(address: address + Word(Y), byte: byte)
    }
    
    func StoreByteZeropage(byte: Byte) {
        let address = fetchByteImmediatePC()
        cycles += 1
        writeByteToMemory(address: Word(address), byte: byte)
    }
    
    func StoreByteXindexedZeropage(byte: Byte) {
        let address = fetchByteImmediatePC()
        cycles += 2
        writeByteToMemory(address: Word(address) + Word(X), byte: byte)
    }
    
    func StoreByteYindexedZeropage(byte: Byte) {
        let address = fetchByteImmediatePC()
        cycles += 2
        writeByteToMemory(address: Word(address) + Word(Y), byte: byte)
    }
    
    func StoreByteXindexedZeropageIndirect(byte: Byte) {
        var addressZeropage = Word(fetchByteImmediatePC()) + Word(X)
        addressZeropage = addressZeropage & 0x00FF
        let addressLowByte = readByteFromMemory(address: addressZeropage)
        let addressHighByte = readByteFromMemory(address: addressZeropage + 1)
        var address: Word = Word(addressHighByte) << 8
        address = address | Word(addressLowByte)
        cycles += 5
        writeByteToMemory(address: address, byte: byte)
    }
    
    func storeByteZeropageIndirectYindexed(byte: Byte) {
        let addressZeropage = fetchByteImmediatePC()
        let addressLowByte = readByteFromMemory(address: Word(addressZeropage))
        let addressHighByte = readByteFromMemory(address: Word(addressZeropage + 1))
        var address: Word = Word(addressHighByte) << 8
        address = address | Word(addressLowByte)
        address += Word(Y)
        cycles += 5
        writeByteToMemory(address: address, byte: byte)
    }
    
    func adc(operand: Byte) {
        if !D {
            // binary mode
            var op = Word(operand)
            TC = !(((A ^ operand) & 0x80) > 0) // true if the sign bits are eqal
            op = op + Word(A)
            if C { op += 1}
            C = op > 0xFF
            A = Byte(op & 0xFF)
            Z = A == 0
            N = A & 0x80 > 0
            V = TC && (((A ^ operand) & 0x80) > 0) //true if the sign bits differ
        }
        else {
            // dezimal mode
            var op1 = Word(A)
            let op2 = Word(operand)
            TC = !(((A ^ operand) & 0x80) > 0)
            var AL = (op1 & 0x0F) + (op2 & 0x0F) + (C ? 0x01 : 0x00)
            if(AL >= 0x0A) { AL = ((AL + 0x06) & 0x0F) + 0x10 }
            op1 = (op1 & 0xF0) + (op2 & 0xF0) + AL
            if(op1 >= 0xA0) { op1 += 0x60 }
            A = Byte(op1 & 0xFF)
            C = op1 >= 0x100
            Z = A == 0 // same as in binary mode
            N = A & 0x80 > 0
            V = TC && (((A ^ operand) & 0x80) > 0) //true bei ungleich
        }
    }
    
    func sbc(operand: Byte) {
        if(!D) {
            adc(operand: ~operand)
        }
        else {
            var op1 = Int16(A)
            let op2 = Int16(operand)
            TC = !(((A ^ operand) & 0x80) > 0)
            var AL = (op1 & 0x0F) - ((op2 & 0x0F) + (C ? 1 : 0) - 1)
            if(AL < 0) { AL = ((AL -  0x06) & 0x0F) - 0x10 }
            op1 = (op1 & 0xF0) - (op2 & 0xF0) + AL
            if (op1 < 0) { op1 -= 0x60 }
            A = Byte(op1 & 0xFF)
            C = op1 >= 0
            N = A & 0x80 > 0
            V = TC && (((A ^ operand) & 0x80) > 0) //true bei ungleich
        }
    }
    
    func cmp(operand: Byte, register: Byte) {
        Z = operand == register
        C = operand <= register
        N = (Int(register) - Int(operand)) & 0b10000000 > 0
    }
    
    func prepareForTest(address: Int, bytes: [Byte]) {
        for i in 0..<bytes.count {
            c64.memory[address + i] = bytes[i]
        }
        PC = Word(address)
        cycles = 0
    }
}
