//
//  TVScreen.swift
//  C64 Emulator
//
//  Created by Holger Becker on 01.02.25.
//

import SwiftUI
import UIKit

struct TVScreen: View {
    @ObservedObject var vic: VIC
    var body: some View {
        VStack {
            DrawViewUIViewRepresentable(pixels: $vic.canvasBuffer)
                .frame(width: 320, height: 200)
        }
    }
}

struct DrawViewUIViewRepresentable: UIViewRepresentable {
    @Binding var pixels: [CGColor]
    
    func makeUIView(context: Context) -> DrawView {
        return DrawView(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 200)), pixels: pixels)
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
    
    init(frame: CGRect, pixels: [CGColor]) {
        self.pixelBuffer = pixels
        super.init(frame: frame)
    }
    
    var pixelBuffer: [CGColor]
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext()
        else { return }
        for i in 0..<(320 * 200){
            context.addRect(CGRect(x: i % 320, y: i / 320, width: 1, height: 1))
            context.setStrokeColor(pixelBuffer[i])
            context.strokePath()
        }
    }
}

#Preview {
    TVScreen(vic: VIC(address: 0xD000))
}
