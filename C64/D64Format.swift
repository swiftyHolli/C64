//
//  D64Format.swift
//  C64
//
//  Created by Holger Becker on 14.02.25.
//
import Foundation

class D64Format: ObservableObject {
    var d64Disk = [Byte]()
    
    struct FileEntry: Hashable, Identifiable {
        var id = UUID()
        var type = Floppy1541.FileType.PRG
        var firstDataBlock = BlockAddress(track: 0, block: 0)
        var fileName = ""
        var firstSideSectorBlock = BlockAddress(track: 0, block: 0)
        var recordSize = 0
        var replacementBlock = BlockAddress(track: 0, block: 0)
        var numerOfBlocks = 0
 
        struct BlockAddress: Hashable {
            var track: Int
            var block: Int
        }
    }
    
    
    var fileEntries: [FileEntry] = []
    var fileContent: [UInt8] = []
            
    func diskName() -> String {
        var diskName = ""
        for index in 144..<161 {
            diskName += String(UnicodeScalar(Int(d64Disk[index + blockAddress(track: 18, block: 0)]))!)
        }
        return diskName
    }
    
    func loadFile(_ id: UUID?) {
        guard let fileEntry = self.fileEntries.first(where: { $0.id == id }) else { return }
        fileContent.removeAll()
        var nextTrack = fileEntry.firstDataBlock.track
        var nextBlock = fileEntry.firstDataBlock.block
        while true {
            var pointer = blockAddress(track: nextTrack, block: nextBlock)
            nextTrack = Int(d64Disk[pointer])
            pointer += 1
            nextBlock = Int(d64Disk[pointer])
            pointer += 1
            for _ in 0..<(nextTrack == 0 ? nextBlock : 256) {
                fileContent.append(d64Disk[pointer])
                pointer += 1
            }
            if nextTrack == 0 {
                break
            }
        }
    }
    
    func loadFileEntries() {
        var nextTrack = 18
        var nextBlock = 1
        while true {
            var pointer = blockAddress(track: nextTrack, block: nextBlock)
            nextTrack = Int(d64Disk[pointer])
            pointer += 1
            nextBlock = Int(d64Disk[pointer])
            pointer += 1
            for _ in 0..<8 {
                var entry = FileEntry()
                if d64Disk[pointer] == 0 {
                    break
                }
                entry.type = fileType(d64Disk[pointer])
                pointer += 1
                entry.firstDataBlock.track = Int(Word(d64Disk[pointer]))
                pointer += 1
                entry.firstDataBlock.block = Int(Word(d64Disk[pointer]))
                pointer += 1
                var fileName = [Byte]()
                for index in pointer..<pointer + 16 {
                    if d64Disk[index] != 0xA0 {
                        fileName.append(d64Disk[index])
                    }
                }
                entry.fileName = String(bytes: fileName, encoding: .utf8)!
                pointer += 16
                entry.firstSideSectorBlock.track = Int(Word(d64Disk[pointer]))
                pointer += 1
                entry.firstSideSectorBlock.block = Int(Word(d64Disk[pointer]))
                pointer += 1
                entry.recordSize = Int(d64Disk[pointer])
                pointer += 5
                entry.replacementBlock.track = Int(Word(d64Disk[pointer]))
                pointer += 1
                entry.replacementBlock.block = Int(Word(d64Disk[pointer]))
                pointer += 1
                entry.numerOfBlocks = Int(Word(d64Disk[pointer]) | (Word(d64Disk[pointer + 1]) << 8))
                pointer += 2
                fileEntries.append(entry)
                pointer += 2
            }
            if nextTrack == 0 {
                break
            }
        }
    }
    
    private func fileType(_ type: Byte)->Floppy1541.FileType{
        switch type {
            case 0x80:
            return .DEL
        case 0x81:
            return .SEQ
        case 0x82:
            return .PRG
        case 0x83:
            return .USR
        case 0x84:
            return .REL
        default:
            return .UKN
        }
    }
    
    func readD64File() async {
        do {
            let url = URL(string: "https://www.c64.com/games/no-frame.php?showid=1666&searchfor=&searchfor_special=p&from=0&range=10")
            let (romData, _) = try await URLSession.shared.data(from: url!)
            for index in 0..<romData.count {
                //TODO: check romData for D64 format
                self.d64Disk.append(romData[index])
            }
            self.loadFileEntries()
        }
        catch { let error = error
            print(error.localizedDescription)
        }
    }

    private func blockAddress(track: Int, block: Int) -> Int {
        let trackOffsets: [Int] = [0, 0x1500, 0x2A00, 0x3F00, 0x5400, 0x6900, 0x7E00, 0x9300, 0xA800, 0xBD00, 0xD200, 0xE700, 0xFC00, 0x11100, 0x12600, 0x13B00, 0x15000, 0x16500, 0x17800, 0x18B00, 0x19E00, 0x1B100, 0x1C400, 0x1D700, 0x1EA00, 0x1FC00, 0x20E00, 0x22000, 0x23200, 0x24400, 0x25600, 0x26700, 0x27800, 0x28900, 0x29A00, 0x2AB00, 0x2BC00, 0x2CD00, 0x2DE00, 0x2EF00]
        
        var blockAddress = trackOffsets[track - 1]
        blockAddress += block * 256
        return blockAddress
    }
}
