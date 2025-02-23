//
//  DisassemblerFiles.swift
//  C64
//
//  Created by Holger Becker on 19.02.25.
//

import SwiftUI

class DisassemblerFilesProvider: ObservableObject {
    @Published var files = DisassemblerFiles()
    @Published var selectedFileName: String?
    
    var disassemblerFiles: [String] {
        files.disassemblerFiles
    }

    init () {
        files.readFilesInDisassemblerDirectory()
    }
    
    func saveFile(named fileName: String, disassembler: DisassemblerViewModel) {
        disassembler.disassembler.save(files.disassemblerDirectoryURL.appendingPathComponent(fileName))
        files.disassemblerFiles.append(fileName)
    }
    
    func loadFile(named fileName: String, disassembler: DisassemblerViewModel) {
        disassembler.disassembler.load(files.disassemblerDirectoryURL.appendingPathComponent(fileName))
    }
    
    func updateDirectory() {
        files.readFilesInDisassemblerDirectory()
    }
    
    func removeFile(named fileName: String) {
        files.removeFile(named: fileName)
    }
    
}

struct DisassemblerFiles {
    
    var disassemblerFiles: [String] = []
            
    var disassemblerDirectoryURL: URL {
        return URL.documentsDirectory.appendingPathComponent("Disassembler")
    }
    
    mutating func readFilesInDisassemblerDirectory() {
        let fileManager = FileManager.default
        let disassamblerDirectory = URL.documentsDirectory.appending(component: "Disassembler")
        print(disassamblerDirectory)
        if !fileManager.fileExists(atPath: disassamblerDirectory.path()) {
            do {
                try fileManager.createDirectory(at: disassamblerDirectory, withIntermediateDirectories: true, attributes: nil)
                
            } catch { let error = error
                fatalError("Could not create directory \(disassamblerDirectory): \(error)")
            }
        }
        else {
            do {
                let fileNames = try fileManager.contentsOfDirectory(atPath: disassamblerDirectory.path())
                print(fileNames)
                disassemblerFiles = fileNames
            }
            catch { let error = error
                fatalError("Could not read directory \(disassamblerDirectory): \(error)")
            }
        }
    }
    
    mutating func removeFile(named fileName: String) {
        let fileManager = FileManager.default
        let disassamblerDirectory = URL.documentsDirectory.appending(component: "Disassembler")
        do {
            try fileManager.removeItem(at: disassamblerDirectory.appendingPathComponent(fileName))
            disassemblerFiles.removeAll(where: { $0 == fileName})
        }
        catch { let error = error
            print("Error removing file: \(error)")
        }
    }
}
