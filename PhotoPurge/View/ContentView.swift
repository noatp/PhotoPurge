//
//  ContentView.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/14/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.viewsFactory) var views: Dependency.Views
    @StateObject var viewModel: WelcomeVM
    
    init(
        viewModel: WelcomeVM
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        if viewModel.isFirstLaunch {
            NavigationStack {
                views.introView()
            }
            .environmentObject(viewModel)
        } else {
            NavigationStack {
                views.photoDeleteView()
            }
        }
    }
}

#Preview {
    ContentView(viewModel: .init(canRetry: false, showAlert: false, isFirstLaunch: true))
}

extension Dependency.Views {
    func contentView() -> ContentView {
        return ContentView(
            viewModel: viewModels.welcomeVM()
        )
    }
}
