//
//  Keyboard.swift
//  C64
//
//  Created by Holger Becker on 08.02.25.
//

import Foundation

class Keyboard: ObservableObject {
    
    @Published var shiftLock = false
    @Published var shift = false
    @Published var comodore = false
    @Published var control = false

    var c64 = C64.shared
    
    private var keyPressedBuffer = -1
    private var clocksuntilRelaese = 0
    private var controlKey: ControlKey = .none
    private var joystickButtonPressed = JoystickButton.none
    
    enum ControlKey: Int {
        case none = 0
        case lShift = 15
        case rShift = 52
        case control  = 58
        case commodore = 61
        case shiftLock = 200 // mechanically locked key; parallel connected to the left shift key
        case restore = 201 //restore button performes an NMI
    }
    
    enum JoystickButton: Byte {
        case none = 0b0111_1111
        case up = 0b0111_1110
        case down = 0b0111_1101
        case left = 0b0111_1011
        case right = 0b0111_0111
        case fire = 0b0110_1111
    }
        
    init() {
        c64.keyboard = self
    }
    
    func clock()->C64.Interrupts {
        if joystickButtonPressed != JoystickButton.none {
            c64.cia1.setPortA(value: joystickButtonPressed.rawValue)
        }
        if controlKey == .restore {
            controlKey = .none
            return .nmi
        }
        if keyPressedBuffer == -1 {
            c64.cia1.setPortB(value: 0xFF)
            return.none
        }
        if c64.cia1.getPortA() == 0x00 {
            c64.cia1.setPortB(value: PortBLinesForKey(keyPressedBuffer))
            if controlKey != .none {
                c64.cia1.setPortB(value: PortBLinesForKey(controlKey.rawValue) & c64.cia1.getPortB())
            }
            return .none
        }
        c64.cia1.setPortB(value: 0xFF)
        if (PortALinesForKey(keyPressedBuffer) ^ c64.cia1.getPortA() == 0) {
            c64.cia1.setPortB(value: PortBLinesForKey(keyPressedBuffer)  & c64.cia1.getPortB())
                              
        }
        if (PortALinesForKey(controlKey.rawValue) ^ c64.cia1.getPortA() == 0 && controlKey != .none) {
            if(controlKey != .none) {
                c64.cia1.setPortB(value: PortBLinesForKey(controlKey.rawValue) & c64.cia1.getPortB())
            }
        }
        if clocksuntilRelaese > 0 {
            clocksuntilRelaese -= 1
        } else {
            keyPressedBuffer = -1
            controlKey = .none
            joystickButtonPressed = .none
        }
        return .none
    }
    
    func keyPressed(_ key: Int) {
        if key == ControlKey.restore.rawValue {
            controlKey = .restore
        }
        if shiftLock {
            controlKey = .lShift
        }
        if key == ControlKey.lShift.rawValue {
            shift.toggle()
            controlKey = shift ? .lShift : .none
            return
        }
        if key == ControlKey.rShift.rawValue {
            shift.toggle()
            controlKey = shift ? .rShift : .none
            return
        }
        if key == ControlKey.commodore.rawValue {
            comodore.toggle()
            controlKey = comodore ? .commodore : .none
            return
        }
        if key == ControlKey.control.rawValue {
            control.toggle()
            controlKey = control ? .control : .none
           return
        }
        if key == ControlKey.shiftLock.rawValue {
            shiftLock.toggle()
            controlKey = shiftLock ? .lShift : .none
            shift = shiftLock
            return
        }
        if keyPressedBuffer == -1 {
            if !shiftLock { shift = false }
            control = false
            comodore = false
            keyPressedBuffer = key
            clocksuntilRelaese = 100000
        }
    }
    
    func JoystickPort1Pressed(_ button: JoystickButton) {
        joystickButtonPressed = button
    }
        
    func JoystickPort2Pressed(_ button: JoystickButton) {
        c64.cia1.setPortA(value: button.rawValue)
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
