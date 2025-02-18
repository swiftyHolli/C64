//
//  Disassembler.swift
//  C64
//
//  Created by Holger Becker on 16.02.25.
//

import Foundation

class DisassemblerViewModel: ObservableObject {
    var c64 = C64.shared
    @Published var disassembler: Disassembler = Disassembler()
    @Published var startAddressString = ""
    @Published var endAddressString = ""
    
    init() {
        c64.setStopMarker = setStopMarker
    }
    
    private var startAddress: Int {
        Int(startAddressString, radix: 16) ?? 0
    }
    
    private var endAddress: Int {
        Int(endAddressString, radix: 16) ?? 0
    }
    
    private var breakpoints = [Int]() {
        didSet {
            c64.breakpoints = breakpoints
        }
    }
    
    var disassemblyText: [Disassembler.Line] {
        return disassembler.disassembly
    }
    
    func makeStep() {
        c64.makeStep = true
    }
    
    func resetHalt() {
        c64.HALT = false
    }
    
    func dataString(_ lineID : UUID)->String {
        var _data: String = ""
        if let line = disassembler.disassembly.first(where: { $0.id == lineID }) {
            if line.dataView == .ascii {
                _data = String(bytes: line.data, encoding: .ascii) ?? ""
            }
            else {
                for entry in line.data {
                    _data.append(String(format: "%02X ", entry))
                }
            }
        }
        return _data
    }

    
    func disassemble() {
        disassembler.disassemble(c64.memory, start: startAddress, end: endAddress)
        breakpoints.removeAll()
    }
    
    func changeToData(_ lines: Set<UUID>) {
        disassembler.changeToData(lines)
    }
    
    func changeDataView(_ line: UUID) {
        disassembler.changeDataView(line)
    }
    
    func addRemoveBreakpoint(_ line: UUID) {
        if let lineIndex = disassembler.disassembly.firstIndex(where: { $0.id == line }) {
            let address = disassembler.disassembly[lineIndex].address
            if breakpoints.contains(address) {
                if let index = breakpoints.firstIndex(of: address) {
                    breakpoints.remove(at: index)
                    disassembler.disassembly[lineIndex].isBreakpoint = false
                }
            }
            else {
                breakpoints.append(address)
                disassembler.disassembly[lineIndex].isBreakpoint = true
            }
        }
    }
    
    func setStopMarker(at address: Int, old: Int)->Void {
        for lineIndex in 0..<disassembler.disassembly.count {
            self.disassembler.disassembly[lineIndex].stepMarker = false
        }
        if let lineIndex = disassembler.disassembly.firstIndex(where: { $0.address == address }) {
                self.disassembler.disassembly[lineIndex].stepMarker = true
        }
    }
}

struct Disassembler {
    
    struct Line: Identifiable, Hashable {
        var id: UUID = UUID()
        var address: Int = 0
        var addressString: String = ""
        var label: String = ""
        var instruction: String = ""
        var operand: String = ""
        var data: [UInt8] = []
        var type: LineType = .instruction
        var isBreakpoint = false
        var dataView: DataView = .hex
        var stepMarker = false
        enum LineType { case instruction, data }
        enum DataView { case ascii, hex }
    }
        
    var disassembly: [Line] = []
    
