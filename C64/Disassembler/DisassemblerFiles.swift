//
//  DisassemblerFiles.swift
//  C64
//
//  Created by Holger Becker on 19.02.25.
//

import SwiftUI

class DisassemblerFilesProvider: ObservableObject {
    
    @Published var files: DisassemblerFiles = .init()
    
    init () {
        files.readFilesInDisassemblerDirectory()
    }
    
    var disassemblerFiles: [String] {
        return files.disassemblerFiles
    }
    
    var selectedFileName: String?
    
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
    
}

struct DisassemblerFiles {
    
    var disassemblerFiles: [String] = []
            
    mutating func removeFile(named fileName: String) {
        disassemblerFiles.removeAll(where: { $0 == fileName})
    }
    
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
}
