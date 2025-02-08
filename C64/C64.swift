//
//  C64.swift
//  C64 Emulator
//
//  Created by Holger Becker on 28.01.25.
//

import Foundation

class C64: ObservableObject {
    
    static let shared = C64()
    
    var vic: VICII?
    
    struct C64Adresses {
        static let CharacterROM = (start: Word(0xD000), end: Word(0xDFFF))
        static let BasicRom = (start: Word(0xA000), end: Word(0xBFFF))
        static let KernalRom = (start: Word(0xE000), end: Word(0xFFFF))
        static let Vic = (start: Word(0xD000), end: Word(0xD3FF))
        static let Cid = (start: Word(0xD400), end: Word(0xD7FF))
        static let Cia1 = (start: Word(0xDC00), end: Word(0xDCFF))
        static let Cia2 = (start: Word(0xDD00), end: Word(0xDDFF))
    }

    var clockTimer: Timer?
    
    let MaxMem = 1024 * 64
    
    var memory = [Byte]()
    
    var characterRom = [Byte]()
    var basicROM = [Byte]()
    var kernalROM = [Byte]()
    
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
        mos6502 = MOS6502()
        loadROMs()
        mos6502.c64 = self
        mos6502.reset()
        startTimer()
    }
    
    func startTimer() {
        if clockTimer == nil {
            clockTimer = Timer.scheduledTimer(timeInterval: 0.000_001, target: self, selector: #selector(clock), userInfo: "MOS6502", repeats: false)
        }
    }
    
    func stopTimer() {
        clockTimer?.invalidate()
        clockTimer = nil
    }
    
    @objc func clock() {
        guard vic != nil else { return }
        vic?.clock()
        mos6502.execute()
        if(cia1.clock()) == true {
            mos6502.INT = true
        }
        _ = cia2.clock()
        clockTimer?.invalidate()
        clockTimer = nil
        startTimer()
    }

    
    func readByteFromAddress(_ address: Word)->Byte {
        // Address decoding
        if (LORAM && address >= C64Adresses.BasicRom.start && address <= C64Adresses.BasicRom.end) {
            return basicROM[Int(address - C64Adresses.BasicRom.start)]
        }
        if (HIRAM && address >= C64Adresses.KernalRom.start && address <= C64Adresses.KernalRom.end) {
            return kernalROM[Int(address - C64Adresses.KernalRom.start)]
        }
        if (!CHAREN && address >= C64Adresses.CharacterROM.start && address <= C64Adresses.CharacterROM.end) {
            return characterRom[Int(address - C64Adresses.CharacterROM.start)]
        }
        if (CHAREN && address >= C64Adresses.Vic.start && address <= C64Adresses.Vic.end) {
            return vic?.getRegister(address: Int(address - C64Adresses.Vic.start)) ?? 0
        }
        if (CHAREN && address >= C64Adresses.Cia1.start && address <= C64Adresses.Cia1.end) {
            return cia1.getRegister(address: Int(address - C64Adresses.Cia1.start))
        }
        if (CHAREN && address >= C64Adresses.Cia2.start && address <= C64Adresses.Cia2.end) {
            return cia2.getRegister(address: Int(address - C64Adresses.Cia2.start))
        }
        return memory[Int(address)]
    }
    
    func writeByteToAddress(_ address: Word, byte: Byte) {
        if (CHAREN && address >= C64Adresses.Vic.start && address <= C64Adresses.Vic.end) {
            vic?.setRegister(address: Int(address - C64Adresses.Vic.start), byte: byte)
            return
        }
        if (CHAREN && address >= C64Adresses.Cia1.start && address <= C64Adresses.Cia1.end) {
            cia1.setRegister(address: Int(address - C64Adresses.Cia1.start), byte: byte)
            return
        }
        if (CHAREN && address >= C64Adresses.Cia2.start && address <= C64Adresses.Cia2.end) {
            cia2.setRegister(address: Int(address & C64Adresses.Cia2.start), byte: byte)
            return
        }
        memory[Int(address)] = byte
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

