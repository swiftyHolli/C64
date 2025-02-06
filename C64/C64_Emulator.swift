//
//  C64_Emulator.swift
//  C64 Emulator
//
//  Created by Holger Becker on 01.02.25.
//
import SwiftUI

class C64Emulator {
    var c64: C64
    
    init() {
        c64 = C64()
        reset()
    }
    
    func reset() {
        c64.mos6502.reset()
    }
    
    var character: Byte = 0x00
    func writeScreen() {
        character &+= 1
        c64.memory[0x2003] = character
        c64.memory[0xD800 + Int(character)] = character
        c64.memory[0xD021] = character
    }
}

