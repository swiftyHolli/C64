//
//  KeyboardButton.swift
//  C64
//
//  Created by Holger Becker on 11.02.25.
//

import SwiftUI

struct KeyboardButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    let padding: CGFloat
    
    init(cornerRadius: CGFloat = 3, padding: CGFloat = 6) {
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct KeyboardButton: View {
    @ObservedObject var keyboard: Keyboard
    var label: String
    var labelShift: String
    var labelComodore: String
    var colorComodore: Byte
    var labelControl: String
    var colorControl: Byte
    var code: Int
    
    init(vm: Keyboard,
         _ label: String,
         _ labelShift: String,
         _ labelComodore: String,
         _ labelControl: String,
         _ colorComodore: Byte,
         _ colorControl: Byte,
         code: Int) {
        self.keyboard = vm
        self.label = label
        self.labelShift = labelShift
        self.labelComodore = labelComodore
        self.labelControl = labelControl
        self.colorComodore = colorComodore
        self.colorControl = colorControl
        self.code = code
    }
    var body: some View {
        Button {
            keyboard.keyPressed(code)
        } label: {
            if keyboard.shift {
                ButtonText(labelShift)
            }
            else if keyboard.comodore {
                if labelComodore == "◉" {
                    ButtonText(labelComodore)
                        .foregroundStyle(Color(cgColor: colorFromCode(colorComodore)))
                }
                else {
                    ButtonText(labelComodore)
                }
            }
            else if keyboard.control {
                if labelControl == "◉" {
                    ButtonText(labelControl)
                        .foregroundStyle(Color(cgColor: colorFromCode(colorControl)))
                }
                else {
                    ButtonText(labelControl)
                }
            }
            else{
                ButtonText(label)
            }
        }
        .foregroundStyle(.white)
        .buttonStyle(KeyboardButtonStyle())
    }
    struct ButtonText: View {
        var label: String
        init(_ label: String) {
            self.label = label
        }
        var body: some View {
            Text(label)
                .font(Font.custom("Bescii-Mono", size: 14))
                .padding(6)
                .background(Color.gray)
                .cornerRadius(3)
        }
    }
}

struct ControlButton: View {
    @ObservedObject var keyboard: Keyboard
    var body: some View {
        Button {
            keyboard.keyPressed(58)
        } label: {
            Text("CTRL")
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .padding(4.5)
                .background(keyboard.control ? Color.blue : Color.gray)
                .cornerRadius(3)
        }
    }
}

struct ShiftButton: View {
    @ObservedObject var keyboard: Keyboard
    var code: Int
    var body: some View {
        Button {
            keyboard.keyPressed(code)
        } label: {
            Image(systemName: "shift")
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .padding(4.5)
                .background(keyboard.shift ? Color.blue : Color.gray)
                .cornerRadius(3)
        }
    }
}

struct ShiftLockButton: View {
    @ObservedObject var keyboard: Keyboard
    var body: some View {
        Button {
            keyboard.keyPressed(10)
        } label: {
            Image(systemName: "capslock")
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .padding(4.5)
                .background(keyboard.shiftLock ? Color.blue : Color.gray)
                .cornerRadius(3)
        }
    }
}

struct ComodoreButton: View {
    @ObservedObject var keyboard: Keyboard
    var body: some View {
        Button {
            keyboard.keyPressed(61)
        } label: {
            Text("C=")
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .padding(4.5)
                .background(keyboard.shiftLock ? Color.blue : Color.gray)
                .cornerRadius(3)
        }
    }
}
#Preview {
    let keyboard = Keyboard()
    HStack(alignment: .center, spacing: 2) {
        Spacer()
        ControlButton(keyboard: keyboard)
        KeyboardButton(vm: keyboard,"A", "B", "◉", "◉", 02, 08, code: 0)
        Button("HOME") { }
        Button("B") { }

        Button("5") { }
        Spacer()
    }
    .buttonStyle(KeyboardButtonStyle())
}
