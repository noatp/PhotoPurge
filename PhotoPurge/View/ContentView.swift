//
//  ContentView.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/14/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isFirstLaunch: Bool = UserDefaults.standard.bool(forKey: "hasLaunchedBefore") == false

    var body: some View {
        if isFirstLaunch {
            WelcomeScreen(isFirstLaunch: $isFirstLaunch)
        } else {
            let dependency = Dependency()
            dependency.views().monthPickerView()
        }
    }
}

#Preview {
    ContentView()
}
