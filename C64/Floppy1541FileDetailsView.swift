//
//  Floppy1541FileDetailsView.swift
//  C64
//
//  Created by Holger Becker on 22.02.25.
//

import SwiftUI

struct FileDetailView: View {
    @ObservedObject var floppy1541: Floppy1541
    var disk: Floppy1541.Disk.ID
    var fileID: UUID
    @State var lines: [Floppy1541.FileDataHexDisplay.Line]?
    
    var body: some View {
        VStack {
            HStack {
                Text("Start address: \(floppy1541.startAddress(diskID: disk, fileID: fileID))")
                Text("End address: \(floppy1541.endAddress(diskID: disk, fileID: fileID))")
            }
            ScrollView {
                if lines == nil {
                    ProgressView().progressViewStyle(.circular)
                }
                VStack(alignment: .leading) {
                    ForEach(lines ?? [], id: \.address) { line in
                        LineView(line: line)
                    }
                }
            }
        }
        .navigationTitle(floppy1541.fileName(diskID: disk, fileID: fileID))
        .onAppear() {
            let data = floppy1541.readFile(diskID: disk, fileID: fileID)
            Task {
                let hexDisplay = Floppy1541.FileDataHexDisplay(data: data,
                                                               startAddress: floppy1541.startAddress(diskID: disk, fileID: fileID), split: 8)
                lines = hexDisplay.lines
            }
        }
    }
    struct LineView: View {
        let line: Floppy1541.FileDataHexDisplay.Line
        var body: some View {
            HStack {
                Text("\(line.address):")
                Text("\(line.data)")
                Text("\(line.ascii)")
            }
            .font(.caption)
            .monospaced()
        }
    }
}
