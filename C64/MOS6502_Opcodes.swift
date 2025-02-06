//
//  MOS6502_Opcodes.swift
//  C64 Emulator
//
//  Created by Holger Becker on 29.01.25.
//

// Control Instructions
let BRK:            Byte = 0x00
let JMP_AB:         Byte = 0x4C
let JMP_ABI:        Byte = 0x6C
let JSR_AB:         Byte = 0x20
let RTI:            Byte = 0x40
let RTS:            Byte = 0x60
let NOP:            Byte = 0xEA
let HALT:           Byte = 0xFF // used for test purposes only

// Branch Instructions
let BCC:            Byte = 0x90
let BCS:            Byte = 0xB0
let BEQ:            Byte = 0xF0
let BMI:            Byte = 0x30
let BNE:            Byte = 0xD0
let BPL:            Byte = 0x10
let BVC:            Byte = 0x50
let BVS:            Byte = 0x70

// flag set and reset instructions
let CLC:            Byte = 0x18
let CLD:            Byte = 0xD8
let CLI:            Byte = 0x58
let CLV:            Byte = 0xB8
let SEC:            Byte = 0x38
let SED:            Byte = 0xF8
let SEI:            Byte = 0x78

// Load Operations
let LDA_IM:         Byte = 0xA9
let LDA_AB:         Byte = 0xAD
let LDA_XAB:        Byte = 0xBD
let LDA_YAB:        Byte = 0xB9
let LDA_ZP:         Byte = 0xA5
let LDA_XZP:        Byte = 0xB5
let LDA_XZPI:       Byte = 0xA1
let LDA_ZPYI:       Byte = 0xB1

let LDX_IM:         Byte = 0xA2
let LDX_AB:         Byte = 0xAE
let LDX_YAB:        Byte = 0xBE
let LDX_ZP:         Byte = 0xA6
let LDX_YZP:        Byte = 0xB6

let LDY_IM:         Byte = 0xA0
let LDY_AB:         Byte = 0xAC
let LDY_XAB:        Byte = 0xBC
let LDY_ZP:         Byte = 0xA4
let LDY_XZP:        Byte = 0xB4

// Store Operations
let STA_AB:         Byte = 0x8D
let STA_XAB:        Byte = 0x9D
let STA_YAB:        Byte = 0x99
let STA_ZP:         Byte = 0x85
let STA_XZP:        Byte = 0x95
let STA_XZPI:       Byte = 0x81
let STA_ZPYI:       Byte = 0x91

let STX_AB:         Byte = 0x8E
let STX_ZP:         Byte = 0x86
let STX_YZP:        Byte = 0x96
let STY_AB:         Byte = 0x8C
let STY_ZP:         Byte = 0x84
let STY_XZP:        Byte = 0x94

// Transfer Operations
let TAX:            Byte = 0xAA
let TAY:            Byte = 0xA8
let TSX:            Byte = 0xBA
let TXA:            Byte = 0x8A
let TXS:            Byte = 0x9A
let TYA:            Byte = 0x98

// Stack Operations
let PHA:            Byte = 0x48
let PHP:            Byte = 0x08
let PLA:            Byte = 0x68
let PLP:            Byte = 0x28

// Shift Operations
let ASL_A:          Byte = 0x0A
let ASL_AB:         Byte = 0x0E
let ASL_XAB:        Byte = 0x1E
let ASL_ZP:         Byte = 0x06
let ASL_XZP:        Byte = 0x16

let LSR_A:          Byte = 0x4A
let LSR_AB:         Byte = 0x4E
let LSR_XAB:        Byte = 0x5E
let LSR_ZP:         Byte = 0x46
let LSR_XZP:        Byte = 0x56

let ROL_A:          Byte = 0x2A
let ROL_AB:         Byte = 0x2E
let ROL_XAB:        Byte = 0x3E
let ROL_ZP:         Byte = 0x26
let ROL_XZP:        Byte = 0x36

let ROR_A:          Byte = 0x6A
let ROR_AB:         Byte = 0x6E
let ROR_XAB:        Byte = 0x7E
let ROR_ZP:         Byte = 0x66
let ROR_XZP:        Byte = 0x76

let AND_IM:         Byte = 0x29
let AND_AB:         Byte = 0x2D
let AND_XAB:        Byte = 0x3D
let AND_YAB:        Byte = 0x39
let AND_ZP:         Byte = 0x25
let AND_XZP:        Byte = 0x35
let AND_XZPI:       Byte = 0x21
let AND_ZPYI:       Byte = 0x31

let BIT_AB:         Byte = 0x2C
let BIT_ZP:         Byte = 0x24

let EOR_IM:         Byte = 0x49
let EOR_AB:         Byte = 0x4D
let EOR_XAB:        Byte = 0x5D
let EOR_YAB:        Byte = 0x59
let EOR_ZP:         Byte = 0x45
let EOR_XZP:        Byte = 0x55
let EOR_XZPI:       Byte = 0x41
let EOR_ZPYI:       Byte = 0x51

let ORA_IM:         Byte = 0x09
let ORA_AB:         Byte = 0x0D
let ORA_XAB:        Byte = 0x1D
let ORA_YAB:        Byte = 0x19
let ORA_ZP:         Byte = 0x05
let ORA_XZP:        Byte = 0x15
let ORA_XZPI:       Byte = 0x01
let ORA_ZPYI:       Byte = 0x11

// Arythmetic Operations
let ADC_IM:         Byte = 0x69
let ADC_AB:         Byte = 0x6D
let ADC_XAB:        Byte = 0x7D
let ADC_YAB:        Byte = 0x79
let ADC_ZP:         Byte = 0x65
let ADC_XZP:        Byte = 0x75
let ADC_XZPI:       Byte = 0x61
let ADC_ZPYI:       Byte = 0x71

let CMP_IM:         Byte = 0xC9
let CMP_AB:         Byte = 0xCD
let CMP_XAB:        Byte = 0xDD
let CMP_YAB:        Byte = 0xD9
let CMP_ZP:         Byte = 0xC5
let CMP_XZP:        Byte = 0xD5
let CMP_XZPI:       Byte = 0xC1
let CMP_ZPYI:       Byte = 0xD1

let CPX_IM:         Byte = 0xE0
let CPX_AB:         Byte = 0xEC
let CPX_ZP:         Byte = 0xE4

let CPY_IM:         Byte = 0xC0
let CPY_AB:         Byte = 0xCC
let CPY_ZP:         Byte = 0xC4

let SBC_IM:         Byte = 0xE9
let SBC_AB:         Byte = 0xED
let SBC_XAB:        Byte = 0xFD
let SBC_YAB:        Byte = 0xF9
let SBC_ZP:         Byte = 0xE5
let SBC_XZP:        Byte = 0xF5
let SBC_XZPI:       Byte = 0xE1
let SBC_ZPYI:       Byte = 0xF1

// Incremental Operations
let DEC_AB:         Byte = 0xCE
let DEC_XAB:        Byte = 0xDE
let DEC_ZP:         Byte = 0xC6
let DEC_XZP:        Byte = 0xD6

let DEX:            Byte = 0xCA
let DEY:            Byte = 0x88

let INC_AB:         Byte = 0xEE
let INC_XAB:        Byte = 0xFE
let INC_ZP:         Byte = 0xE6
let INC_XZP:        Byte = 0xF6

let INX:            Byte = 0xE8
let INY:            Byte = 0xC8
