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
    var line: Disassembler.Line
    
    @State private var label: String = ""
    @State private var comment: String = ""
    @State var dataStart: String = ""
    @State var dataEnd: String = ""
    
    init(vm: DisassemblerViewModel, line: Disassembler.Line) {
        self.vm = vm
        self.line = line
        self.label = line.label
        self.comment = line.comment
    }
    
    var body: some View {
        VStack {
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
}

#Preview {
    DisassemblerDetailView(vm: DisassemblerViewModel(), line: Disassembler.Line(address: 0x1234, addressString: "$1234", label: "LDA #$01", instruction: "LDA #$01"))
}

