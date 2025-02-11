//
//  CIA.swift
//  C64 Emulator
//
//  Created by Holger Becker on 02.02.25.
//

import Foundation

struct CIA {
    private struct Registers {
        static let PRA = 0x00
        static let PRB = 0x01
        static let DDRA = 0x02
        static let DDRB = 0x03
        static let TALO = 0x04
        static let TAHI = 0x05
        static let TBLO = 0x06
        static let TBHI = 0x07
        static let TOD10TH = 0x08
        static let TODSEC = 0x09
        static let TODMIN = 0x0A
        static let TODHR = 0x0B
        static let SDR = 0x0C
        static let ICR = 0x0D
        static let CRA = 0x0E
        static let CRB = 0x0F
        var values: [Byte] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }
    private struct IntMask {
        var underflowTimerA = false
        var underflowTimerB = false
        var clockAlarm = false
        var serialByteComplete = false
        var flagPin = false
    }
    
    private var registers = Registers()
    private var interruptMask = IntMask()
         
    private var latchA: Word = 0
    private var latchB: Word = 0
    private var timerA: Word = 0
    private var timerB: Word = 0
    private var todStarted = false

    init(address: Int) {
        print("CIA")
    }
    
    mutating func getRegister(address: Int)->Byte {
        switch address & 0x00FF{
        case Registers.PRA:
            return registers.values[Registers.PRA]
        case Registers.PRB:
            return registers.values[Registers.PRB]
        case Registers.DDRA:
            return registers.values[Registers.DDRA]
        case Registers.DDRB:
            return registers.values[Registers.DDRB]
        case Registers.TALO:
            return Byte(timerA & 0x0F)
        case Registers.TAHI:
            return Byte((timerB >> 8) & 0x0F)
        case Registers.TBLO:
            return Byte(timerA & 0x0F)
        case Registers.TBHI:
            return Byte((timerB >> 8) & 0x0F)
        case Registers.TOD10TH:
            return registers.values[Registers.TOD10TH]
        case Registers.TODSEC:
            return registers.values[Registers.TODSEC]
        case Registers.TODMIN:
            return registers.values[Registers.TODMIN]
        case Registers.TODHR:
            return registers.values[Registers.TODHR]
        case Registers.SDR:
            return registers.values[Registers.SDR]
        case Registers.ICR:
            let temp = registers.values[Registers.ICR]
            registers.values[Registers.ICR] = 0x00
            return temp
        case Registers.CRA:
            return registers.values[Registers.CRA]
        case Registers.CRB:
            return registers.values[Registers.CRB]
        default:
            print("read from unknown CIA register")
        }
        return 0
    }

    mutating func setRegister(address: Int, byte: Byte) {
        switch address & 0x00FF{
        case Registers.PRA:
            let inputLines = registers.values[Registers.PRA] & ~registers.values[Registers.DDRA]
            registers.values[Registers.PRA] = (byte & registers.values[Registers.DDRA]) | inputLines
        case Registers.PRB:
            let inputLines = registers.values[Registers.PRB] & ~registers.values[Registers.DDRB]
            registers.values[Registers.PRB] = (byte & registers.values[Registers.DDRB]) | inputLines
        case Registers.DDRA:
            registers.values[Registers.DDRA] = byte
        case Registers.DDRB:
            registers.values[Registers.DDRB] = byte
        case Registers.TALO:
            latchA |= Word(byte)
            if registers.values[Registers.CRA] & 0b0000_0001 > 0 { latchA &= 0x0F }
        case Registers.TAHI:
            latchA |= Word(byte) << 8
        case Registers.TBLO:
            latchB |= Word(byte)
            if registers.values[Registers.CRB] & 0b0000_0001 > 0 { latchB &= 0x0F }
        case Registers.TBHI:
            latchB |= Word(byte) << 8
        //TODO: Time of day registers
        case Registers.SDR:
            registers.values[Registers.SDR] = byte
        case Registers.ICR:
            if(byte & 0b1000_0000) > 0 {
                setMaskBits(mask: byte)
            } else {
                resetMaskBits(mask: byte)
            }
        case Registers.CRA:
            if(byte & 0b0001_0000 > 0) { timerA = latchA }
            registers.values[Registers.CRA] = byte & 0b1110_1111
        case Registers.CRB:
            if(byte & 0b0001_0000 > 0) { timerB = latchB }
            registers.values[Registers.CRB] = byte & 0b1110_1111
        default:
            print("write to unknown CIA register")
        }
        func setMaskBits(mask: Byte) {
            if(mask & 0b0000_0001 > 0) { interruptMask.underflowTimerA = true }
            if(mask & 0b0000_0010 > 0) { interruptMask.underflowTimerB = true }
            if(mask & 0b0000_0100 > 0) { interruptMask.clockAlarm = true }
            if(mask & 0b0000_1000 > 0) { interruptMask.serialByteComplete = true }
            if(mask & 0b0001_0000 > 0) { interruptMask.flagPin = true }
        }
        func resetMaskBits(mask: Byte) {
            if(mask & 0b0000_0001 > 0) { interruptMask.underflowTimerA = false }
            if(mask & 0b0000_0010 > 0) { interruptMask.underflowTimerB = false }
            if(mask & 0b0000_0100 > 0) { interruptMask.clockAlarm = false }
            if(mask & 0b0000_1000 > 0) { interruptMask.serialByteComplete = false }
            if(mask & 0b0001_0000 > 0) { interruptMask.flagPin = false }
        }
    }
    
    mutating func setPortA(value: Byte) {
        registers.values[Registers.PRA] = ~registers.values[Registers.DDRA] & value
    }
    mutating func setPortB(value: Byte) {
        registers.values[Registers.PRB] = ~registers.values[Registers.DDRB] & value
    }
    func getPortA() -> Byte {
        return registers.values[Registers.PRA]
    }
    func getPortB() -> Byte {
        return registers.values[Registers.PRB]
    }

    mutating func clock()->Bool {
        handleTimerA()
        //handleTimerB()
        return registers.values[Registers.ICR] & 0b1000_0000 > 0
    }
    
    mutating private func handleTimerA() {
        if(registers.values[Registers.CRA] & 0b0000_0001 > 0) {
            // Timer started
            if timerA > 0 { timerA -= 1 }
            if(timerA == 0) {
                if(registers.values[Registers.CRA] & 0b0000_1000 == 0) {
                    timerA = latchA
                    if(interruptMask.underflowTimerA) {
                        interruptTimerA()
                    }
                }
            }
        }
        func interruptTimerA() {
            registers.values[Registers.ICR] |= 0b0000_0001
            registers.values[Registers.ICR] |= 0b1000_0000
        }
    }
}
