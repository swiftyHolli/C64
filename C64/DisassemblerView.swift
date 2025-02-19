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
                        NavigationLink(destination: DisassemblerDetailView(vm: disassembler, line: line)) {
                            DisassemblerLineView(line: line, vm: disassembler)
                        }
                    }
                }
                .listStyle(.plain)
                .font(.system(size: 16, weight: .regular, design: .monospaced))
            }
            HStack {
                Button("Reload") {
                    disassembler.disassemble()
                }
                NavigationLink("Load", destination: DisassemblerLoadFileView( disassembler: disassembler))
                NavigationLink("Save", destination: DisassemblerSaveFileView( disassembler: disassembler))
                Button("Data") {
                    disassembler.changeToData(selectedLines)
                    selectedLines.removeAll()
                }
                .disabled(selectedLines.isEmpty)
            }
        }
        .navigationTitle("Disassambly")
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
            HStack(alignment: .top) {
                VStack {
                    Text(line.addressString)
                        .background(line.isBreakpoint ? .red : .clear)
                    Text(line.label).font(.subheadline).foregroundColor(.accentColor)
                }
                VStack (alignment: .leading) {
                    HStack(alignment: .top) {
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
                    Text(line.comment).font(.subheadline)
                        .foregroundColor(.primary)
                }
                
            }
            .background(line.stepMarker ? .yellow : .clear)
        }
    }
}







#Preview(body: {
    DisassemblerView(disassembler: DisassemblerViewModel())
})
