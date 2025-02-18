//
//  Floppy1541.swift
//  C64
//
//  Created by Holger Becker on 13.02.25.
//

import Foundation
import SwiftUI

class Floppy1541: ObservableObject {
    private var c64 = C64.shared
        
    init() {
        c64.floppy1541 = self
        loadDisks()
    }
    struct Disk: Encodable, Decodable, Hashable, Identifiable {
        var id = UUID()
        var label: String
        var isInserted: Bool = false
        var files: [File] = []
    }
    
    struct File: Encodable, Decodable, Hashable, Identifiable {
        var id = UUID()
        var name: String
        var type: String
        var data: Data
    }

    func saveDisks() {
        let jsonData = try! JSONEncoder().encode(disks)
        try? jsonData.write(to: URL.documentsDirectory.appendingPathComponent("disks.json"))
    }
    
    func loadDisks() {
        do {
            let jsonData = try Data(contentsOf: URL.documentsDirectory.appendingPathComponent("disks.json"))
            disks = try JSONDecoder().decode([Disk].self, from: jsonData)
        } catch {let error = error; print(error)}
    }
    
    func addEmptyDisk() {
        let disk = Disk(label: "DISK \(disks.count + 1)")
        disks.append(disk)
    }
    
    func addD64Image() async {
        let d64Manager = D64Format()
        await d64Manager.readD64File()
        await MainActor.run {
            let diskName = d64Manager.diskName()
            var disk = Disk(label: diskName.isEmpty ? "UNLABELED" : diskName)
            for file in d64Manager.fileEntries {
                d64Manager.loadFile(file.id)
                disk.files.append(File(name: file.fileName, type: file.type, data: Data(d64Manager.fileContent)))
            }
            self.disks.append(disk)
        }
    }
    
    func insertDisk(_ disk: UUID) {
        if let index = disks.firstIndex(where: { $0.id == disk }) {
            disks.indices.forEach { index in
                if disks[index].isInserted {
                    disks[index].isInserted = false
                }
            }
            disks[index].isInserted = true
        }
    }
    
    @Published var disks: [Disk] = []
    
    func writeFile(_ fileName: String, startAddress: Int, endAddress: Int) {
        let fileName = realFilename(fileName)
        guard let diskIndex = disks.firstIndex(where: {$0.isInserted == true}) else {return}
        var dataToWrite = Array(c64.memory[startAddress..<endAddress])
        dataToWrite.insert(Byte(startAddress >> 8), at: 0)
        dataToWrite.insert(Byte(startAddress & 0xFF), at: 0)
        if let fileIndex = disks[diskIndex].files.firstIndex(where: { $0.name == fileName}) {
            disks[diskIndex].files[fileIndex].data = Data(dataToWrite)
        }
        else {
            disks[diskIndex].files.append(File(name: fileName, type: "PRG", data: Data(dataToWrite)))
        }
        saveDisks()
    }
    
    func readFile(_ fileName: String, stardAddress: Int, secAddress: Byte) -> Int? {
        let fileName = realFilename(fileName)
        guard let disk = disks.first(where: {$0.isInserted == true}) else {return nil}
        var data: Data?
        var startAddress = stardAddress
        if fileName == "$" {
            data = buildDirectoryBasicList(for: disk)
        }
        else {
            if fileName == "*" {
                data = disk.files.first?.data
            }
            else {
                data = disk.files.first(where: { $0.name == fileName })?.data
            }
        }
        if data == nil {return nil}
        if data!.count < 2 {return nil}
        if secAddress > 0 {
            startAddress = Int(Word(data![1]) << 8 | Word(data![0]))
        }
        data!.removeSubrange(0..<2) // Adresse aus den Daten entfernen
        for (index, byte) in data!.enumerated() {
            c64.memory[startAddress + index] = Byte(byte)
        }
        return startAddress + data!.count
        
    }
    
    private func realFilename(_ name: String) -> String {
        var fileName = name
        let prefix = String(name.prefix(2))
        if prefix == "0:" || prefix == "1:" {
            fileName = String(name.split(separator: ":").last!)
        }
        print(fileName)
        return fileName
    }
    
    private func buildDirectoryBasicList(for disk: Disk) -> Data? {
        var data: Data = Data()
        let files = disk.files
        var disklabel = "\"" + disk.label + "\""
        disklabel = disklabel.padding(toLength: 18, withPad: " ", startingAt: 0) + "20 25"
        var nextAddress = 0x801
        nextAddress += 4 + disklabel.count + 1 // 4 = 2 Byte nächse Adresse und 2 Byte Zeilennummer, 1 für 0 am Ende
        data.append(Data([0x01, 0x08]))
        data.append(Byte(nextAddress & 0xff))
        data.append(Byte(nextAddress >> 8))
        data.append(contentsOf: [0, 0])
        data.append(contentsOf: disklabel.utf8)
        data.append(0x0)
        for file in files {
            let fileName = ("\"" + file.name + "\"").padding(toLength: 18, withPad: " ", startingAt: 0)
            let blockCount: UInt16 = UInt16(file.data.count / 254)
            nextAddress += 4 + 3 + fileName.count + 3 + 1 // 4 = 2 Byte nächse Adresse und 2 Byte Zeilennummer, 3 Leerzeichen, 4 für Typ, 1 für 0 am Ende
            data.append(Byte(nextAddress & 0xff))
            data.append(Byte(nextAddress >> 8))
            data.append(Byte(blockCount & 0xff))
            data.append(Byte(blockCount >> 8))
            data.append(contentsOf: [32, 32, 32])
            data.append(contentsOf: fileName.utf8)
            data.append(contentsOf: file.type.utf8)
            data.append(0x0)
        }
        nextAddress += 14
        data.append(Byte(nextAddress & 0xff))
        data.append(Byte(nextAddress >> 8))
        data.append(contentsOf: [0x0f, 0x27])
        data.append(contentsOf: "BLOCKS FREE.".utf8)
        data.append(contentsOf: [0 ,0, 0])
        return data
    }   
}
