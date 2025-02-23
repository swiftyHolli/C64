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
            //Text("Time: \(vic.c64.elapsedTime)")
            Image(uiImage: vic.image)
        }
    }
}

#Preview {
    TVScreen(vic: VICII())
}
