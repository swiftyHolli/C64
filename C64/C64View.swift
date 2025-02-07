//
//  ContentView.swift
//  C64 Emulator
//
//  Created by Holger Becker on 28.01.25.
//

import SwiftUI

struct C64View: View {
    @State var length: Int = 10
    var c64Emulator = C64Emulator()
    var body: some View {
        VStack {
            TVScreen(vic: c64Emulator.c64.vic)
                .frame(width: 320, height: 200)
                .padding()
            Button("C64 Reset") {
                c64Emulator.writeScreen()
            }
        }
    }
}

#Preview {
    C64View()
}
