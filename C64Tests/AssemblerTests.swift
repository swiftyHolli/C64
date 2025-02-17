//
//  AssemblerTests.swift
//  C64Tests
//
//  Created by Holger Becker on 16.02.25.
//

import Testing
@testable import C64

struct AssemblerTests {
    var assembler = Disassembler()
    
    @Test mutating func TestLDA() {
        assembler.disassemble([0xA9, 0x01], length: 1)
        #expect (assembler.disassembly[0].description == "LDA #$01")
    }
    @Test mutating func TestBRK() {
        assembler.disassemble([0xA9, 0x01, 0x00], length: 2)
        #expect (assembler.disassembly[0].description == "LDA #$01")
        #expect (assembler.disassembly[1].description == "BRK")
    }
    @Test mutating func TestZPX() {
        assembler.disassemble([0xA9, 0x01, 0x00, 0x01, 0x0A], length: 3)
        #expect (assembler.disassembly[0].description == "LDA #$01")
        #expect (assembler.disassembly[1].description == "BRK")
        #expect (assembler.disassembly[2].description == "ORA ($0A,X)")
    }
    @Test mutating func TestZP() {
        assembler.disassemble([0x05, 0x42, 0x00], length: 2)
        #expect (assembler.disassembly[0].description == "ORA $42")
        #expect (assembler.disassembly[1].description == "BRK")
    }
    @Test mutating func TestImmediate() {
        assembler.disassemble([0x09, 0x42, 0x00], length: 2)
        #expect (assembler.disassembly[0].description == "ORA #$42")
        #expect (assembler.disassembly[1].description == "BRK")
    }
    @Test mutating func TestAbsolute() {
        assembler.disassemble([0x0D, 0x42, 0x02, 0x00], length: 2)
        #expect (assembler.disassembly[0].description == "ORA $0242")
        #expect (assembler.disassembly[1].description == "BRK")
    }
    @Test mutating func TestRelative() {
        assembler.disassemble([0x00, 0x00, 0x00, 0x00, 0x10, 0xFE, 0x10, 0x02, 0x00, 0x00], length: 8)
        #expect (assembler.disassembly[4].description == "BPL $0004")
        #expect (assembler.disassembly[5].description == "BPL $000A")
        #expect (assembler.disassembly[6].description == "BRK")
    }
    @Test mutating func TestZPY() {
        assembler.disassemble([0xA9, 0x01, 0x00, 0x11, 0x42], length: 3)
        #expect (assembler.disassembly[0].description == "LDA #$01")
        #expect (assembler.disassembly[1].description == "BRK")
        #expect (assembler.disassembly[2].description == "ORA ($42),Y")
    }
    @Test mutating func TestAbsoluteY() {
        assembler.disassemble([0x19, 0x42, 0x02, 0x00], length: 2)
        #expect (assembler.disassembly[0].description == "ORA $0242,Y")
        #expect (assembler.disassembly[1].description == "BRK")
    }
    @Test mutating func TestAbsoluteIndirect() {
        assembler.disassemble([0x6C, 0xFF, 0x42, 0x00], length: 2)
        #expect (assembler.disassembly[0].description == "JMP ($42FF)")
        #expect (assembler.disassembly[1].description == "BRK")
    }

}
