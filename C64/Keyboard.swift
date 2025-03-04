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
        case none       = 0
        case lShift     = 15
        case rShift     = 52
        case control    = 58
        case commodore  = 61
        case shiftLock  = 200 // mechanically locked key; parallel connected to the left shift key
        case restore    = 201 // restore button performes an NMI
    }
    
    enum JoystickButton: Byte {
        case none   = 0b0111_1111
        case up     = 0b0111_1110
        case down   = 0b0111_1101
        case left   = 0b0111_1011
        case right  = 0b0111_0111
        case fire   = 0b0110_1111
    }
    var button_Delete = false, button_Return = false, button_CursorLeft = false, button_F7 = false, button_F1 = false, button_F3 = false,
        button_F5 = false, button_CursorUp = false, button_3 = false, button_W = false, button_A = false, button_4 = false, button_Z = false,
        button_S = false, button_E = false, button_LeftShift = false, button_5 = false, button_R = false, button_D = false, button_6 = false,
        button_C = false, button_F = false, button_T = false, button_X = false, button_7 = false, button_Y = false, button_G = false,
        button_8 = false, button_B = false, button_H = false, button_U = false, button_V = false, button_9 = false, button_I = false,
        button_J = false, button_0 = false, button_M = false, button_K = false, button_O = false, button_N = false, button_Plus = false,
        button_P = false, button_L = false, button_Minus = false, button_Period = false, button_Colon = false, button_At = false,
        button_Comma = false, button_Pound = false, button_Asterisk = false, button_Semicolon = false, button_Home = false,
        button_RightShift = false, button_Equal = false, button_UpArrow = false, button_Slash = false, button_1 = false,
        button_LeftArrow = false, button_Control = false, button_2 = false, button_Space = false, button_Commodore = false,
        button_Q = false, button_Run = false, button_Restore = false, Joy2_Up = false, Joy2_Down = false, Joy2_Left = false, Joy2_Right = false,
        Joy2_Fire = false

    init() {
        c64.keyboard = self
    }
    
    func clock()->C64.Interrupts {
        c64.cia1.setPortB(value: portBLinesForPortAOutput(portA: c64.cia1.getPortA()))
        setJoystickPortA()
        if button_Restore {
            return .nmi
        } else {
            return .none
        }
    }
    
    func keyPressed(_ key: Int) {
        switch key {
        case 0x00:
            button_Delete = true
        case 0x01:
            button_Return = true
        case 0x02:
            button_CursorLeft = true
        case 0x03:
            button_F7 = true
        case 0x04:
            button_F1 = true
        case 0x05:
            button_F3 = true
        case 0x06:
            button_F5 = true
        case 0x07:
            button_CursorUp = true
        case 0x08:
            button_3 = true
        case 0x09:
            button_W = true
        case 0x0A:
            button_A = true
        case 0x0B:
            button_4 = true
        case 0x0C:
            button_Z = true
        case 0x0D:
            button_S = true
        case 0x0E:
            button_E = true
        case 0x0F:
            button_LeftShift.toggle()
            shift = button_LeftShift
        case 0x10:
            button_5 = true
        case 0x11:
            button_R = true
        case 0x12:
            button_D = true
        case 0x13:
            button_6 = true
        case 0x14:
            button_C = true
        case 0x15:
            button_F = true
        case 0x16:
            button_T = true
        case 0x17:
            button_X = true
        case 0x18:
            button_7 = true
        case 0x19:
            button_Y = true
        case 0x1A:
            button_G = true
        case 0x1B:
            button_8 = true
        case 0x1C:
            button_B = true
        case 0x1D:
            button_H = true
        case 0x1E:
            button_U = true
        case 0x1F:
            button_V = true
        case 0x20:
            button_9 = true
        case 0x21:
            button_I = true
        case 0x22:
            button_J = true
        case 0x23:
            button_0 = true
        case 0x24:
            button_M = true
        case 0x25:
            button_K = true
        case 0x26:
            button_O = true
        case 0x27:
            button_N = true
        case 0x28:
            button_Plus = true
        case 0x29:
            button_P = true
        case 0x2A:
            button_L = true
        case 0x2B:
            button_Minus = true
        case 0x2C:
            button_Period = true
        case 0x2D:
            button_Colon = true
        case 0x2E:
            button_At = true
        case 0x2F:
            button_Comma = true
        case 0x30:
            button_Pound = true
        case 0x31:
            button_Asterisk = true
        case 0x32:
            button_Semicolon = true
        case 0x33:
            button_Home = true
        case 0x34:
            button_RightShift.toggle()
            shift = button_RightShift
        case 0x35:
            button_Equal = true
        case 0x36:
            button_UpArrow = true
        case 0x37:
            button_Slash = true
        case 0x38:
            button_1 = true
        case 0x39:
            button_LeftArrow = true
        case 0x3A:
            button_Control.toggle()
            control = button_Control
        case 0x3B:
            button_2 = true
        case 0x3C:
            button_Space = true
        case 0x3D:
            button_Commodore.toggle()
            comodore = button_Commodore
        case 0x3E:
            button_Q = true
        case 0x3F:
            button_Run = true
        case 200:
            shiftLock.toggle()
            if shiftLock {
                button_LeftShift = true
            }
            else {
                button_LeftShift = false
            }
        case 201:
            button_Restore = true
            button_Run = true
        case 210:
            Joy2_Left = true
        case 211:
            Joy2_Right = true
        case 212:
            Joy2_Up = true
        case 213:
            Joy2_Down = true
        case 214:
            Joy2_Fire = true
        
        default:
            print("unknown keycode: \(key)")
            break
        }
    }
    func keyReleased(_ key: Int) {
        if key != 0x0F && key != 0x34 && !shiftLock {
            button_LeftShift = false
            button_RightShift = false
            shift = false
        }
        
        switch key {
        case 0x00:
            button_Delete = false
        case 0x01:
            button_Return = false
        case 0x02:
            button_CursorLeft = false
        case 0x03:
            button_F7 = false
        case 0x04:
            button_F1 = false
        case 0x05:
            button_F3 = false
        case 0x06:
            button_F5 = false
        case 0x07:
            button_CursorUp = false
        case 0x08:
            button_3 = false
        case 0x09:
            button_W = false
        case 0x0A:
            button_A = false
        case 0x0B:
            button_4 = false
        case 0x0C:
            button_Z = false
        case 0x0D:
            button_S = false
        case 0x0E:
            button_E = false
        case 0x0F:
            //button_LeftShift = false
            break
        case 0x10:
            button_5 = false
        case 0x11:
            button_R = false
        case 0x12:
            button_D = false
        case 0x13:
            button_6 = false
        case 0x14:
            button_C = false
        case 0x15:
            button_F = false
        case 0x16:
            button_T = false
        case 0x17:
            button_X = false
        case 0x18:
            button_7 = false
        case 0x19:
            button_Y = false
        case 0x1A:
            button_G = false
        case 0x1B:
            button_8 = false
        case 0x1C:
            button_B = false
        case 0x1D:
            button_H = false
        case 0x1E:
            button_U = false
        case 0x1F:
            button_V = false
        case 0x20:
            button_9 = false
        case 0x21:
            button_I = false
        case 0x22:
            button_J = false
        case 0x23:
            button_0 = false
        case 0x24:
            button_M = false
        case 0x25:
            button_K = false
        case 0x26:
            button_O = false
        case 0x27:
            button_N = false
        case 0x28:
            button_Plus = false
        case 0x29:
            button_P = false
        case 0x2A:
            button_L = false
        case 0x2B:
            button_Minus = false
        case 0x2C:
            button_Period = false
        case 0x2D:
            button_Colon = false
        case 0x2E:
            button_At = false
        case 0x2F:
            button_Comma = false
        case 0x30:
            button_Pound = false
        case 0x31:
            button_Asterisk = false
        case 0x32:
            button_Semicolon = false
        case 0x33:
            button_Home = false
        case 0x34:
            break
            //button_RightShift = false
        case 0x35:
            button_Equal = false
        case 0x36:
            button_UpArrow = false
        case 0x37:
            button_Slash = false
        case 0x38:
            button_1 = false
        case 0x39:
            button_LeftArrow = false
        case 0x3A:
            break
            //button_Control = false
        case 0x3B:
            button_2 = false
        case 0x3C:
            button_Space = false
        case 0x3D:
            break
            //button_Commodore = false
        case 0x3E:
            button_Q = false
        case 0x3F:
            button_Run = false
        case 201:
            button_Restore = false
            button_Run = false
        case 210:
            Joy2_Left = false
        case 211:
            Joy2_Right = false
        case 212:
            Joy2_Up = false
        case 213:
            Joy2_Down = false
        case 214:
            Joy2_Fire = false

        default:
            print("unknown keycode: \(key)")
            break
        }
    }

    func JoystickPort1Pressed(_ button: JoystickButton) {
        joystickButtonPressed = button
    }
    
    private func setJoystickPortA() {
        if Joy2_Up {
            c64.cia1.setPortA(value: JoystickButton.up.rawValue)
        }
        if Joy2_Down {
            c64.cia1.setPortA(value: JoystickButton.down.rawValue)
        }
        if Joy2_Left {
            c64.cia1.setPortA(value: JoystickButton.left.rawValue)
        }
        if Joy2_Right {
            c64.cia1.setPortA(value: JoystickButton.right.rawValue)
        }
        if Joy2_Fire {
            c64.cia1.setPortA(value: JoystickButton.fire.rawValue)
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
    
    func portBLinesForPortAOutput(portA: Byte)->Byte {
        var portBLines: Byte = 0xFF
        if ~portA & 0x01 > 0x0 {
            if button_Delete {
                portBLines &= 0xFE
            }
            if button_Return {
                portBLines &= 0xFD
            }
            if button_CursorLeft {
                portBLines &= 0xFB
            }
            if button_F7 {
                portBLines &= 0xF7
            }
            if button_F1 {
                portBLines &= 0xEF
            }
            if button_F3 {
                portBLines &= 0xDF
            }
            if button_F5 {
                portBLines &= 0xBF
            }
            if button_CursorUp {
                portBLines &= 0x7F
            }
        }
        if ~portA & 0x02 > 0x0 {
            if button_3 {
                portBLines &= 0xFE
            }
            if button_W {
                portBLines &= 0xFD
            }
            if button_A {
                portBLines &= 0xFB
            }
            if button_4 {
                portBLines &= 0xF7
            }
            if button_Z {
                portBLines &= 0xEF
            }
            if button_S {
                portBLines &= 0xDF
            }
            if button_E {
                portBLines &= 0xBF
            }
            if button_LeftShift {
                portBLines &= 0x7F
            }
        }
        if ~portA & 0x04 > 0x0 {
            if button_5 {
                portBLines &= 0xFE
            }
            if button_R {
                portBLines &= 0xFD
            }
            if button_D {
                portBLines &= 0xFB
            }
            if button_6 {
                portBLines &= 0xF7
            }
            if button_C {
                portBLines &= 0xEF
            }
            if button_F {
                portBLines &= 0xDF
            }
            if button_T {
                portBLines &= 0xBF
            }
            if button_X {
                portBLines &= 0x7F
            }
        }
        if ~portA & 0x08 > 0x0 {
            if button_7 {
                portBLines &= 0xFE
            }
            if button_Y {
                portBLines &= 0xFD
            }
            if button_G {
                portBLines &= 0xFB
            }
            if button_8 {
                portBLines &= 0xF7
            }
            if button_B {
                portBLines &= 0xEF
            }
            if button_H {
                portBLines &= 0xDF
            }
            if button_U {
                portBLines &= 0xBF
            }
            if button_V {
                portBLines &= 0x7F
            }
        }
        if ~portA & 0x10 > 0x0 {
            if button_9 {
                portBLines &= 0xFE
            }
            if button_I {
                portBLines &= 0xFD
            }
            if button_J {
                portBLines &= 0xFB
            }
            if button_0 {
                portBLines &= 0xF7
            }
            if button_M {
                portBLines &= 0xEF
            }
            if button_K {
                portBLines &= 0xDF
            }
            if button_O {
                portBLines &= 0xBF
            }
            if button_N {
                portBLines &= 0x7F
            }
        }
        if ~portA & 0x20 > 0x0 {
            if button_Plus {
                portBLines &= 0xFE
            }
            if button_P {
                portBLines &= 0xFD
            }
            if button_L {
                portBLines &= 0xFB
            }
            if button_Minus {
                portBLines &= 0xF7
            }
            if button_Period {
                portBLines &= 0xEF
            }
            if button_Colon {
                portBLines &= 0xDF
            }
            if button_At {
                portBLines &= 0xBF
            }
            if button_Comma {
                portBLines &= 0x7F
            }
        }
        if ~portA & 0x40 > 0x0 {
            if button_Pound {
                portBLines &= 0xFE
            }
            if button_Asterisk {
                portBLines &= 0xFD
            }
            if button_Semicolon {
                portBLines &= 0xFB
            }
            if button_Home {
                portBLines &= 0xF7
            }
            if button_RightShift {
                portBLines &= 0xEF
            }
            if button_Equal {
                portBLines &= 0xDF
            }
            if button_UpArrow {
                portBLines &= 0xBF
            }
            if button_Slash {
                portBLines &= 0x7F
            }
        }
        if ~portA & 0x80 > 0x0 {
            if button_1 {
                portBLines &= 0xFE
            }
            if button_LeftArrow {
                portBLines &= 0xFD
            }
            if button_Control {
                portBLines &= 0xFB
            }
            if button_2 {
                portBLines &= 0xF7
            }
            if button_Space {
                portBLines &= 0xEF
            }
            if button_Commodore {
                portBLines &= 0xDF
            }
            if button_Q {
                portBLines &= 0xBF
            }
            if button_Run {
                portBLines &= 0x7F
            }
        }
        return portBLines
    }
}
