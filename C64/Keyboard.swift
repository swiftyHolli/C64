//
//  Keyboard.swift
//  C64
//
//  Created by Holger Becker on 08.02.25.
//

import Foundation

class Keyboard: ObservableObject {
    
    var c64 = C64.shared
    
    private var keyPressedBuffer = -1
    private var clocksuntilRelaese = 0
    private var controlKey: ControlKey = .none
    
    enum ControlKey: Int {
        case none = 0
        case lShift = 15
        case rShift = 52
        case ctrl  = 2
        case commodore = 3
    }
        
    init() {
        c64.keyboard = self
    }
    
    func clock() {
        if keyPressedBuffer == -1 {
            c64.cia1.setPortB(value: 0xFF)
            return
        }
        if c64.cia1.getPortA() == 0x00 {
            c64.cia1.setPortB(value: PortBLinesForKey(keyPressedBuffer))
            if controlKey != .none {
                c64.cia1.setPortB(value: PortBLinesForKey(controlKey.rawValue) & c64.cia1.getPortB())
            }
            return
        }
        c64.cia1.setPortB(value: 0xFF)
        if (PortALinesForKey(keyPressedBuffer) ^ c64.cia1.getPortA() == 0) {
            c64.cia1.setPortB(value: PortBLinesForKey(keyPressedBuffer)  & c64.cia1.getPortB())
                              
        }
        if (PortALinesForKey(controlKey.rawValue) ^ c64.cia1.getPortA() == 0 && controlKey != .none) {
            c64.cia1.setPortB(value: PortBLinesForKey(controlKey.rawValue) & c64.cia1.getPortB())
        }

        if clocksuntilRelaese > 0 {
            clocksuntilRelaese -= 1
        } else {
            keyPressedBuffer = -1
            controlKey = .none
        }
    }
    
    func keyPressed(_ key: Int) {
        if key == ControlKey.lShift.rawValue {
            controlKey = .lShift
            return
        }
        if key == ControlKey.rShift.rawValue {
            controlKey = .rShift
            return
        }
        if keyPressedBuffer == -1 {
            keyPressedBuffer = key
            clocksuntilRelaese = 100000
        }
    }
        
    private func PortALinesForKey(_ key: Int) -> Byte {
        let pinNumber = (key / 8)
        return ~(0b0000_0001 << pinNumber)
    }
    private func PortBLinesForKey(_ key: Int) -> Byte {
        let pinNumber = key % 8
        return ~(0b0000_0001 << pinNumber)
    }
}
