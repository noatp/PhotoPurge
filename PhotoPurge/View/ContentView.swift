//
//  ContentView.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/14/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isFirstLaunch: Bool = UserDefaults.standard.bool(forKey: "hasLaunchedBefore") == false
    @StateObject private var navigationPathVM: NavigationPathVM = .init()

    var body: some View {
        if isFirstLaunch {
            WelcomeScreen(isFirstLaunch: $isFirstLaunch)
        } else {
            let dependency = Dependency()
            NavigationStack(path: $navigationPathVM.path) {
                dependency.views().photoDeleteView()
            }
        }
    }
}

#Preview {
    ContentView()
}
