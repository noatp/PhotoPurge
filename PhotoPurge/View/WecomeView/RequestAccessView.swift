//
//  RequestAccessView.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/28/25.
//

import SwiftUI

struct RequestAccessView: View {
    @EnvironmentObject var viewModel: WelcomeVM
    
    var body: some View {
        VStack {
            Spacer()
            Text("To get started, we'll need access to your photo library.")
                .font(.title)
                .padding(.bottom)
            
            Text("Rest assured, your privacy is our priority—we do not store your photos or share them in any way.")
                .font(.title3)
                .padding()
            
            Spacer()
            if viewModel.canRetry {
                Text("Access to photos is required for this app. Please allow access in your settings.")
                    .font(.headline)
                    .padding()
            }
            
            Button {
                guard !viewModel.canRetry else {
                    viewModel.openSettings()
                    return
                }
                viewModel.requestAccess()
                
            } label: {
                Text(viewModel.canRetry ? "Go to settings" : "Continue")
                    .font(.headline)
            }
            .padding()
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}

#Preview {
    NavigationStack {
        RequestAccessView()
    }
}

extension Dependency.Views {
    func requestAccessView() -> RequestAccessView {
        return RequestAccessView()
    }
}

