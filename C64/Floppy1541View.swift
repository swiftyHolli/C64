//
//  Floppy1541View.swift
//  C64
//
//  Created by Holger Becker on 13.02.25.
//

import SwiftUI

struct Floppy1541View: View {
    @ObservedObject var floppy1541 = Floppy1541()
    @State var selectedDisk: Floppy1541.Disk?
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button("add empty Disk") {
                        floppy1541.addEmptyDisk()
                    }
                    Button("insert Disk") {
                        floppy1541.insertDisk(selectedDisk)
                    }
                }
                List(floppy1541.disks, id: \.self, selection: $selectedDisk) { disk in
                    HStack  {
                        Text(disk.label)
                        Text(disk.isInserted ? "Ja" : "Nein")
                        Text("Files: \(disk.files.count)")
                    }
                }
                List(selectedDisk?.files ?? [], id: \.self) {file in
                    HStack {
                        Text(file.name)
                        Spacer()
                        Text(file.type)
                    }
                }
            }
            .navigationTitle("My disks")
            .toolbar {
                EditButton()
            }
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear() {
            floppy1541.loadDisks()
            selectedDisk = floppy1541.disks.first
        }
        .onDisappear() {
            floppy1541.saveDisks()
        }
    }
}

#Preview {
    Floppy1541View(floppy1541: Floppy1541())
}
