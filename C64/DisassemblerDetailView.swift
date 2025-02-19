//
//  DisassemblerDetailView.swift
//  C64
//
//  Created by Holger Becker on 18.02.25.
//

import SwiftUI

struct DisassemblerDetailView: View {
    @ObservedObject var vm: DisassemblerViewModel
    var line: Disassembler.Line
    
    @State private var label: String = ""
    @State private var comment: String = ""
    
    init(vm: DisassemblerViewModel, line: Disassembler.Line) {
        self.vm = vm
        self.line = line
        self.label = line.label
        self.comment = line.comment
    }
    
    var body: some View {
        VStack {
            TextField("label", text: $label)
                .textFieldStyle(.roundedBorder)
            TextField("comment", text: $comment, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(5...10)
            Button("Save") {
                vm.setLabel(label, address: line.address)
                vm.setComment(comment, address: line.address)
            }
        }
        .padding()
    }
}

