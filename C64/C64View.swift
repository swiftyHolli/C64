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
            Button("Poke") {
                c64.pokeMachineProgram()
            }
            
        }
        Spacer()
    }
}

