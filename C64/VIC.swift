//
//  VIC-II.swift
//  C64 Emulator
//
//  Created by Holger Becker on 02.02.25.
//

import SwiftUI

class VIC: ObservableObject {
    var c64: C64!
    var address: Int
    var timerVic = Timer()
    
    var videoBuffer = [CGColor](repeating: UIColor.blue.cgColor, count: 320 * 200)
    @Published var canvasBuffer = [CGColor](repeating: UIColor.blue.cgColor, count: 320 * 200)
    
    init(address: Word) {
        print("VIC")
        self.address = Int(address)
        timerVic = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(rasterInterrupt), userInfo: "vic", repeats: true)
    }

    let controlRegister1:   Int = 0x11
    let controlRegister2:   Int = 0x16
    let memoryPointers:     Int = 0x18
    let RASTERadress:       Int = 0x12
    let BackgroundColor0:   Int = 0x21
    
    let xRange = 343
    let yRange = 250
    
    let firstLine = 51
    let lastLine = 250
    
    // 312 Rasterzeilen 65ms/Zeile
    
    private var screenMemoryAddress: Int {Int((c64.memory[address + memoryPointers] & 0b11100000) >> 5) * 1024}
    private var characterDataAddress: Int {Int((c64.memory[address + memoryPointers] & 0b00001110) >> 1) * 1024}
    private let colorMemoryAddress: Int = 0xD800
    
    var lastInstructionTime = Date()
    var timeSinceLastInstruction = 0.0
    var timeCorrection = 0.0
    
    var xCoordinate = 0
    var yCoordinate = 0

    var lineNumber = 0
    @objc func rasterInterrupt() {
        lineNumber += 1
        if(lineNumber > yRange) {
            lineNumber = 0
        }
        if(lineNumber > 0xFF) {
            c64.memory[address + controlRegister1] = c64.memory[address + controlRegister1] | 0x80
        }
        else {
            c64.memory[address + controlRegister1] = c64.memory[address + controlRegister1] & 0x7F
        }
        c64.memory[address + RASTERadress] = Byte(lineNumber & 0xFF)
        let yScroll = Int(c64.memory[address + controlRegister1] & 0b00000111)
        
        
        if(lineNumber > 50 && lineNumber <= 251) {
            let scanline = lineNumber - 51
            if(scanline % 8 == yScroll) {
                fillVideoBuffer(forScanline: scanline)
            }
        }
        if(lineNumber == 201) {
            canvasBuffer = videoBuffer
        }
    }
    
    //executes in bad lines
    func fillVideoBuffer(forScanline scanline: Int) {
        let RSEL = c64.memory[address + controlRegister1] & 0b00001000 > 0
        let CSEL = c64.memory[address + controlRegister2] & 0b00001000 > 0
        c64.mos6502.stopTimer()
        //video memory bank set bank for test
        c64.memory[address + memoryPointers] = 0b00100000
        
        //Character Mode
        let startAddress = scanline / 8 * 40
        
        for characterIndex in startAddress..<startAddress + 40 {
            let characterCode = c64.memory[screenMemoryAddress + characterIndex]
            let colorCode = c64.memory[colorMemoryAddress + characterIndex]
            for rowIndex in 0..<8 {
                let characterLineBits = c64.characterRom[(Int(characterCode) * 8) + rowIndex]
                // first all black for test
                for pixel in 0..<8 {
                    let pixelColor = (characterLineBits & (0x80 >> pixel)) > 0 ?  colorFromCode(colorCode) : colorFromCode(c64.memory[address + BackgroundColor0])
                    //später aus dem Color RAM
                    videoBuffer[characterIndex % 40 * 8 + rowIndex * 40 * 8 + characterIndex / 40 * 2560 + pixel] = pixelColor
                }
            }
        }
        c64.mos6502.startTimer()
        func colorFromCode(_ code: Byte)->CGColor {
            switch code & 0x0F {
            case 0:
                return CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            case 1:
                return CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            case 2:
                return CGColor(red: 104 / 255, green: 55 / 255, blue: 43 / 255, alpha: 1.0)
            case 3:
                return CGColor(red: 112 / 255, green: 164 / 255, blue: 178 / 255, alpha: 1.0)
            case 4:
                return CGColor(red: 111 / 255, green: 61 / 255, blue: 134 / 255, alpha: 1.0)
            case 5:
                return CGColor(red: 88 / 255, green: 141 / 255, blue: 67 / 255, alpha: 1.0)
            case 6:
                return CGColor(red: 53 / 255, green: 40 / 255, blue: 178 / 121, alpha: 1.0)
            case 7:
                return CGColor(red: 184 / 255, green: 199 / 255, blue: 111 / 255, alpha: 1.0)
            case 8:
                return CGColor(red: 112 / 255, green: 79 / 255, blue: 37 / 255, alpha: 1.0)
            case 9:
                return CGColor(red: 67 / 255, green: 57 / 255, blue: 0 / 255, alpha: 1.0)
            case 10:
                return CGColor(red: 154 / 255, green: 103 / 255, blue: 89 / 255, alpha: 1.0)
            case 11:
                return CGColor(red: 68 / 255, green: 68 / 255, blue: 68 / 255, alpha: 1.0)
            case 12:
                return CGColor(red: 108 / 255, green: 108 / 255, blue: 108 / 255, alpha: 1.0)
            case 13:
                return CGColor(red: 154 / 255, green: 210 / 255, blue: 132 / 255, alpha: 1.0)
            case 14:
                return CGColor(red: 108 / 255, green: 94 / 255, blue: 181 / 255, alpha: 1.0)
            case 15:
                return CGColor(red: 149 / 255, green: 149 / 255, blue: 149 / 255, alpha: 1.0)
            default:
                return UIColor.blue.cgColor
            }
        }
    }
}
