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
    
    var openedFiles = [File]()
    
    enum FileType: String, Codable {
        case PRG, SEQ, USR, REL, DEL, UKN
    }

    enum FileMode: String, Codable {
        case READ, WRITE, APPEND, MODIFY
    }
    
    let driveErrors: [Int : String] = [0 : "OK", 1 : "OK", 30: "SYNTAX ERROR", 31: "SYNTAX ERROR", 32: "SYNTAX ERROR", 33: "SYNTAX ERROR", 34: "SYNTAX ERROR", 39: "SYNTAX ERROR", 60: "WRITE FILE OPEN", 61: "FILE NOT OPEN", 62: "FILE NOT FOUND", 63: "FILE EXISTS", 64: "FILE TYPE MISMATCH",  70: "NO CHANNEL", 74: "DRIVE NOT READY"]
    
    var lastError = 0
    
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
        var type: FileType
        var data: Data
        var open: Bool = false
        var setForOutput: Bool = false
        var setForInput: Bool = false
        var mode: FileMode = .READ
        var secAddress: Int = 0
    }
    
    struct FileOpenProperties {
        var filename: String = ""
        var fileType: FileType = .PRG
        var mode: FileMode = .READ
        var error: Int = 0
        var override: Bool = false
    }
    
    func startAddress(diskID: Disk.ID, fileID: File.ID) -> String {
        if let file = disks.first(where: { $0.id == diskID })?.files.first(where: { $0.id == fileID }) {
            let startAddress = String(format: "%02X%02X", file.data[1], file.data[0])
            return startAddress
        }
        return ""
    }

    func endAddress(diskID: Disk.ID, fileID: File.ID) -> String {
        if let file = disks.first(where: { $0.id == diskID })?.files.first(where: { $0.id == fileID }) {
            let endAddress = String(format: "%04X", file.data.count - 2 + Int((Word((file.data[1])) << 8) | Word(file.data[0])))
            return endAddress
        }
        return ""
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
    
    func open(_ fileName: String, secAddress: Int)->Bool {
        let fileToOpenProperties = parseFilenameToOpen(fileName)
        if openedFiles.contains(where: { $0.name == fileToOpenProperties.filename || $0.secAddress == secAddress}) {
            // No channel Error
            lastError = 70
            return false
        }
        
        if let insertedDisk = disks.first(where: { $0.isInserted }) {
            if openedFiles.count >= 5 {
                // No channel error
                lastError = 70
                return false
            }
            if fileToOpenProperties.mode == .READ ||
                fileToOpenProperties.mode == .APPEND ||
                fileToOpenProperties.mode == .MODIFY {
                let predicate = NSPredicate(format: "SELF LIKE %@", String(fileToOpenProperties.filename))
                //Search for the first file with matching patterns
                if var fileToOpen = insertedDisk.files.first(where: { predicate.evaluate(with: $0)}) {
                    fileToOpen.name = fileToOpenProperties.filename
                    fileToOpen.type = fileToOpenProperties.fileType
                    fileToOpen.mode = fileToOpenProperties.mode
                    fileToOpen.secAddress = secAddress
                    openedFiles.append(fileToOpen)
                }
                else {
                    // File not found Error
                    lastError = 62
                    return false
                }
            }
            else  if fileToOpenProperties.mode == .WRITE {
                if insertedDisk.files.contains(where: { $0.name == fileToOpenProperties.filename}) {
                    // File exists Error
                    lastError = 63
                    return false
                }
                let newFileToOpen = File(name: String(fileToOpenProperties.filename),
                                         type: fileToOpenProperties.fileType,
                                         data: Data([Byte]()),
                                         mode: fileToOpenProperties.mode,
                                         secAddress: secAddress)
                openedFiles.append(newFileToOpen)
            }
        }
        else {
            // drive not ready error
            lastError = 74
            return false
        }
        print(openedFiles)
        return true
    }
    
    func closeFile(secondaryAddress: Int)->Bool {
        if let openedFileIndex = openedFiles.firstIndex(where: { $0.secAddress == secondaryAddress }) {
            if let diskIndex = disks.firstIndex(where: { $0.isInserted }) {
                disks[diskIndex].files.append(openedFiles[openedFileIndex])
            }
            openedFiles.remove(at: openedFileIndex)
            return true
        }
        return false
    }

    
    func setOpendFileAsOutput(secondaryAddress: Int)->Bool {
        if let openedFileIndex = openedFiles.firstIndex(where: { $0.secAddress == secondaryAddress }) {
            openedFiles[openedFileIndex].setForOutput = true
            return true
        }
        return false
    }
    
    func setOpendFileAsInput(secondaryAddress: Int)->Bool {
        if let openedFileIndex = openedFiles.firstIndex(where: { $0.secAddress == secondaryAddress }) {
            openedFiles[openedFileIndex].setForInput = true
            return true
        }
        return false
    }
    
    func writeByteToFile(_ byte: Byte, secondaryAddress: Int) -> Bool {
        if let openedFileIndex = openedFiles.firstIndex(where: { $0.secAddress == secondaryAddress }) {
            if openedFiles[openedFileIndex].setForOutput {
                openedFiles[openedFileIndex].data.append(byte)
                print(openedFiles[openedFileIndex].data)
                return true
            }
        }
        return false
    }
    
    func parseFilenameToOpen(_ filename: String) -> FileOpenProperties {
        var filename = filename
        var properties = FileOpenProperties()
        var name = filename.split(separator: ":", omittingEmptySubsequences: false)
     if name.count > 2 {
            // contains at least two ":"
            properties.error = 34 // SYNTAX ERROR no file given
        }
        if name.count == 2 {
            //contains one ":"
            if let driveNumberComponent = name.first {
                if driveNumberComponent.count == 1 {
                    // number shoud be 0
                    if driveNumberComponent != "0" {
                        // Syntax Error
                        properties.error = 33 //invalid Filename ?
                    }
                }
                if driveNumberComponent.count == 2 {
                    if driveNumberComponent == "$0" {
                        properties.filename = "$"
                    }
                    else if driveNumberComponent == "@0" {
                        properties.override = true
                    }
                }
            }
            filename = String(name[1])
        }
        if name.count == 1 {
            filename = String(name[0])
        }
        name = filename.split(separator: ",", omittingEmptySubsequences: false)
        if name.count > 3 {
            // too many commas - Syntax error
            properties.error = 33
        }
        properties.filename = String(name[0])
        if name.count == 3 {
            let typeComponent = name[1]
            // middle section contains file type; last section contains mode
            switch typeComponent {
            case "PRG", "P":
                properties.fileType = .PRG
            case "SEQ", "S":
                properties.fileType = .SEQ
            case "USR", "U":
                properties.fileType = .USR
            case "REL", "L":
                properties.fileType = .REL
            default:
                break
            }
            let modeComponent = name[2]
            // last section contains mode
            switch modeComponent {
            case "R":
                properties.mode = .READ
            case "W":
                properties.mode = .WRITE
            case "A":
                properties.mode = .APPEND
            case "M":
                properties.mode = .MODIFY
            case "PRG", "P":
                properties.fileType = .PRG
            case "SEQ", "S":
                properties.fileType = .SEQ
            case "USR", "U":
                properties.fileType = .USR
            case "REL", "L":
                properties.fileType = .REL
            default:
                // here should be an error
                break
            }
        }
        if name.count == 2 {
            // last section contains file type or mode
            let modeTypeComponent = name[1]
            switch modeTypeComponent {
            case "R":
                properties.mode = .READ
            case "W":
                properties.mode = .WRITE
            case "A":
                properties.mode = .APPEND
            case "M":
                properties.mode = .MODIFY
            default:
                // here should be an error
                break
            }
        }
        return properties
    }
    
    
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
            disks[diskIndex].files.append(File(name: fileName, type: .PRG, data: Data(dataToWrite)))
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
            data.append(contentsOf: file.type.rawValue.utf8)
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
