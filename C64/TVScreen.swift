//
//  TVScreen.swift
//  C64 Emulator
//
//  Created by Holger Becker on 01.02.25.
//

import SwiftUI
import UIKit

struct TVScreen: View {
    @ObservedObject var vic = VICII()
    var body: some View {
        VStack {
            DrawViewUIViewRepresentable(pixels: $vic.canvasBuffer, counter: $vic.counter)
                .frame(width: 320, height: 200)
            Text("\(vic.counter)")
            Button("fill Screen") {
                vic.c64.memory[0x400] = 1
            }
        }
    }
}

struct DrawViewUIViewRepresentable: UIViewRepresentable {
    @Binding var pixels: [Byte]
    @Binding var counter: Int
    
    func makeUIView(context: Context) -> DrawView {
        return DrawView(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 200)), pixels: pixels, counter: counter)
    }
    
    func updateUIView(_ uiView: DrawView, context: Context) {
        uiView.pixelBuffer = pixels
        uiView.setNeedsDisplay()
    }
}

class DrawView: UIView {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, pixels: [Byte], counter: Int) {
        self.pixelBuffer = pixels
        self.counter = counter
        super.init(frame: frame)
    }
    
    var pixelBuffer: [Byte]
    var counter: Int
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext()
        else { return }
        for i in 0..<(320 * 200){
            context.addRect(CGRect(x: i % 320, y: i / 320, width: 1, height: 1))
            context.setStrokeColor(colorFromCode(pixelBuffer[i]))
            context.strokePath()
        }
    }
    
    func colorFromCode(_ code: Byte)->CGColor {
        switch code {
        case 0:
            return CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        case 1:
            return CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        case 2:
            return CGColor(red: 104 / 255, green: 55 / 255, blue: 43 / 255, alpha: 1.0)
        case 3:
            return CGColor(red: 112 / 255, green: 164 / 255, blue: 178 / 255, alpha: 1.0)
        case 4:
            return CGColor(red: 111 / 255, green: 61 / 255, blue: 134 / 255, alpha: 1.0)
        case 5:
            return CGColor(red: 88 / 255, green: 141 / 255, blue: 67 / 255, alpha: 1.0)
        case 6:
            return CGColor(red: 53 / 255, green: 40 / 255, blue: 178 / 255, alpha: 1.0)
        case 7:
            return CGColor(red: 184 / 255, green: 199 / 255, blue: 111 / 255, alpha: 1.0)
        case 8:
            return CGColor(red: 112 / 255, green: 79 / 255, blue: 37 / 255, alpha: 1.0)
        case 9:
            return CGColor(red: 67 / 255, green: 57 / 255, blue: 0 / 255, alpha: 1.0)
        case 10:
            return CGColor(red: 154 / 255, green: 103 / 255, blue: 89 / 255, alpha: 1.0)
        case 11:
            return CGColor(red: 68 / 255, green: 68 / 255, blue: 68 / 255, alpha: 1.0)
        case 12:
            return CGColor(red: 108 / 255, green: 108 / 255, blue: 108 / 255, alpha: 1.0)
        case 13:
            return CGColor(red: 154 / 255, green: 210 / 255, blue: 132 / 255, alpha: 1.0)
        case 14:
            return CGColor(red: 108 / 255, green: 94 / 255, blue: 181 / 255, alpha: 1.0)
        case 15:
            return CGColor(red: 149 / 255, green: 149 / 255, blue: 149 / 255, alpha: 1.0)
        default:
            return CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
    }
}

#Preview {
    TVScreen(vic: VICII())
}
