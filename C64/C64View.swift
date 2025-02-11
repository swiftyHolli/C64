//
//  ContentView.swift
//  C64 Emulator
//
//  Created by Holger Becker on 28.01.25.
//

import SwiftUI

struct C64View: View {
    @ObservedObject var c64 = C64.shared
    var body: some View {
        VStack {
            TVScreen()
                .frame(width: 320, height: 200)
                .padding()
            KeyboardView()
        }
        Spacer()
    }
}

struct KeyboardView: View {
    @ObservedObject var keyboard = Keyboard()
    
    var body: some View {
        HStack {
            Button("<-") {keyboard.keyPressed(00)}
            Button("1") {keyboard.keyPressed(56)}
            Button("2") {keyboard.keyPressed(59)}
            Button("3") {keyboard.keyPressed(08)}
            Button("4") {keyboard.keyPressed(11)}
            Button("5") {keyboard.keyPressed(16)}
            Button("6") {keyboard.keyPressed(19)}
            Button("7") {keyboard.keyPressed(24)}
            Button("8") {keyboard.keyPressed(27)}
            Button("9") {keyboard.keyPressed(32)}
            Button("0") {keyboard.keyPressed(35)}
        }
        HStack {
            Button("Q") {keyboard.keyPressed(62)}
            Button("W") {keyboard.keyPressed(09)}
            Button("E") {keyboard.keyPressed(14)}
            Button("R") {keyboard.keyPressed(17)}
            Button("T") {keyboard.keyPressed(22)}
            Button("Y") {keyboard.keyPressed(25)}
            Button("U") {keyboard.keyPressed(30)}
            Button("I") {keyboard.keyPressed(33)}
            Button("O") {keyboard.keyPressed(38)}
            Button("P") {keyboard.keyPressed(41)}
        }
        HStack {
            Button("A") {keyboard.keyPressed(10)}
            Button("S") {keyboard.keyPressed(13)}
            Button("D") {keyboard.keyPressed(18)}
            Button("F") {keyboard.keyPressed(21)}
            Button("G") {keyboard.keyPressed(26)}
            Button("H") {keyboard.keyPressed(29)}
            Button("J") {keyboard.keyPressed(34)}
            Button("K") {keyboard.keyPressed(37)}
            Button("L") {keyboard.keyPressed(42)}
            Button(":") {keyboard.keyPressed(45)}
            Button(";") {keyboard.keyPressed(50)}
            Button("=") {keyboard.keyPressed(53)}
            Button("Enter") {keyboard.keyPressed(01)}

        }
        HStack {
            Button("Y") {keyboard.keyPressed(25)}
            Button("X") {keyboard.keyPressed(23)}
            Button("C") {keyboard.keyPressed(20)}
            Button("V") {keyboard.keyPressed(31)}
            Button("B") {keyboard.keyPressed(28)}
            Button("N") {keyboard.keyPressed(39)}
            Button("M") {keyboard.keyPressed(36)}
            Button(",") {keyboard.keyPressed(47)}
            Button(".") {keyboard.keyPressed(44)}
            Button("-") {keyboard.keyPressed(43)}
        }
        HStack {
            Button("Shift") {keyboard.keyPressed(15)}
            Button("Space") {keyboard.keyPressed(60)}
            Button("Shift") {keyboard.keyPressed(52)}
        }
    }
}
