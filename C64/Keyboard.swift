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
    
    enum ControlKey: Int {
        case none = 0
        case shift = 1
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
        if c64.cia1.getPortA() == 0x00 || (PortALinesForKey(keyPressedBuffer) ^ c64.cia1.getPortA() == 0) {
            c64.cia1.setPortB(value: PortBLinesForKey(keyPressedBuffer))
        }
        else {
            c64.cia1.setPortB(value: 0xFF)
        }
        if clocksuntilRelaese > 0 {
            clocksuntilRelaese -= 1
        } else {
            keyPressedBuffer = -1
        }
    }
    
    func keyPressed(_ key: Int, ctrlKey: ControlKey = .none) {
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
