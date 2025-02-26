//
//  C64_EmulatorApp.swift
//  C64 Emulator
//
//  Created by Holger Becker on 28.01.25.
//

import SwiftUI

@main
struct C64_EmulatorApp: App {
    var body: some Scene {
        let _ = C64.shared
        WindowGroup {
            C64View()
        }
    }
}
