//
//  ContentView.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/14/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isFirstLaunch: Bool = UserDefaults.standard.bool(forKey: "hasLaunchedBefore") == false
    private let views: Dependency.Views
    
    init(views: Dependency.Views) {
        self.views = views
    }

    var body: some View {
        if isFirstLaunch {
            WelcomeScreen(isFirstLaunch: $isFirstLaunch)
        } else {
            NavigationStack {
                views.photoDeleteView()
            }
        }
    }
}

#Preview {
    ContentView(views: Dependency.preview.views())
}
