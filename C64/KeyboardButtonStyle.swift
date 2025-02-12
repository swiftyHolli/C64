//
//  KeyboardButton.swift
//  C64
//
//  Created by Holger Becker on 11.02.25.
//

import SwiftUI

struct KeyboardButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    let padding: CGFloat
    
    init(cornerRadius: CGFloat = 3, padding: CGFloat = 6) {
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(padding)
            .background(Color.gray)
            .cornerRadius(cornerRadius)
    }
}
 
#Preview {
    HStack(alignment: .center, spacing: 2) {
        Spacer()
        Button("HOME") { }
        Button("B") { }
        Button("5") { }
        Spacer()
    }
    .buttonStyle(KeyboardButtonStyle())
}
