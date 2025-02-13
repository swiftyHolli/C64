//
//  C64.swift
//  C64 Emulator
//
//  Created by Holger Becker on 28.01.25.
//

import Foundation

class C64: ObservableObject {
    
    enum Interrupts: Int {
        case nmi
        case irq
        case none
    }
    
    var elapsedTime: Int = 0
    
    static let shared = C64()
    
    var vic: VICII?
    var keyboard: Keyboard?
    
    struct C64Adresses {
        static let CharacterROM = (start: Word(0xD000), end: Word(0xDFFF))
        static let BasicRom = (start: Word(0xA000), end: Word(0xBFFF))
        static let KernalRom = (start: Word(0xE000), end: Word(0xFFFF))
        static let Vic = (start: Word(0xD000), end: Word(0xD3FF))
        static let Cid = (start: Word(0xD400), end: Word(0xD7FF))
        static let Cia1 = (start: Word(0xDC00), end: Word(0xDCFF))
        static let Cia2 = (start: Word(0xDD00), end: Word(0xDDFF))
    }
    
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
        run()
        //startTimer()
    }
    
    func run() {
        DispatchQueue.global(qos: .userInteractive).async {
            while true {
                let startTime = DispatchTime.now()
                for _ in 0..<10 {
                    self.clock()
                }
                let endTime = DispatchTime.now()
                self.elapsedTime = Int((endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1000)
                usleep(2)
            }
        }
    }

    @objc func clock() {
        guard vic != nil else { return }
        if mos6502.cycles == 0 {
            mos6502.execute()
            vic?.clock()
        }
        if(cia1.clock()) == .irq {
            mos6502.INT = true
        }
        _ = cia2.clock()
        if(keyboard?.clock()) == .nmi {
            mos6502.NMI = true
        }
        mos6502.cycles -= 1
//        clockTimer?.invalidate()
//        clockTimer = nil
        //startTimer()
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
    
    func loadFile(_ fileName: String, device: Int, address: Int, verify: Bool, normal: Bool)->Int {
        print("Filename: \(fileName)")
        print("device: \(device)")
        print(String(format: "address: 0x%04X", address))
        print("verify: \(verify)")
        print("normal: \(normal)")
        if fileName == "$" {
            let dir = loadDirectory()
            for (index, byte) in dir.enumerated() {
                memory[address + index] = Byte(byte)
            }
            return address + dir.count
        }
        do {
            let directory = URL.documentsDirectory
            let fileURL = directory.appendingPathComponent(fileName)
            var data = try Data(contentsOf: fileURL)
            var startAddress = address
            if normal {
                // Startadresse extrahieren und verwenden falls normal
                startAddress = Int(Word(data[1]) << 8 | Word(data[0]))
            }
            data.removeSubrange(0..<2) // Adresse aus den Daten entfernen
            for (index, byte) in data.enumerated() {
                memory[startAddress + index] = Byte(byte)
            }
            return address + data.count
        } catch { let error = error
            print(error.localizedDescription)
            return -1
        }
        func loadDirectory()->[Byte] {
            var files = [String]()
            do {
                let directory = URL.documentsDirectory
                let items = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])
                files = items.map { $0.lastPathComponent }
                print(files)
            } catch { let error = error
                print(error.localizedDescription)
            }
            var directoryData = [Byte]()
            files.insert("HOLGER", at: 0)
            var nextAddress = address
            for file in files {
                nextAddress += 4 + file.count + 2 + 1 // 4 = 2 Byte nächse Adresse und 2 Byte Zeilennummer, 2 für Quotas, 1 für 0 am Ende
                directoryData.append(Byte(nextAddress & 0xff))
                directoryData.append(Byte(nextAddress >> 8))
                directoryData.append(0x0)
                directoryData.append(0x0) //2 Byte Zeilennummer
                directoryData.append("\"".utf8.first!)
                directoryData.append(contentsOf: file.utf8)
                directoryData.append("\"".utf8.first!)
                directoryData.append(0x0)
            }
            directoryData.append(0x0)
            directoryData.append(0x0)
            return directoryData
        }
    }
    
    func saveFile(_ fileName: String, device: Int, startAddress: Int, endAddress: Int)->FileError {
        print("Filename: \(fileName)")
        print("device: \(device)")
        print(String(format: "startAddress: 0x%04X", startAddress))
        print(String(format: "endAddress: 0x%04X", endAddress))
        do {
            let directory = URL.documentsDirectory
            let fileURL = directory.appendingPathComponent(fileName)
            // Startadresse als Header an den Anfang des Arrays schreiben
            var dataToWrite = Array(memory[startAddress..<endAddress])
            dataToWrite.insert(Byte(startAddress >> 8), at: 0)
            dataToWrite.insert(Byte(startAddress & 0xFF), at: 0)
            try Data(dataToWrite).write(to: fileURL)
        } catch { let error = error
            print(error.localizedDescription)
            return .fileNotFound
        }
        return .none
    }
    
    enum FileError: Int {
        case fileNotFound
        case none
    }
    
    func pokeMachineProgram() {
        poke(0x1000, [LDA_IM, 0x07, STA_AB, 0x11, 0xD0, BRK])
        func poke(_ address: Int, _ bytes: [Byte]) {
            for i in 0..<bytes.count {
                memory[address + i] = bytes[i]
            }
        }
    }
}

