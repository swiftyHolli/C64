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
            Button("A") {keyboard.keyPressed(10)}
            Button("B") {keyboard.keyPressed(28)}
        }
    }
}
