//
//  DisassemblerDetailView.swift
//  C64
//
//  Created by Holger Becker on 18.02.25.
//

import SwiftUI

struct DisassemblerDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var vm: DisassemblerViewModel
    var line: Disassembler.DisassemblyLine
    
    @State private var label: String = ""
    @State private var comment: String = ""
    @State var dataStart: String = ""
    @State var dataEnd: String = ""
    @State var newDisassemblyStart: String = ""
    @State var newDisassemblyEnd: String = ""

    init(vm: DisassemblerViewModel, line: Disassembler.DisassemblyLine) {
        self.vm = vm
        self.line = line
        self.label = line.label
        self.comment = line.comment
    }
    
    var body: some View {
        VStack {
            markAsData
            newDisassembly
            TextField("label", text: $label)
                .disableAutocorrection(true)
            TextField("comment", text: $comment, axis: .vertical)
                .lineLimit(5...10)
        }
        .textFieldStyle(.roundedBorder)
        .disableAutocorrection(true)
        .padding()
        .navigationBarItems(trailing:
            Button("Save") {
                vm.setLabel(label, address: line.address)
                vm.setComment(comment, address: line.address)
                presentationMode.wrappedValue.dismiss()
        })
        .onAppear() {
            dataStart = String(format: "%04x", line.address)
            dataEnd = String(format: "%04x", line.address)
        }
    }
    var markAsData: some View {
        VStack(alignment: .leading) {
            Button("Mark as Data") {
                vm.changeToData(from: Int(dataStart, radix: 16) ?? 0,
                                to: Int(dataEnd, radix: 16) ?? 0)
            }
            HStack {
                Text("from:")
                TextField("", text: $dataStart)
                Text("to:")
                TextField("", text: $dataEnd)
            }
        }
        .padding(.vertical)
    }
    var newDisassembly: some View {
        VStack(alignment: .leading) {
            Button("Disassamble again") {
                vm.newDisassembly(from: Int(newDisassemblyStart, radix: 16) ?? 0,
                                to: Int(newDisassemblyEnd, radix: 16) ?? 0)
            }
            HStack {
                Text("from:")
                TextField("", text: $newDisassemblyStart)
                Text("to:")
                TextField("", text: $newDisassemblyEnd)
            }
        }
        .padding(.vertical)
    }

}

#Preview {
    DisassemblerDetailView(vm: DisassemblerViewModel(), line: Disassembler.DisassemblyLine(address: 0x1234, label: "LDA #$01", instruction: "LDA #$01"))
}

