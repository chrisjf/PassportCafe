//
//  Passport_CafeApp.swift
//  Passport Cafe
//
//  Created by Chris Forbes on 2026-05-15.
//

import SwiftUI

@main
struct Passport_CafeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                #if os(macOS)
                .frame(minWidth: 800, minHeight: 600)
                #endif
        }
        #if os(macOS)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        #endif
    }
}
