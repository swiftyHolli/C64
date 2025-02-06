//
//  CIA.swift
//  C64 Emulator
//
//  Created by Holger Becker on 02.02.25.
//

import Foundation

class CIA {
    var c64: C64!
    var address: Int
    
    var chipSelect = false
    var write = false
    
    init(address: Int) {
        print("CIA")
        self.address = address
    }
    let PRA = 0x00
    let PRB = 0x01
    
    let DDRA = 0x02
    let DDRB = 0x03
    
    let TALO = 0x04 // timer A low register
    let TAHI = 0x05 // timer A high register
    
    let TBLO = 0x06 // timer B low register
    let TBHI = 0x07 // timer B high register

    let TOD10TH = 0x08 // 10th of seconds register
    let TODSEC = 0x09 // seconds register
    let TODMIN = 0x0A // minutes register
    let TODHR = 0x0B // hours AM/PM register
    
    let SDR = 0x0C // seriell data register
    let ICR = 0x0D // interrupt control register
    
    let CRA = 0x0E // control register A
    let CRB = 0x0F // control register B
    
    private var latchA: Word = 0
    private var latchB: Word = 0
    
    private var timerAStart = false
    private var timerBStart = false
    
    private var timerAOnce = false
    private var timerBOnce = false
    
    private var timerAIntEnable = false
    private var timerBIntEnable = false

    private var timerALoad = false
    private var timerBLoad = false
    
    private var timerACountValue: Int = 0
    private var timerBCountValue: Int = 0

    var portA: Byte {
        get {
            return c64.memory[Int(address) + PRA]
        }
        set {
            let inputLines = c64.memory[Int(address) + PRA] & ~c64.memory[Int(address) + DDRA]
            c64.memory[Int(address) + PRA] = (newValue & c64.memory[Int(address) + DDRA]) | inputLines
        }
    }
    var portB: Byte {
        get {
            return c64.memory[Int(address) + PRB]
        }
        set {
            let inputLines = c64.memory[Int(address) + PRB] & ~c64.memory[Int(address) + DDRB]
            c64.memory[Int(address) + PRB] = (newValue & c64.memory[Int(address) + DDRB]) | inputLines
        }
    }
    
    func clock() {
        setLatchOfTimerA()
        readControlRegisterTimerA()
        handleTimerA()
        //handleTimerB()
        write = false
    }
    
    private func setLatchOfTimerA() {
        if chipSelect {
            if write {
                write = false
                switch c64.mos6502.addressBus {
                case 0xDC04:
                    latchA |= Word(c64.memory[address + TALO])
                    print(latchA)
                case 0xDC05:
                    latchA |= Word(c64.memory[address + TAHI]) << 8
                    print(latchA)
                case 0xDC0D:
                    timerAIntEnable = c64.memory[address + ICR] | 0b00000001 > 0
                default:
                    return
                }
            }
            else {
                switch c64.mos6502.addressBus {
                case 0xDC0D:
                    c64.memory[address + ICR] = 0
                default:
                    return
                }
            }
        }
    }
    private func readControlRegisterTimerA() {
        timerAStart = c64.memory[address + CRA] & 0b00000001 > 0
        timerAOnce = c64.memory[address + CRA] & 0b00001000 > 0
        timerALoad = c64.memory[address + CRA] & 0b00010000 > 0
    }
    private func handleTimerA() {
        if timerALoad {
            timerALoad = false
            c64.memory[address + CRA] &= 0b11101111
            timerACountValue = Int(latchA)
        }
        if timerAStart {
            timerACountValue -= 1
            if timerACountValue <= 0 {
                if !timerAOnce {
                    timerACountValue = Int(latchA)
                }
                if timerAIntEnable {
                    c64.mos6502.INT = true
                    c64.memory[0xDC0D] |= 0b00000001
                }
            }
        }
    }
    
    
}
