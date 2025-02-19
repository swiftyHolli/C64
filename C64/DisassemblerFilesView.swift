//
//  DisassemblerFilesView.swift
//  C64
//
//  Created by Holger Becker on 19.02.25.
//

import SwiftUI

struct DisassemblerLoadFileView: View {
    @ObservedObject var fileProvider = DisassemblerFilesProvider()
    var disassembler: DisassemblerViewModel
    var body: some View {
        NavigationStack {
            VStack {
                Text("Disassembler Files")
                Button("Load File") {
                    fileProvider.loadFile(named: fileProvider.selectedFileName ?? "" , disassembler: disassembler)
                }
            }
            List(fileProvider.disassemblerFiles, id: \.self, selection: $fileProvider.selectedFileName) { file in
                Text(file)
            }
        }
        .onAppear() {
            fileProvider.updateDirectory()
        }
    }
}

struct DisassemblerSaveFileView: View {
    @ObservedObject var fileProvider = DisassemblerFilesProvider()
    var disassembler: DisassemblerViewModel
    
    @State var filename: String = ""
    var body: some View {
        VStack {
            Text("Disassembler Save File")
            TextField("Filename", text: $filename)
                .padding()
                .textFieldStyle(.roundedBorder)
            Button("Save") {
                fileProvider.saveFile(named: filename, disassembler: disassembler)
            }
        }
    }
}

#Preview {
    DisassemblerLoadFileView(fileProvider: DisassemblerFilesProvider(), disassembler: DisassemblerViewModel())
}

#Preview {
    DisassemblerSaveFileView(fileProvider: DisassemblerFilesProvider(), disassembler: DisassemblerViewModel())
}
