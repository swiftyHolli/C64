//
//  C64.swift
//  C64 Emulator
//
//  Created by Holger Becker on 28.01.25.
//

import Foundation

class C64 {

    let MaxMem = 1024 * 64
    let characterROMStartAddress = 0xD000
    
    var memory = [Byte]()
    
    var characterRom = [Byte]()
    var basicROM = [Byte]()
    var kernalROM = [Byte]()
    
    var vic:  VIC
    var mos6502: MOS6502
    var cia1: CIA
    var cia2: CIA
    
    var LORAM: Bool {
        get {
            memory[0x0001] & 0b00000001 > 0
        }
    }
    var HIRAM: Bool {
        get {
            memory[0x0001] & 0b00000010 > 0
        }
    }
    var CHAREN: Bool {
        get {
            memory[0x0001] & 0b00000100 > 0
        }
    }
    
    var processorPortDataDirectionRegister: Byte {
        get {
            return memory[0x0000]
        }
        set {
            memory[0x0000] = newValue
        }
    }
    
    var processorPortDataRegister: Byte {
        get {
            return memory[0x0001]
        }
        set {
            //set the output lines and leave the input lines unchanged
            let inputLines = memory[0x0001] & ~processorPortDataDirectionRegister
            memory[0x0001] = (newValue & processorPortDataDirectionRegister) | inputLines
        }
    }
        
    init() {
        print("C64")
        memory = [Byte](repeating: 0, count: MaxMem)
        cia1 = CIA(address: 0xDC00)
        cia2 = CIA(address: 0xDD00)
        vic = VIC(address: 0xD000)
        mos6502 = MOS6502()
        loadROMs()
        cia1.c64 = self
        cia2.c64 = self
        vic.c64 = self
        mos6502.c64 = self

        //initMemory()
        //mos6502.reset()
    }
    
    func loadROMs() {
        loadCharacterROM()
        loadBasicROM()
        loadKernalROM()
    }
    
    func loadCharacterROM() {
        if let filePath = Bundle.main.path(forResource: "C64_Characters", ofType: "rom"){
            if let romData = try? Data(contentsOf: URL(filePath: filePath)) {
                for index in 0..<romData.count {
                    characterRom.append(romData[index])
                }
            }
        }
    }
    
    func loadBasicROM() {
        if let filePath = Bundle.main.path(forResource: "C64 - 901226-01 - Commodore (F833D117) Basic", ofType: "rom"){
            if let romData = try? Data(contentsOf: URL(filePath: filePath)) {
                for index in 0..<romData.count {
                    basicROM.append(romData[index])
                }
            }
        }
    }

    func loadKernalROM() {
        if let filePath = Bundle.main.path(forResource: "C64 - 901227-03 - Commodore (DBE3E7C7) Kernal", ofType: "rom"){
            if let romData = try? Data(contentsOf: URL(filePath: filePath)) {
                for index in 0..<romData.count {
                    kernalROM.append(romData[index])
                }
            }
        }
    }
}

