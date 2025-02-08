//
//  VICII.swift
//  C64
//
//  Created by Holger Becker on 06.02.25.
//

import SwiftUI

class VICII: ObservableObject {
    
    var c64 = C64.shared
    
    var videoBuffer = [Byte](repeating: 0, count: 320*200)
    @Published var canvasBuffer = [Byte](repeating: 0, count: 320*200)
    @Published var counter = 0
    struct Registers {
        var M0X: Byte = 0
        var M0Y: Byte = 0
        var M1X: Byte = 0
        var M1Y: Byte = 0
        var M2X: Byte = 0
        var M2Y: Byte = 0
        var M3X: Byte = 0
        var M3Y: Byte = 0
        var M4X: Byte = 0
        var M4Y: Byte = 0
        var M5X: Byte = 0
        var M5Y: Byte = 0
        var M6X: Byte = 0
        var M6Y: Byte = 0
        var M7X: Byte = 0
        var M7Y: Byte = 0
        var MXX8: Byte = 0  // MSB X coordinates
        var CR1: Byte = 0
        var RASTER: Byte = 0
        var LPX: Byte = 0
        var LPY: Byte = 0
        var MXE: Byte = 0
        var CR2: Byte = 0
        var MXYE: Byte = 0
        var MEMP: Byte = 0
        var INTR: Byte = 0  // interrupt register
        var INTM: Byte = 0  // interrupt enable
        var MXDP: Byte = 0  // sprite data priority
        var MXMC: Byte = 0  // sprite multicolor
        var MXXE: Byte = 0  // sprite X expansion
        var MXM: Byte = 0   // sprite-sprite collision
        var MXD: Byte = 0   // sprite-data collision
        var EC: Byte = 0    // frame color
        var B0C: Byte = 0   // background color 0
        var B1C: Byte = 0   // background color 1
        var B2C: Byte = 0   // background color 2
        var B3C: Byte = 0   // background color 3
        var MM0: Byte = 0   // sprite multicolor 0
        var MM1: Byte = 0   // sprite multicolor 1
        var M0C: Byte = 0   // color sprite 0
        var M1C: Byte = 0   // color sprite 1
        var M2C: Byte = 0   // color sprite 2
        var M3C: Byte = 0   // color sprite 3
        var M4C: Byte = 0   // color sprite 4
        var M5C: Byte = 0   // color sprite 5
        var M6C: Byte = 0   // color sprite 6
        var M7C: Byte = 0   // color sprite 7
    }
    
    private var registers = Registers()
    private var yScroll = 0
    private var raster = 0
    
    private var characterPixelBuffer = [Byte](repeating: 0, count: 8)
    private var characterLineBuffer = [[Byte]]()
    private var colorLineBuffer = [Byte](repeating: 0, count: 40)

    private var screenMemoryAddress = 0
    private var characterMemoryAddress = 0
    private let colorMemoryAddress: Int = 0xD800
    
    private var cyclCounter = 0
    
    init() {
        c64.vic = self
        print("VICII")
    }

    func setRegister(address: Int, byte: Byte) {
        let registerAdress = address & 0x3F
        switch registerAdress {
        case 0:
            registers.M0X = byte
        case 1:
            registers.M0Y = byte
        case 2:
            registers.M1X = byte
        case 3:
            registers.M1Y = byte
        case 4:
            registers.M2X = byte
        case 5:
            registers.M2Y = byte
        case 6:
            registers.M3X = byte
        case 7:
            registers.M3Y = byte
        case 8:
            registers.M4X = byte
        case 9:
            registers.M4Y = byte
        case 10:
            registers.M5X = byte
        case 11:
            registers.M5Y = byte
        case 12:
            registers.M6X = byte
        case 13:
            registers.M6Y = byte
        case 14:
            registers.M7X = byte
        case 15:
            registers.M7Y = byte
        case 16:
            registers.MXX8 = byte
        case 17:
            registers.CR1 = byte
            yScroll = Int(byte & 0x7)
            raster = Int(registers.RASTER)
            if(byte & 0x80 > 0) {
                raster += 0x100
            }
        case 18:
            registers.RASTER = byte
            raster = Int(byte)
            if(registers.CR1 & 0x80 > 0){
                raster += 0x100
            }
        case 19:
            registers.LPX = byte
        case 20:
            registers.LPY = byte
        case 21:
            registers.MXE = byte
        case 22:
            registers.CR2 = byte
        case 23:
            registers.MXYE = byte
        case 24:
            registers.MEMP = byte
            screenMemoryAddress = Int((byte & 0b1111_0000) >> 4) * 1024
            characterMemoryAddress = Int((byte & 0b0000_1110) >> 1) * 2048 - 4096
        case 25:
            registers.INTR = byte
        case 26:
            registers.INTM = byte
        case 27:
            registers.MXDP = byte
        case 28:
            registers.MXMC = byte
        case 29:
            registers.MXXE = byte
        case 30:
            registers.MXM = byte
        case 31:
            registers.MXD = byte
        case 32:
            registers.EC = byte
        case 33:
            registers.B0C = byte
        case 34:
            registers.B1C = byte
        case 35:
            registers.B2C = byte
        case 36:
            registers.B3C = byte
        case 37:
            registers.MM0 = byte
        case 38:
            registers.MM1 = byte
        case 39:
            registers.M0C = byte
        case 40:
            registers.M1C = byte
        case 41:
            registers.M2C = byte
        case 42:
            registers.M3C = byte
        case 43:
            registers.M4C = byte
        case 44:
            registers.M5C = byte
        case 45:
            registers.M6C = byte
        case 46:
            registers.M7C = byte
        default:
            print("write to unknown VIC register")
        }
    }
    
