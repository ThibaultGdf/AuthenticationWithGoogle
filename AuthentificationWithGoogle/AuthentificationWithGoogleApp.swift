//
//  AuthentificationWithGoogleApp.swift
//  AuthentificationWithGoogle
//
//  Created by Thibault GODEFROY on 24/11/2023.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct AuthentificationWithGoogleApp: App {
    @StateObject var viewModel = AuthenticationViewModel()
    init() {
       setupAuthentication()
     }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}

extension AuthentificationWithGoogleApp {
  private func setupAuthentication() {
    FirebaseApp.configure()
  }
}
