//
//  Test.swift
//  C64Tests
//
//  Created by Holger Becker on 05.02.25.
//

import Testing
@testable import C64


struct ROMTests {
    var c64 = C64()
    @Test mutating func testBasicROM() {
        c64.memory[0x00] = 0xEF
        c64.memory[0x01] = 0x37
        
        c64.mos6502.prepareForTest(address: 0xA000, bytes: [0x42])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [LDA_AB, 0x00, 0xA0, HALT])
        c64.mos6502.execute()
        
        #expect(c64.mos6502.A == 0x94)
        
        c64.mos6502.prepareForTest(address: 0xA001, bytes: [0x43])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [LDA_AB, 0x01, 0xA0, HALT])
        c64.mos6502.execute()
        
        #expect(c64.mos6502.A == 0xE3)
        
        c64.mos6502.prepareForTest(address: 0xA002, bytes: [0x44])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [LDA_AB, 0x02, 0xA0, HALT])
        c64.mos6502.execute()
        
        #expect(c64.mos6502.A == 0x7B)
        
        c64.mos6502.prepareForTest(address: 0xBFFF, bytes: [0x45])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [LDA_AB, 0xFF, 0xBF, HALT])
        c64.mos6502.execute()
        
        #expect(c64.mos6502.A == 0xE0)

        c64.memory[0x01] = 0b00110110
        c64.mos6502.prepareForTest(address: 0xA000, bytes: [0x42])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [LDA_AB, 0x00, 0xA0, HALT])
        c64.mos6502.execute()
        
        #expect(c64.mos6502.A == 0x42)
        
        c64.mos6502.prepareForTest(address: 0xA001, bytes: [0x43])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [LDA_AB, 0x01, 0xA0, HALT])
        c64.mos6502.execute()
        
        #expect(c64.mos6502.A == 0x43)
        
        c64.mos6502.prepareForTest(address: 0xA002, bytes: [0x44])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [LDA_AB, 0x02, 0xA0, HALT])
        c64.mos6502.execute()
        
        #expect(c64.mos6502.A == 0x44)
        
        c64.mos6502.prepareForTest(address: 0xBFFF, bytes: [0x45])
        c64.mos6502.prepareForTest(address: 0x2000, bytes: [LDA_AB, 0xFF, 0xBF, HALT])
        c64.mos6502.execute()
        
        #expect(c64.mos6502.A == 0x45)
    }
}