    func getRegister(address: Int)->Byte {
        let registerAddress = address & 0x3F
        switch registerAddress {
        case 0:
            return registers.M0X
        case 1:
            return registers.M0Y
        case 2:
            return registers.M1X
        case 3:
            return registers.M1Y
        case 4:
            return registers.M2X
        case 5:
            return registers.M2Y
        case 6:
            return registers.M3X
        case 7:
            return registers.M3Y
        case 8:
            return registers.M4X
        case 9:
            return registers.M4Y
        case 10:
            return registers.M5X
        case 11:
            return registers.M5Y
        case 12:
            return registers.M6X
        case 13:
            return registers.M6Y
        case 14:
            return registers.M7X
        case 15:
            return registers.M7Y
        case 16:
            return registers.MXX8
        case 17:
            if(raster & 0x100 > 0) {
                registers.CR1 |= 0x80
            }
            return registers.CR1
        case 18:
            registers.RASTER = Byte(raster & 0xFF)
            return registers.RASTER
        case 19:
            return registers.LPX
        case 20:
            return registers.LPY
        case 21:
            return registers.MXE
        case 22:
            return registers.CR2
        case 23:
            return registers.MXYE
        case 24:
            return registers.MEMP
        case 25:
            return registers.INTR
        case 26:
            return registers.INTM
        case 27:
            return registers.MXDP
        case 28:
            return registers.MXMC
        case 29:
            return registers.MXXE
        case 30:
            return registers.MXM
        case 31:
            return registers.MXD
        case 32:
            return registers.EC
        case 33:
            return registers.B0C
        case 34:
            return registers.B1C
        case 35:
            return registers.B2C
        case 36:
            return registers.B3C
        case 37:
            return registers.MM0
        case 38:
            return registers.MM1
        case 39:
            return registers.M0C
        case 40:
            return registers.M1C
        case 41:
            return registers.M2C
        case 42:
            return registers.M3C
        case 43:
            return registers.M4C
        case 44:
            return registers.M5C
        case 45:
            return registers.M6C
        case 46:
            return registers.M7C
        default:
            print("read from unknown VIC register")
            return 0
        }
    }

        
    func clock() {
        cyclCounter += 1
        if(cyclCounter > 62) {
            cyclCounter = 0
            if isBadLine() { badLine() }
            raster += 1
            if raster > 250 {
                raster = 0
            }
        }
        if(raster > 48 && raster < 248 && cyclCounter >= 16 && cyclCounter < 56) {
            decodeEightPixels()
        }
        if(raster == 247 && cyclCounter == 0) {
            canvasBuffer = videoBuffer
            //counter += 1
        }
    }
    
    func badLine() {
        // decode one line out from the video buffer
        // fill line buffer
        characterLineBuffer.removeAll(keepingCapacity: true)
        let characterLine = (raster - 48) / 8
        for characterIndex in 0..<40 {
            let character = c64.memory[(screenMemoryAddress + characterIndex + characterLine * 40)]
            colorLineBuffer[characterIndex] = c64.memory[(colorMemoryAddress + characterIndex + characterLine * 40)]
            for i in 0..<8 {
                characterPixelBuffer[i] = c64.characterRom[characterMemoryAddress + Int(character) * 8 + i]
            }
            characterLineBuffer.append(characterPixelBuffer)
        }
    }
    
    func decodeEightPixels() {
        let pixelLine = (raster - 48 + yScroll + 1) % 8
        let colorCode = colorLineBuffer[cyclCounter - 16]
        let characterLineBits = characterLineBuffer[cyclCounter - 16][pixelLine]
        for pixel in 0..<8 {
            let pixelColor = (characterLineBits & (0x80 >> pixel)) > 0 ?  colorCode : registers.B0C
            videoBuffer[(raster - 48) * 320 + (cyclCounter - 16) * 8 + pixel] = pixelColor
        }
    }
    
    func isBadLine()->Bool {
        raster >= 48 && raster < 247 && raster & 0x07 == yScroll && cyclCounter == 0
    }
}

