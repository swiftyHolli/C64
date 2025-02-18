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
                controlView
                .padding()
                List(selection: $selectedLines) {
                    ForEach(disassembler.disassemblyText, id: \.id) { line in
                        DisassemblerLineView(line: line, vm: disassembler)
                    }
                }
                .listStyle(.plain)
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
    
    var controlView: some View {
        VStack {
            HStack {
                TextField("Start", text: $disassembler.startAddressString)
                TextField("End", text: $disassembler.endAddressString)
                Button("⇢") {
                    disassembler.makeStep()
                }
                .padding(.horizontal)
                Button("➞") {
                    disassembler.resetHalt()
                }
                .padding(.horizontal)
            }
        }
    }
    
    struct DisassemblerLineView: View {
        let line: Disassembler.Line
        @ObservedObject var vm: DisassemblerViewModel
        var body: some View {
            HStack {
                Text(line.addressString)
                    .background(line.isBreakpoint ? .red : .clear)
                if line.type == .instruction {
                    Text(line.instruction)
                    Text(line.operand)
                        .swipeActions {
                            Button("BreakPoint") {
                                vm.addRemoveBreakpoint(line.id)
                            }
                        }
                        .tint(.red)
                } else {
                    Text(vm.dataString(line.id))
                        .swipeActions {
                            Button(line.dataView == .ascii ? "Hex" :"ASCII") {
                                vm.changeDataView(line.id)
                            }
                        }
                        .tint(.blue)
                }
            }
            .background(line.stepMarker ? .yellow : .clear)
        }
    }
}







#Preview(body: {
    DisassemblerView(disassembler: DisassemblerViewModel())
})
