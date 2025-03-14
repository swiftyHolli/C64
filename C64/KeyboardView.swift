//
//  KeyboardView.swift
//  C64
//
//  Created by Holger Becker on 11.02.25.
//

import SwiftUI

struct KeyboardView: View {
    @ObservedObject var keyboard = Keyboard()
    
    var body: some View {
        VStack(spacing: 1) {
            HStack {
                Joystick2View(vm: keyboard, port: 1)
                Joystick1View(vm: keyboard, port: 1)
            }
            HStack(spacing: 1) {
                KeyboardButton(vm: keyboard, "Home", "Clear", "Clear", " ",0 , 0, code: 51)
                Spacer()
                KeyboardButton(vm: keyboard, "Restore", "Restore", "Restore", " ",0 , 0, code: 201)
                KeyboardButton(vm: keyboard, "Del", "Ins", "Ins", " ",0 , 0, code: 00)
            }
            HStack(spacing: 1){
                KeyboardButton(vm: keyboard, "←", "←", "←", " ",0 , 0, code: 57)
                KeyboardButton(vm: keyboard, "1", "!", "◉", "◉", 08, 00, code: 56)
                KeyboardButton(vm: keyboard, "2", "\"", "◉", "◉", 09 , 01, code: 59)
                KeyboardButton(vm: keyboard, "3", "#", "◉", "◉", 10 , 02 , code: 08)
                KeyboardButton(vm: keyboard, "4", "$", "◉", "◉", 11 , 03 , code: 11)
                KeyboardButton(vm: keyboard, "5", "%", "◉", "◉", 12 , 04 , code: 16)
                KeyboardButton(vm: keyboard, "6", "&", "◉", "◉", 13 , 05 , code: 19)
                KeyboardButton(vm: keyboard, "7", "/", "◉", "◉", 14 , 06 , code: 24)
                KeyboardButton(vm: keyboard, "8", "(", "◉", "◉", 15 , 07 , code: 27)
                KeyboardButton(vm: keyboard, "9", ")", "◉", "◉", 16 , 08 , code: 32)
                KeyboardButton(vm: keyboard, "0", ")", "◉", "◉", 17 , 09 , code: 35)
                KeyboardButton(vm: keyboard, "+", "+", "▒", " ", 0 , 0 , code: 40)
                KeyboardButton(vm: keyboard, "-", "│", "🮌", " ", 0 , 0 , code: 43)
                KeyboardButton(vm: keyboard, "£", "◤", "🮏", " ", 0 , 0 , code: 48)
            }
            HStack(spacing: 1) {
                ControlButton(keyboard: keyboard)
                KeyboardButton(vm: keyboard, "Q", "•", "├", "↓", 00, 00, code: 62)
                KeyboardButton(vm: keyboard, "W", "○", "┤", " ", 00, 00, code: 09)
                KeyboardButton(vm: keyboard, "E", "▔", "┴", " ", 00, 00, code: 14)
                KeyboardButton(vm: keyboard, "R", "▁", "┬", " ", 00, 00, code: 17)
                KeyboardButton(vm: keyboard, "T", "▏", "▔", " ", 00, 00, code: 22)
                KeyboardButton(vm: keyboard, "Y", "▕", "", " ", 00, 00, code: 25)
                KeyboardButton(vm: keyboard, "U", "╭", "", " ", 00, 00, code: 30)
                KeyboardButton(vm: keyboard, "I", "╮", "▄", " ", 00, 00, code: 33)
                KeyboardButton(vm: keyboard, "O", "", "▃", " ", 00, 00, code: 38)
                KeyboardButton(vm: keyboard, "P", "", "▂", " ", 00, 00, code: 41)
                KeyboardButton(vm: keyboard, "@", "", "▁", " ", 00, 00, code: 46)
                KeyboardButton(vm: keyboard, "*", "", "▁", " ", 00, 00, code: 49)
            }

            HStack(spacing: 1) {
                ShiftLockButton(keyboard: keyboard)
                KeyboardButton(vm: keyboard,"A", "♠", "┌", " ",0 , 0, code: 10)
                KeyboardButton(vm: keyboard,"S", "♥", "┐", " ",0 , 0, code: 13)
                KeyboardButton(vm: keyboard,"D", "", "▗", " ",0 , 0, code: 18)
                KeyboardButton(vm: keyboard,"F", "", "▖", " ",0 , 0, code: 21)
                KeyboardButton(vm: keyboard,"G", "", "▏", " ",0 , 0, code: 26)
                KeyboardButton(vm: keyboard,"H", "", "▎", " ",0 , 0, code: 29)
                KeyboardButton(vm: keyboard,"J", "╰", "▍", " ",0 , 0, code: 34)
                KeyboardButton(vm: keyboard,"K", "╯", "▌", " ",0 , 0, code: 37)
                KeyboardButton(vm: keyboard,"L", "", "", " ",0 , 0, code: 42)
                KeyboardButton(vm: keyboard,":", "[", "[", " ",0 , 0, code: 45)
                KeyboardButton(vm: keyboard,";", "]", "]", " ",0 , 0, code: 50)
                KeyboardButton(vm: keyboard,"=", "=", "=", " ",0 , 0, code: 53)
                KeyboardButton(vm: keyboard,"↲", "↲", "↲", " ",0 , 0, code: 01)
                
            }

            HStack(spacing: 1) {
                ShiftButton(keyboard: keyboard, code: 15)
                KeyboardButton(vm: keyboard,"Z", "♦", "└", " ",0 , 0, code: 12)
                KeyboardButton(vm: keyboard,"X", "♣", "┘", " ",0 , 0, code: 23)
                KeyboardButton(vm: keyboard,"C", "", "▝", " ",0 , 0, code: 20)
                KeyboardButton(vm: keyboard,"V", "╳", "▘", " ",0 , 0, code: 31)
                KeyboardButton(vm: keyboard,"B", "", "▚", " ",0 , 0, code: 28)
                KeyboardButton(vm: keyboard,"N", "╱", "", " ",0 , 0, code: 39)
                KeyboardButton(vm: keyboard,"M", "╲", "▕", " ",0 , 0, code: 36)
                KeyboardButton(vm: keyboard,",", "<", "<", " ",0 , 0, code: 47)
                KeyboardButton(vm: keyboard,".", ">", ">", " ",0 , 0, code: 44)
                KeyboardButton(vm: keyboard,"/", "?", "?", " ",0 , 0, code: 44)
                ShiftButton(keyboard: keyboard, code: 52)
            }
            HStack(spacing: 2) {
                ComodoreButton(keyboard: keyboard)
                KeyboardButton(vm: keyboard,"Stop", "Load", "Load", " ",0 , 0, code: 63)
                KeyboardButton(vm: keyboard,"           ", "           ", "           ", "           ",0 , 0, code: 60)
                KeyboardButton(vm: keyboard,"↓", "↑", "↑", " ",0 , 0, code: 07)
                KeyboardButton(vm: keyboard,"→", "←", "←", " ",0 , 0, code: 02)
            }

            .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(KeyboardButtonStyle())
        .padding()
    }
    
    struct Joystick2View: View {
        var vm: Keyboard
        var port: Int = 0
        var body: some View {
            VStack {
                KeyboardButton(vm: vm,"↑", "↑", "↑", "↑",0 , 0, code: 212)
                HStack {
                    KeyboardButton(vm: vm,"←", "←", "←", " ",0 , 0, code: 210)
                    KeyboardButton(vm: vm,"♦", "♦", "♦", " ",0 , 0, code: 214)
                    KeyboardButton(vm: vm,"→", "→", "→", " ",0 , 0, code: 211)
                }
                KeyboardButton(vm: vm,"↓", "↓", "↓", "↓",0 , 0, code: 213)
            }
        }
    }
    struct Joystick1View: View {
        var vm: Keyboard
        var port: Int = 0
        var body: some View {
            VStack {
                KeyboardButton(vm: vm,"↑", "↑", "↑", "↑",0 , 0, code: 217)
                HStack {
                    KeyboardButton(vm: vm,"←", "←", "←", " ",0 , 0, code: 215)
                    KeyboardButton(vm: vm,"♦", "♦", "♦", " ",0 , 0, code: 219)
                    KeyboardButton(vm: vm,"→", "→", "→", " ",0 , 0, code: 216)
                }
                KeyboardButton(vm: vm,"↓", "↓", "↓", "↓",0 , 0, code: 218)
            }
        }
    }
}

#Preview {
    KeyboardView()
}
