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
    var body: some View {
        Text("Start address: \(floppy1541.startAddress(diskID: disk, fileID: fileID))")
        Text("End address: \(floppy1541.endAddress(diskID: disk, fileID: fileID))")
    }
}
