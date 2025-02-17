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
        NavigationStack {
            VStack {
                TVScreen()
                    //.frame(width: 320, height: 200)
                    .padding(.vertical, 30.0)
                HStack {
                    NavigationLink(destination: Floppy1541View()) {
                        Text("💾")
                            .font(.system(size: 55))
                    }
                }
                Spacer()
                NavigationLink("Disassembler", destination: DisassemblerView())
                KeyboardView(keyboard: Keyboard())
            }
            Spacer()
        }
    }
}

#Preview {
    C64View(c64: C64.shared)
}