    mutating func disassemble(_ codes: [Byte], start: Int, end: Int) {
        if end <= start {return}
        disassembly.removeAll(keepingCapacity: true)
        var address: Int = start
        for _ in start..<end {
            if address >= codes.count { break }
            let instruction = codes[address]
            disassembly.append(decode(instruction))
        }
        
        func decode(_ instruction: UInt8) -> Line {
            if address >= codes.count { return Line() }
            var disassembly: Line = Line()
            disassembly.address = address
            disassembly.addressString = String(format: "$%04X:", address)
            var data = [UInt8]()
            data.append(instruction)
            switch instruction {
            case 0x00:
                disassembly.instruction = "BRK"
                incAddress()
            case 0x01:
                disassembly.instruction = "ORA "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0x05:
                disassembly.instruction = "ORA "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0x06:
                disassembly.instruction = "ASL "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0x08:
                disassembly.instruction = "PHP"
                incAddress()
            case 0x09:
                disassembly.instruction = "ORA "
                incAddress()
                disassembly.operand = operand(.immediate)
            case 0x0A:
                disassembly.instruction = "ASL"
                incAddress()
            case 0x0D:
                disassembly.instruction = "ORA "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0x0E:
                disassembly.instruction = "ASL "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0x10:
                disassembly.instruction = "BPL "
                incAddress()
                disassembly.operand = operand(.relative)
            case 0x11:
                disassembly.instruction = "ORA "
                incAddress()
                disassembly.operand = operand(.zeroPageIndirectY)
            case 0x15:
                disassembly.instruction = "ORA "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0x16:
                disassembly.instruction = "ASL "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0x18:
                disassembly.instruction = "CLC"
                incAddress()
            case 0x19:
                disassembly.instruction = "ORA "
                incAddress()
                disassembly.operand = operand(.absoluteY)
            case 0x1D:
                disassembly.instruction = "ORA "
                incAddress()
                disassembly.operand = operand(.absoluteX)
            case 0x1E:
                disassembly.instruction = "ASL "
                incAddress()
                disassembly.operand = operand(.absoluteX)
            case 0x20:
                disassembly.instruction = "JSR "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0x21:
                disassembly.instruction = "AND "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0x24:
                disassembly.instruction = "BIT "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0x25:
                disassembly.instruction = "AND "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0x26:
                disassembly.instruction = "ROL "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0x28:
                disassembly.instruction = "PLP"
                incAddress()
            case 0x29:
                disassembly.instruction = "AND "
                incAddress()
                disassembly.operand = operand(.immediate)
            case 0x2A:
                disassembly.instruction = "ROL"
                incAddress()
            case 0x2C:
                disassembly.instruction = "BIT "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0x2D:
                disassembly.instruction = "AND "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0x2E:
                disassembly.instruction = "ROL "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0x30:
                disassembly.instruction = "BMI "
                incAddress()
                disassembly.operand = operand(.relative)
            case 0x31:
                disassembly.instruction = "AND "
                incAddress()
                disassembly.operand = operand(.zeroPageIndirectY)
            case 0x35:
                disassembly.instruction = "AND "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0x36:
                disassembly.instruction = "ROL "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0x38:
                disassembly.instruction = "SEC"
                incAddress()
            case 0x39:
                disassembly.instruction = "AND "
                incAddress()
                disassembly.operand = operand(.absoluteY)
            case 0x3D:
                disassembly.instruction = "AND "
                incAddress()
                disassembly.operand = operand(.absoluteX)
            case 0x3E:
                disassembly.instruction = "ROL "
                incAddress()
                disassembly.operand = operand(.absoluteX)
            case 0x40:
                disassembly.instruction = "RTI"
                incAddress()
            case 0x41:
                disassembly.instruction = "EOR "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0x45:
                disassembly.instruction = "EOR "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0x46:
                disassembly.instruction = "LSR "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0x48:
                disassembly.instruction = "PHA"
                incAddress()
            case 0x49:
                disassembly.instruction = "EOR "
                incAddress()
                disassembly.operand = operand(.immediate)
            case 0x4A:
                disassembly.instruction = "LSR "
                incAddress()
                disassembly.operand = operand(.accumulator)
            case 0x4C:
                disassembly.instruction = "JMP "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0x4D:
                disassembly.instruction = "EOR "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0x4E:
                disassembly.instruction = "LSR "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0x50:
                disassembly.instruction = "BVC "
                incAddress()
                disassembly.operand = operand(.relative)
            case 0x51:
                disassembly.instruction = "EOR "
                incAddress()
                disassembly.operand = operand(.zeroPageIndirectY)
            case 0x55:
                disassembly.instruction = "EOR "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0x56:
                disassembly.instruction = "LSR "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0x58:
                disassembly.instruction = "CLI"
                incAddress()
            case 0x59:
                disassembly.instruction = "EOR "
                incAddress()
                disassembly.operand = operand(.absoluteY)
            case 0x5D:
                disassembly.instruction = "EOR "
                incAddress()
                disassembly.operand = operand(.absoluteX)
            case 0x5E:
                disassembly.instruction = "LSR "
                incAddress()
                disassembly.operand = operand(.absoluteX)
            case 0x60:
                disassembly.instruction = "RTS"
                incAddress()
            case 0x61:
                disassembly.instruction = "ADC "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0x65:
                disassembly.instruction = "ADC "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0x66:
                disassembly.instruction = "ROR "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0x68:
                disassembly.instruction = "PLA"
                incAddress()
            case 0x69:
                disassembly.instruction = "ADC "
                incAddress()
                disassembly.operand = operand(.immediate)
            case 0x6A:
                disassembly.instruction = "ROR "
                incAddress()
                disassembly.operand = operand(.accumulator)
            case 0x6C:
                disassembly.instruction = "JMP "
                incAddress()
                disassembly.operand = operand(.absoluteIndirect)
            case 0x6D:
                disassembly.instruction = "ADC "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0x6E:
                disassembly.instruction = "ROR "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0x70:
                disassembly.instruction = "BVS "
                incAddress()
                disassembly.operand = operand(.relative)
            case 0x71:
                disassembly.instruction = "ADC "
                incAddress()
                disassembly.operand = operand(.zeroPageIndirectY)
            case 0x75:
                disassembly.instruction = "ADC "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0x76:
                disassembly.instruction = "ROR "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0x78:
                disassembly.instruction = "SEI"
                incAddress()
            case 0x79:
                disassembly.instruction = "ADC "
                incAddress()
                disassembly.operand = operand(.absoluteY)
            case 0x7D:
                disassembly.instruction = "ADC "
                incAddress()
                disassembly.operand = operand(.absoluteX)
            case 0x7E:
                disassembly.instruction = "ROR "
                incAddress()
                disassembly.instruction = operand(.absoluteX)
            case 0x81:
                disassembly.instruction = "STA "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0x84:
                disassembly.instruction = "STY "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0x85:
                disassembly.instruction = "STA "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0x86:
                disassembly.instruction = "STX "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0x88:
                disassembly.instruction = "DEY"
                incAddress()
            case 0x8A:
                disassembly.instruction = "TXA"
                incAddress()
            case 0x8C:
                disassembly.instruction = "STY "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0x8D:
                disassembly.instruction = "STA "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0x8E:
                disassembly.instruction = "STX "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0x90:
                disassembly.instruction = "BCC "
                incAddress()
                disassembly.operand = operand(.relative)
            case 0x91:
                disassembly.instruction = "STA "
                incAddress()
                disassembly.operand = operand(.zeroPageIndirectY)
            case 0x94:
                disassembly.instruction = "STY "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0x95:
                disassembly.instruction = "STA "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0x96:
                disassembly.instruction = "STX "
                incAddress()
                disassembly.operand = operand(.zeroPageIndirectY)
            case 0x98:
                disassembly.instruction = "TYA"
                incAddress()
            case 0x99:
                disassembly.instruction = "STA "
                incAddress()
                disassembly.operand = operand(.absoluteY)
            case 0x9D:
                disassembly.instruction = "STA "
                incAddress()
                disassembly.operand = operand(.absoluteX)
            case 0xA0:
                disassembly.instruction = "LDY "
                incAddress()
                disassembly.operand = operand(.immediate)
            case 0xA1:
                disassembly.instruction = "LDA "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0xA2:
                disassembly.instruction = "LDX "
                incAddress()
                disassembly.operand = operand(.immediate)
            case 0xA3:
                disassembly.instruction = "LAX "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0xA4:
                disassembly.instruction = "LDY "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0xA5:
                disassembly.instruction = "LDA "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0xA6:
                disassembly.instruction = "LDX "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0xA7:
                disassembly.instruction = "LAX " // undocumented
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0xA8:
                disassembly.instruction = "TAY"
                incAddress()
            case 0xA9:
                disassembly.instruction = "LDA "
                incAddress()
                disassembly.operand = operand(.immediate)
            case 0xAA:
                disassembly.instruction = "TAX"
                incAddress()
            case 0xAB:
                disassembly.instruction = "LAX " // undocumented
                incAddress()
                disassembly.operand = operand(.immediate)
            case 0xAC:
                disassembly.instruction = "LDY "
                incAddress()
                disassembly.instruction = operand(.absolute)
            case 0xAD:
                disassembly.instruction = "LDA "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0xAE:
                disassembly.instruction = "LDX "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0xAF:
                disassembly.instruction = "LAX "  //undocumented
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0xB0:
                disassembly.instruction = "BCS "
                incAddress()
                disassembly.operand = operand(.relative)
            case 0xB1:
                disassembly.instruction = "LDA "
                incAddress()
                disassembly.operand = operand(.zeroPageIndirectY)
            case 0xB3:
                disassembly.instruction = "LAX " // undocumented
                incAddress()
                disassembly.operand = operand(.zeroPageIndirectY)
            case 0xB4:
                disassembly.instruction = "LDY "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0xB5:
                disassembly.instruction = "LDA "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0xB6:
                disassembly.instruction = "LDX "
                incAddress()
                disassembly.operand = operand(.zeroPageIndirectY)
            case 0xB7:
                disassembly.instruction = "LAX " // undocumented
                incAddress()
                disassembly.operand = operand(.zeroPageIndirectY)
            case 0xB8:
                disassembly.instruction = "CLV"
                incAddress()
            case 0xB9:
                disassembly.instruction = "LDA "
                incAddress()
                disassembly.operand = operand(.absoluteY)
            case 0xBA:
                disassembly.instruction = "TSX"
                incAddress()
            case 0xBC:
                disassembly.instruction = "LDY "
                incAddress()
                disassembly.operand = operand(.absoluteX)
            case 0xBD:
                disassembly.instruction = "LDA "
                incAddress()
                disassembly.operand = operand(.absoluteX)
            case 0xBE:
                disassembly.instruction = "LDX "
                incAddress()
                disassembly.operand = operand(.absoluteX)
            case 0xBF:
                disassembly.instruction = "LAX " // undocumented
                incAddress()
                disassembly.operand = operand(.absoluteY)
            case 0xC0:
                disassembly.instruction = "CPY "
                incAddress()
                disassembly.operand = operand(.immediate)
            case 0xC1:
                disassembly.instruction = "CMP "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0xC4:
                disassembly.instruction = "CPY "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0xC5:
                disassembly.instruction = "CMP "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0xC6:
                disassembly.instruction = "DEC "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0xC8:
                disassembly.instruction = "INY"
                incAddress()
            case 0xC9:
                disassembly.instruction = "CMP "
                incAddress()
                disassembly.operand = operand(.immediate)
            case 0xCA:
                disassembly.instruction = "DEX"
                incAddress()
            case 0xCC:
                disassembly.instruction = "CPY "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0xCD:
                disassembly.instruction = "CMP "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0xCE:
                disassembly.instruction = "DEC "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0xD0:
                disassembly.instruction = "BNE "
                incAddress()
                disassembly.operand = operand(.relative)
            case 0xD1:
                disassembly.instruction = "CMP "
                incAddress()
                disassembly.operand = operand(.zeroPageIndirectY)
            case 0xD5:
                disassembly.instruction = "CMP "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0xD6:
                disassembly.instruction = "DEC "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0xD8:
                disassembly.instruction = "CLD"
                incAddress()
            case 0xD9:
                disassembly.instruction = "CMP "
                incAddress()
                disassembly.operand = operand(.absoluteY)
            case 0xDD:
                disassembly.instruction = "CMP "
                incAddress()
                disassembly.operand = operand(.absoluteX)
            case 0xDE:
                disassembly.instruction = "DEC "
                incAddress()
                disassembly.operand = operand(.absoluteX)
            case 0xE0:
                disassembly.instruction = "CPX "
                incAddress()
                disassembly.operand = operand(.immediate)
            case 0xE1:
                disassembly.instruction = "SBC "
                incAddress()
                disassembly.instruction = operand(.zeroPageXIndirect)
            case 0xE4:
                disassembly.instruction = "CPX "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0xE5:
                disassembly.instruction = "SBC "
                incAddress()
                disassembly.instruction = operand(.zeroPage)
            case 0xE6:
                disassembly.instruction = "INC "
                incAddress()
                disassembly.operand = operand(.zeroPage)
            case 0xE8:
                disassembly.instruction = "INX"
                incAddress()
            case 0xE9:
                disassembly.instruction = "SBC "
                incAddress()
                disassembly.instruction = operand(.immediate)
            case 0xEA:
                disassembly.instruction = "NOP"
                incAddress()
            case 0xEC:
                disassembly.instruction = "CPX "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0xED:
                disassembly.instruction = "SBC "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0xEE:
                disassembly.instruction = "INC "
                incAddress()
                disassembly.operand = operand(.absolute)
            case 0xF0:
                disassembly.instruction = "BEQ "
                incAddress()
                disassembly.operand = operand(.relative)
            case 0xF1:
                disassembly.instruction = "SBC "
                incAddress()
                disassembly.operand = operand(.zeroPageIndirectY)
            case 0xF5:
                disassembly.instruction = "SBC "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0xF6:
                disassembly.instruction = "INC "
                incAddress()
                disassembly.operand = operand(.zeroPageXIndirect)
            case 0xF8:
                disassembly.instruction = "SED"
                incAddress()
            case 0xF9:
                disassembly.instruction = "SBC "
                incAddress()
                disassembly.operand = operand(.absoluteY)
            case 0xFD:
                disassembly.instruction = "SBC "
                incAddress()
                disassembly.operand = operand(.absoluteX)
            case 0xFE:
                disassembly.instruction = "INC "
                incAddress()
                disassembly.operand = operand(.absoluteX)
            default:
                print("unknown Instruction \(hex(instruction))")
                break
            }
            
            enum AddressingMode {
                case accumulator
                case immediate
                case absolute
                case absoluteX
                case absoluteY
                case absoluteIndirect
                case zeroPage
                case zeroPageXIndirect
                case zeroPageIndirectY
                case relative
            }
            
            func operand(_ mode: AddressingMode) -> String {
                if address >= codes.count { return "" }
                switch mode {
                case .accumulator:
                    return "A"
                case .immediate:
                    return "#\(hex(codes[address]))"
                case .zeroPage:
                    return "\(hex(codes[address]))"
                case .zeroPageXIndirect:
                    return "(\(hex(codes[address])),X)"
                case .zeroPageIndirectY:
                    return "(\(hex(codes[address]))),Y"
                case .absolute:
                    return "\(addressAbsolute())"
                case .absoluteX:
                    return "\(addressAbsolute()),X"
                case .absoluteY:
                    return "\(addressAbsolute()),Y"
                case .absoluteIndirect:
                    return "(\(addressAbsolute()))"
                case .relative:
                    return "\(addressRelative())"
                }
            }
            
            func addressAbsolute() -> String {
                if address >= codes.count { return "" }
                let low: UInt8 = codes[Int(address)]
                data.append(low)
                incAddress()
                let high: UInt8 = codes[Int(address)]
                data.append(high)
                incAddress()
                return String(format: "$%02X%02X", high, low)
            }
            
            func addressRelative() -> String {
                if address >= codes.count { return "" }
                let distance = Int(Int8(bitPattern: codes[Int(address)])) + 1
                data.append(codes[Int(address)])
                let targetAddress = address + distance
                incAddress()
                return String(format: "$%04X", targetAddress)
            }
            
            func hex(_ value: UInt8) -> String {
                incAddress()
                return String(format: "$%02X", value)
            }
            
            func incAddress() {
                if address >= codes.count + 1 { return }
                address += 1
            }
            disassembly.data = data
            return disassembly
        }
    }
    
    mutating func changeToData(_ lines: Set<UUID>) {
        var data = [UInt8]()
        let selectedLines = self.disassembly.filter { lines.contains($0.id) }
        let firstLine = selectedLines.first!
        for line in selectedLines {
            data.append(contentsOf: line.data)
        }
        let index = self.disassembly.firstIndex(of: firstLine)!
        self.disassembly[index].data = data
        self.disassembly[index].type = .data
        var indizies = [Int]()
        for selectedLine in selectedLines {
            if let index = self.disassembly.firstIndex(of: selectedLine) {
                indizies.append(index)
            }
        }
        for _ in 0..<indizies.count {
            self.disassembly.remove(at: indizies[0])
        }
        
    }
    
    mutating func changeDataView(_ line: UUID) {
        if let lineIndex = self.disassembly.firstIndex(where: { $0.id == line }) {
            if self.disassembly[lineIndex].type == .data {
                if self.disassembly[lineIndex].dataView == .hex {
                    self.disassembly[lineIndex].dataView = .ascii
                }
                else {
                    self.disassembly[lineIndex].dataView = .hex
                }
            }
        }
    }

}
