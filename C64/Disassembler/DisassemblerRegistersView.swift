//
//  DisassemblerRegistersView.swift
//  C64
//
//  Created by Holger Becker on 07.03.25.
//

import SwiftUI

class RegistersViewModel: ObservableObject {
    @Published var PC: UInt16 = C64.shared.mos6502.PC
    @Published var A: UInt8 = C64.shared.mos6502.A
    @Published var X: UInt8 = C64.shared.mos6502.X
    @Published var Y: UInt8 = C64.shared.mos6502.Y
    @Published var SP: UInt16 = UInt16(C64.shared.mos6502.SP) + 0x100
}

struct DisassemblerRegistersView: View {
    var vm = RegistersViewModel()
    var body: some View {
        VStack {
            HStack {
                Text("PC: \(String(format: "%04X", vm.PC))")
                Text("A: \(String(format: "%02X", vm.A))")
                Text("X: \(String(format: "%02X", vm.X))")
                Text("Y: \(String(format: "%02X", vm.Y))")
                Text("SP: \(String(format: "%04X", vm.SP))")
            }
        }
    }
}

#Preview {
    DisassemblerRegistersView()
}
