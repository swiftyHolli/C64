//
//  DisassemblerView.swift
//  C64
//
//  Created by Holger Becker on 16.02.25.
//

import SwiftUI

struct DisassemblerView: View {
    @ObservedObject var disassembler = DisassemblerViewModel()
    @State var selectedLines = Set<Disassembler.Line.ID>()
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Start", text: $disassembler.startAddressString)
                    TextField("End", text: $disassembler.endAddressString)
                }
                .padding()
                List(selection: $selectedLines) {
                    ForEach(disassembler.disassemblyText, id: \.id) { line in
                        HStack {
                            Text(line.addressString)
                            if line.type == .instruction {
                                Text(line.instruction)
                                Text(line.operand)
                            } else {
                                Text(line.dataString)
                            }
                        }
                    }
                }
                .font(.system(size: 16, weight: .regular, design: .monospaced))
            }
            HStack {
                Button("Reload") {
                    disassembler.disassemble()
                }
                Button("Data") {
                    disassembler.changeToData(selectedLines)
                    selectedLines.removeAll()
                }
                .disabled(selectedLines.isEmpty)
            }
        }
        .navigationTitle("Disassambly")
        .toolbar { EditButton() }
    }
}







#Preview(body: {
    DisassemblerView(disassembler: DisassemblerViewModel())
})
