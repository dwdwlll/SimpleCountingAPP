//
//  SimpleCountingAPPApp.swift
//  SimpleCountingAPP
//
//  Created on 2026-01-04.
//

import SwiftUI

@main
struct SimpleCountingAPPApp: App {
    @StateObject private var authState = AuthState()
    
    var body: some Scene {
        WindowGroup {
            if authState.isAuthenticated {
                ContentView()
                    .environmentObject(authState)
            } else {
                LoginView(authState: authState)
            }
        }
    }
}
