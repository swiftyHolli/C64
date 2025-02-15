//
//  Floppy1541View.swift
//  C64
//
//  Created by Holger Becker on 13.02.25.
//

import SwiftUI

struct Floppy1541View: View {
    @ObservedObject var floppy1541 = Floppy1541()
    @State var selectedDisk: Floppy1541.Disk.ID?
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button("add empty Disk") {
                        floppy1541.addEmptyDisk()
                    }
                    Button("insert Disk") {
                        floppy1541.insertDisk(selectedDisk!)
                    }
                    Button("D64") {
                        floppy1541.addD64Image()
                    }
                }
                List(floppy1541.disks, id: \.id, selection: $selectedDisk) { disk in
                    HStack  {
                        Text(disk.label)
                        Text(disk.isInserted ? "Ja" : "Nein")
                        Text("Files: \(disk.files.count)")
                    }
                }
                List(floppy1541.disks.first(where: { $0.id == selectedDisk})?.files ?? [], id: \.self) {file in
                    HStack {
                        Text(file.name)
                        Spacer()
                        Text(file.type)
                    }
                }
            }
            .navigationTitle("My disks")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear() {
            floppy1541.loadDisks()
            selectedDisk = floppy1541.disks.first!.id
        }
        .onDisappear() {
            floppy1541.saveDisks()
        }
    }
}

#Preview {
    Floppy1541View(floppy1541: Floppy1541())
}
