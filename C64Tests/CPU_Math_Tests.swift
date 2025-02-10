//
//  6502_Math_tests.swift
//  C64 Emulator
//
//  Created by Holger Becker on 30.01.25.
//

import Testing
@testable import C64


struct CPU_Math_Tests {
    var c64 = C64()
    @Test mutating func testADC_IM() async {
        let opcode: Byte = 0x69
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 25, HALT])
        c64.mos6502.A = 26
        c64.mos6502.execute()
        #expect(c64.mos6502.A == 51)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 2)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 120, HALT])
        c64.mos6502.A = 20
        c64.mos6502.C = false
        c64.mos6502.execute()
        #expect(c64.mos6502.A == 140)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == true)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 250, HALT])
        c64.mos6502.A = 6
        c64.mos6502.C = false
        c64.mos6502.execute()
        #expect(c64.mos6502.A == 0)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 42, HALT])
        c64.mos6502.A = 100
        c64.mos6502.C = true
        c64.mos6502.execute()
        #expect(c64.mos6502.A == 143)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == true)
    }
    @Test mutating func testADC_AB() async {
        let opcode: Byte = 0x6D
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 25
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 51)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 4)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 120
        c64.mos6502.A = 20
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 140)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == true)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 250
        c64.mos6502.A = 6
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 0)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 42
        c64.mos6502.A = 100
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 143)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == true)
    }
    @Test mutating func testADC_XAB() async {
        let opcode: Byte = 0x7D
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000 + 0x10] = 25
        c64.mos6502.X = 0x10
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 51)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 4)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0xFF, 0x30, HALT])
        c64.memory[0x30FF + 0x10] = 250
        c64.mos6502.X = 0x10
        c64.mos6502.A = 20
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 14)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 5)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0xFF, 0x30, HALT])
        c64.memory[0x30FF + 0x10] = 250
        c64.mos6502.X = 0x10
        c64.mos6502.A = 6
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 0)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0xFF, 0x30, HALT])
        c64.memory[0x30FF + 0x10] = 42
        c64.mos6502.X = 0x10
        c64.mos6502.A = 100
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 143)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == true)
        
    }
    @Test mutating func testADC_YAB() async {
        let opcode: Byte = 0x79
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000 + 0x10] = 25
        c64.mos6502.Y = 0x10
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 51)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 4)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0xFF, 0x30, HALT])
        c64.memory[0x30FF + 0x10] = 250
        c64.mos6502.Y = 0x10
        c64.mos6502.A = 20
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 14)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0xFF, 0x30, HALT])
        c64.memory[0x30FF + 0x10] = 250
        c64.mos6502.Y = 0x10
        c64.mos6502.A = 6
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 0)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 5)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0xFF, 0x30, HALT])
        c64.memory[0x30FF + 0x10] = 42
        c64.mos6502.Y = 0x10
        c64.mos6502.A = 100
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 143)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == true)
    }
    @Test mutating func testADC_ZP() async {
        let opcode: Byte = 0x65
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 25
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 51)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 3)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 250
        c64.mos6502.A = 20
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 14)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 250
        c64.mos6502.A = 6
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 0)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 42
        c64.mos6502.A = 100
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 143)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == true)
    }
    @Test mutating func testADC_XZP() async {
        let opcode: Byte = 0x75
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A + 0x03] = 25
        c64.mos6502.X = 0x03
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 51)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 4)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A + 0x03] = 250
        c64.mos6502.X = 0x03
        c64.mos6502.A = 20
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 14)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A + 0x03] = 250
        c64.mos6502.X = 0x03
        c64.mos6502.A = 6
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 0)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A + 0x03] = 42
        c64.mos6502.X = 0x03
        c64.mos6502.A = 100
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 143)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == true)
    }
    @Test mutating func testADC_XZPI() async {
        let opcode: Byte = 0x61
        c64.mos6502.prepareForTest(address: 0x0A + 0x03, bytes: [0x01, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x3001] = 25
        c64.mos6502.X = 0x03
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 51)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 6)
        
        c64.mos6502.prepareForTest(address: 0x0A + 0x03, bytes: [0x01, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x3001] = 250
        c64.mos6502.X = 0x03
        c64.mos6502.A = 20
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 14)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x0A + 0x03, bytes: [0x01, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x3001] = 250
        c64.mos6502.X = 0x03
        c64.mos6502.A = 6
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 0)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x0A + 0x03, bytes: [0x01, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x3001] = 42
        c64.mos6502.X = 0x03
        c64.mos6502.A = 100
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 143)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == true)
    }
    @Test mutating func testADC_ZPYI() async {
        let opcode: Byte = 0x71
        c64.mos6502.prepareForTest(address: 0x0A, bytes: [0x01, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x3001 + 0x03] = 25
        c64.mos6502.Y = 0x03
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 51)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 5)
        
        c64.mos6502.prepareForTest(address: 0x0A, bytes: [0xFF, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x30FF + 0x03] = 250
        c64.mos6502.Y = 0x03
        c64.mos6502.A = 20
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 14)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 6)
        
        c64.mos6502.prepareForTest(address: 0x0A, bytes: [0xFF, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x30FF + 0x03] = 250
        c64.mos6502.Y = 0x03
        c64.mos6502.A = 6
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 0)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x0A, bytes: [0xFF, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x30FF + 0x03] = 42
        c64.mos6502.Y = 0x03
        c64.mos6502.A = 100
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 143)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == true)
    }
    
    @Test mutating func testCMP_IM() async {
        let opcode: Byte = 0xC9
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 25, HALT])
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 2)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 26, HALT])
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 27, HALT])
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
    }
    @Test mutating func testCMP_AB() async {
        let opcode: Byte = 0xCD
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 25
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 4)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 26
        c64.mos6502.A = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 27
        c64.mos6502.A = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
    }
    @Test mutating func testCMP_XAB() async {
        let opcode: Byte = 0xDD
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000 + 0x10] = 25
        c64.mos6502.X = 0x10
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 4)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0xFF, 0x30, HALT])
        c64.memory[0x30FF + 0x10] = 26
        c64.mos6502.X = 0x10
        c64.mos6502.A = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 5)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0xFF, 0x30, HALT])
        c64.memory[0x30FF + 0x10] = 27
        c64.mos6502.X = 0x10
        c64.mos6502.A = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
    }
    @Test mutating func testCMP_YAB() async {
        let opcode: Byte = 0xD9
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000 + 0x10] = 25
        c64.mos6502.Y = 0x10
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 4)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0xFF, 0x30, HALT])
        c64.memory[0x30FF + 0x10] = 26
        c64.mos6502.Y = 0x10
        c64.mos6502.A = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 5)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0xFF, 0x30, HALT])
        c64.memory[0x30FF + 0x10] = 27
        c64.mos6502.Y = 0x10
        c64.mos6502.A = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
    }
    @Test mutating func testCMP_ZP() async {
        let opcode: Byte = 0xC5
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 25
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 3)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 26
        c64.mos6502.A = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 27
        c64.mos6502.A = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
    }
    @Test mutating func testCMP_XZP() async {
        let opcode: Byte = 0xD5
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A + 0x03] = 25
        c64.mos6502.X = 0x03
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 4)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A + 0x03] = 26
        c64.mos6502.X = 0x03
        c64.mos6502.A = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A + 0x03] = 27
        c64.mos6502.X = 0x03
        c64.mos6502.A = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
    }
    @Test mutating func testCMP_XZPI() async {
        let opcode: Byte = 0xC1
        c64.mos6502.prepareForTest(address: 0x0A + 0x03, bytes: [0x01, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x3001] = 25
        c64.mos6502.X = 0x03
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 6)
        
        c64.mos6502.prepareForTest(address: 0x0A + 0x03, bytes: [0x01, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x3001] = 26
        c64.mos6502.X = 0x03
        c64.mos6502.A = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        
        c64.mos6502.prepareForTest(address: 0x0A + 0x03, bytes: [0x01, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x3001] = 27
        c64.mos6502.X = 0x03
        c64.mos6502.A = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
    }
    @Test mutating func testCMP_ZPYI() async {
        let opcode: Byte = 0xD1
        c64.mos6502.prepareForTest(address: 0x0A, bytes: [0x01, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x3001 + 0x03] = 25
        c64.mos6502.Y = 0x03
        c64.mos6502.A = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 5)
        
        c64.mos6502.prepareForTest(address: 0x0A, bytes: [0xFF, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x30FF + 0x03] = 26
        c64.mos6502.Y = 0x03
        c64.mos6502.A = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 6)
        
        c64.mos6502.prepareForTest(address: 0x0A, bytes: [0xFF, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x30FF + 0x03] = 27
        c64.mos6502.Y = 0x03
        c64.mos6502.A = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
    }
    
    @Test mutating func testCPX_IM() async {
        let opcode: Byte = 0xE0
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 25, HALT])
        c64.mos6502.X = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 2)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 26, HALT])
        c64.mos6502.X = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 27, HALT])
        c64.mos6502.X = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
    }
    @Test mutating func testCPX_AB() async {
        let opcode: Byte = 0xEC
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 25
        c64.mos6502.X = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 4)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 26
        c64.mos6502.X = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 27
        c64.mos6502.X = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
    }
    @Test mutating func testCPX_ZP() async {
        let opcode: Byte = 0xE4
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 25
        c64.mos6502.X = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 3)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 26
        c64.mos6502.X = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 27
        c64.mos6502.X = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
    }
    
    @Test mutating func testCPY_IM() async {
        let opcode: Byte = 0xE0
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 25, HALT])
        c64.mos6502.X = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 2)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 26, HALT])
        c64.mos6502.X = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 27, HALT])
        c64.mos6502.X = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
    }
    @Test mutating func testCPY_AB() async {
        let opcode: Byte = 0xEC
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 25
        c64.mos6502.X = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 4)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 26
        c64.mos6502.X = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 27
        c64.mos6502.X = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
    }
    @Test mutating func testCPY_ZP() async {
        let opcode: Byte = 0xE4
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 25
        c64.mos6502.X = 26
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.cycles == 3)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 26
        c64.mos6502.X = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == true)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 27
        c64.mos6502.X = 26
        c64.mos6502.C = false
         c64.mos6502.execute()
        #expect(c64.mos6502.X == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
    }
    
    @Test mutating func testSBC_IM() async {
        let opcode: Byte = 0xE9
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x80, HALT])
        c64.mos6502.C = false
        c64.mos6502.A = 0x60
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 0xE0)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == true)
        #expect(c64.mos6502.cycles == 2)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 250, HALT])
        c64.mos6502.A = 20
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 250, HALT])
        c64.mos6502.A = 6
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 12)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 3, HALT])
        c64.mos6502.A = 5
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 2)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
    }
    @Test mutating func testSBC_AB() async {
        let opcode: Byte = 0xED
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 26
        c64.mos6502.A = 25
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 255)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 4)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 250
        c64.mos6502.A = 20
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)

        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 250
        c64.mos6502.A = 6
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 12)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)

        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000] = 42
        c64.mos6502.A = 100
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 58)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
    }
    @Test mutating func testSBC_XAB() async {
        let opcode: Byte = 0xFD
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000 + 0x10] = 26
        c64.mos6502.X = 0x10
        c64.mos6502.A = 25
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 255)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 4)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0xFF, 0x30, HALT])
        c64.memory[0x30FF + 0x10] = 250
        c64.mos6502.X = 0x10
        c64.mos6502.A = 20
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 5)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0xFF, 0x30, HALT])
        c64.memory[0x30FF + 0x10] = 250
        c64.mos6502.X = 0x10
        c64.mos6502.A = 6
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 12)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0xFF, 0x30, HALT])
        c64.memory[0x30FF + 0x10] = 42
        c64.mos6502.X = 0x10
        c64.mos6502.A = 100
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 58)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
        
    }
    @Test mutating func testSBC_YAB() async {
        let opcode: Byte = 0xF9
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x00, 0x30, HALT])
        c64.memory[0x3000 + 0x10] = 26
        c64.mos6502.Y = 0x10
        c64.mos6502.A = 25
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 255)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 4)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0xFF, 0x30, HALT])
        c64.memory[0x30FF + 0x10] = 250
        c64.mos6502.Y = 0x10
        c64.mos6502.A = 20
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0xFF, 0x30, HALT])
        c64.memory[0x30FF + 0x10] = 250
        c64.mos6502.Y = 0x10
        c64.mos6502.A = 6
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 12)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 5)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0xFF, 0x30, HALT])
        c64.memory[0x30FF + 0x10] = 42
        c64.mos6502.Y = 0x10
        c64.mos6502.A = 100
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 58)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
    }
    @Test mutating func testSBC_ZP() async {
        let opcode: Byte = 0xE5
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 26
        c64.mos6502.A = 25
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 255)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 3)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 250
        c64.mos6502.A = 20
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 250
        c64.mos6502.A = 6
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 12)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A] = 42
        c64.mos6502.A = 100
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 58)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
    }
    @Test mutating func testSBC_XZP() async {
        let opcode: Byte = 0xF5
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A + 0x03] = 26
        c64.mos6502.X = 0x03
        c64.mos6502.A = 25
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 255)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 4)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A + 0x03] = 250
        c64.mos6502.X = 0x03
        c64.mos6502.A = 20
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A + 0x03] = 250
        c64.mos6502.X = 0x03
        c64.mos6502.A = 6
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 12)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x0A + 0x03] = 42
        c64.mos6502.X = 0x03
        c64.mos6502.A = 100
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 58)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
    }
    @Test mutating func testSBC_XZPI() async {
        let opcode: Byte = 0xE1
        c64.mos6502.prepareForTest(address: 0x0A + 0x03, bytes: [0x01, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x3001] = 26
        c64.mos6502.X = 0x03
        c64.mos6502.A = 25
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 255)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 6)
        
        c64.mos6502.prepareForTest(address: 0x0A + 0x03, bytes: [0x01, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x3001] = 250
        c64.mos6502.X = 0x03
        c64.mos6502.A = 20
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x0A + 0x03, bytes: [0x01, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x3001] = 250
        c64.mos6502.X = 0x03
        c64.mos6502.A = 6
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 12)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x0A + 0x03, bytes: [0x01, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x3001] = 42
        c64.mos6502.X = 0x03
        c64.mos6502.A = 100
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 58)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
    }
    @Test mutating func testSBC_ZPYI() async {
        let opcode: Byte = 0xF1
        c64.mos6502.prepareForTest(address: 0x0A, bytes: [0x01, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x3001 + 0x03] = 26
        c64.mos6502.Y = 0x03
        c64.mos6502.A = 25
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 255)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 5)
        
        c64.mos6502.prepareForTest(address: 0x0A, bytes: [0xFF, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x30FF + 0x03] = 250
        c64.mos6502.Y = 0x03
        c64.mos6502.A = 20
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 26)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        #expect(c64.mos6502.cycles == 6)
        
        c64.mos6502.prepareForTest(address: 0x0A, bytes: [0xFF, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x30FF + 0x03] = 6
        c64.mos6502.Y = 0x03
        c64.mos6502.A = 5
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 255)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == true)
        #expect(c64.mos6502.C == false)
        #expect(c64.mos6502.V == false)
        
        c64.mos6502.prepareForTest(address: 0x0A, bytes: [0xFF, 0x30])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [opcode, 0x0A, HALT])
        c64.memory[0x30FF + 0x03] = 3
        c64.mos6502.Y = 0x03
        c64.mos6502.A = 5
        c64.mos6502.C = true
         c64.mos6502.execute()
        #expect(c64.mos6502.A == 2)
        #expect(c64.mos6502.Z == false)
        #expect(c64.mos6502.N == false)
        #expect(c64.mos6502.C == true)
        #expect(c64.mos6502.V == false)
    }        

}
