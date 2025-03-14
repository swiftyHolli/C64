//
//  Floppy1541View.swift
//  C64
//
//  Created by Holger Becker on 13.02.25.
//

import SwiftUI

struct Floppy1541View: View {
    @ObservedObject var floppy1541 = Floppy1541.shared
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
                        Task {
                            await floppy1541.addD64Image()
                        }
                    }
                }
                List(selection: $selectedDisk) {
                    ForEach(floppy1541.disks, id: \.id) { disk in
                        HStack  {
                            Text(disk.label)
                            Text(disk.isInserted ? "Ja" : "Nein")
                            Text("Files: \(disk.files.count)")
                        }
                    }
                    .onDelete { rows in
                        for row in rows {
                            floppy1541.disks.remove(at: row)
                        }
                        floppy1541.saveDisks()
                    }
                }
                
                List(floppy1541.disks.first(where: { $0.id == selectedDisk} )?.files ?? [], id: \.self) {file in
                    NavigationLink {
                        FileDetailView(floppy1541: floppy1541, disk: selectedDisk!, fileID: file.id)
                    } label: {
                        HStack {
                            Text(file.name)
                            Spacer()
                            Text(file.type.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("My disks")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear() {
            floppy1541.loadDisks()
            selectedDisk = floppy1541.insertedDisk
        }
        .onDisappear() {
            floppy1541.saveDisks()
        }
    }
}



struct Floppy1541LEDView: View {
    @ObservedObject var floppy1541 = Floppy1541.shared
    
    @State private var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    @State private var errorLedIsOn: Bool = false
    @State private var driveLedIsOn: Bool = false
    

    var body: some View {
        HStack {
            Circle()
                .fill(errorLedIsOn || driveLedIsOn ? .red : .clear)
                .frame(width: 20, height: 20)
        }
        .onReceive(timer) { _ in
            errorLedIsOn.toggle()
        }
        .onChange(of: floppy1541.driveError) {
            if floppy1541.driveError != 0 {
                startTimer()
            }
            else {
                stopTimer()
                errorLedIsOn = false
            }
        }
        .onAppear() {
            stopTimer()
        }
    }
    
    func startTimer() {
        timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    }
    
    func stopTimer() {
        timer.upstream.connect().cancel()
    }
}
