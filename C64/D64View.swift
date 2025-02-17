//
//  D64View.swift
//  C64
//
//  Created by Holger Becker on 14.02.25.
//

import SwiftUI

public struct D64View: View {
    @ObservedObject var vm = D64Format()
    @State var selectedFile: UUID?
    
    public var body: some View {
        VStack {
            Text(vm.diskName())
            HStack {
                Button("Load File") {
                    vm.loadFile(selectedFile)
                }
                Button("Copy to 1541") {
                    
                }
            }
            List(vm.fileEntries,id: \.id, selection: $selectedFile) { entry in
                HStack {
                    Text("\(entry.numerOfBlocks)  ")
                    Text(entry.fileName)
                    Spacer()
                    Text(entry.type)
                }
            }
        }
    }
}

#Preview {
    D64View(vm: D64Format())
}
