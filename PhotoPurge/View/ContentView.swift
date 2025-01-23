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
    private let views: Dependency.Views
    
    init(views: Dependency.Views) {
        self.views = views
    }

    var body: some View {
        if isFirstLaunch {
            WelcomeScreen(isFirstLaunch: $isFirstLaunch)
        } else {
            NavigationStack(path: $navigationPathVM.path) {
                views.photoDeleteView()
                    .navigationDestination(for: NavigationDestination.self ){ destination in
                        switch destination {
                        case .result:
                            views.resultView()
                        }
                    }
            }
            .environmentObject(navigationPathVM)
        }
    }
}

#Preview {
    ContentView(views: Dependency.preview.views())
}
