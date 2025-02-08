//
//  ContentView.swift
//  C64 Emulator
//
//  Created by Holger Becker on 28.01.25.
//

import SwiftUI

struct C64View: View {
        
    var body: some View {
        VStack {
            TVScreen()
                .frame(width: 320, height: 200)
                .padding()
            KeyboardView()
        }
    }
}

struct KeyboardView: View {
    @ObservedObject var keyboard = Keyboard()
    
    var body: some View {
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
            Button("Enter") {keyboard.keyPressed(01)}

        }
    }
}
