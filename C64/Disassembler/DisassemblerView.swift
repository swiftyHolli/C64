//
//  DisassemblerView.swift
//  C64
//
//  Created by Holger Becker on 16.02.25.
//

import SwiftUI

struct DisassemblerView: View {
    @ObservedObject var disassembler = DisassemblerViewModel()
    @State var selectedLines = Set<Disassembler.DisassemblyLine.ID>()
    var body: some View {
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
            Button { disassembler.disassemble() } label: {
                Text(Image(systemName:"memorychip"))
            }
            NavigationLink(destination: DisassemblerLoadFileView(disassembler: disassembler)) {
                Image(systemName: "square.and.arrow.up")
            }
            NavigationLink(destination: DisassemblerSaveFileView(disassembler: disassembler)) {
                Image(systemName: "square.and.arrow.down")
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .buttonStyle(.borderedProminent)
        .navigationTitle(disassembler.disassamblyName == "" ? "not saved" : disassembler.disassamblyName)
    }
    
    var controlView: some View {
        VStack {
            HStack {
                TextField("Start", text: $disassembler.startAddressString)
                TextField("End", text: $disassembler.endAddressString)
                Button("⇢") {
                    disassembler.makeStep()
                }
                Button("➞") {
                    disassembler.resetHalt()
                }
            }
            .buttonStyle(.borderedProminent)

        }
    }
}

struct DisassemblerLineView: View {
    let line: Disassembler.DisassemblyLine
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
                        Text("Data: ")
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






#Preview(body: {
    DisassemblerView(disassembler: DisassemblerViewModel())
})
