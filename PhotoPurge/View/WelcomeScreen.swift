//
//  WelcomeScreen.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/14/25.
//

import SwiftUI
import Photos

enum WelcomeScreenNumber {
    case first
    case second
    case third
}

struct WelcomeScreen: View {
    @State private var welcomeScreenNumber: WelcomeScreenNumber
    @Binding var isFirstLaunch: Bool
    @State private var canRetry: Bool
    @State private var showAlert: Bool

    init(
        welcomeScreenNumber: WelcomeScreenNumber = .first,
        isFirstLaunch: Binding<Bool> = .constant(false),
        canRetry: Bool = false,
        showAlert: Bool = false
    ) {
        self.welcomeScreenNumber = welcomeScreenNumber
        self._isFirstLaunch = isFirstLaunch
        self.canRetry = canRetry
        self.showAlert = showAlert
    }
    
    
    var body: some View {
        if welcomeScreenNumber == .third {
            VStack {
                thirdWelcomeScreen
            }
        }
        else {
            GeometryReader { geometry in
                ZStack {
                    GIFView(gifName: "demo")
                        .scaledToFill()
                        .frame(maxWidth: geometry.size.width) // Full screen width
                        .offset(y: -geometry.size.height * 0.5) // Offset by 30% of screen height
                    
                    Group {
                        switch welcomeScreenNumber {
                        case .first:
                            firstWelcomeScreen
                        case .second:
                            secondWelcomeScreen
                        default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: geometry.size.width * 0.9) // Allow 10% padding for readability
                    .multilineTextAlignment(.center)
                }
            }
        }
        
    }
    
    var firstWelcomeScreen: some View {
        VStack {
            Spacer()
            
            // Texts
            Text("Take some time to tidy up your photo library!")
                .font(.title)
                .lineLimit(2)
                .padding()
            Text("Go through your photos month by month and keep only the ones that truly matter to you.")
                .font(.callout)
                .lineLimit(2)
                .padding()
            
            // Continue Button
            Button {
                withAnimation(.easeInOut(duration: 0.5)) {
                    welcomeScreenNumber = .second
                }
            } label: {
                Text("Continue")
                    .font(.headline)
            }
            .padding()
        }
    }
    
    var secondWelcomeScreen: some View {
        VStack {
            Spacer()
            
            // Texts
            Text("Navigate through your photos of a month,")
                .font(.title)
                .lineLimit(2)
                .padding()
            Group {
                Text("and select the ") +
                Text("checkmark")
                    .foregroundStyle(.green)
                    .fontWeight(.bold) +
                Text(" to keep a photo or the ") +
                Text("trash bin")
                    .foregroundStyle(.red)
                    .fontWeight(.bold) +
                Text(" to remove it.")
            }
            .font(.callout)
            .padding()
            
            // Continue Button
            Button {
                welcomeScreenNumber = .third
            } label: {
                Text("Continue")
                    .font(.headline)
            }
            .padding()
        }
    }
    
    var thirdWelcomeScreen: some View {
        VStack {
            Spacer()
            Text("To get started, we'll need access to your photo library.")
                .font(.title)
                .padding(.bottom)
            
            Text("Rest assured, your privacy is our priority—we do not store your photos or share them in any way.")
                .font(.callout)
            
            Spacer()
            if canRetry {
                Text("Access to photos is required for this app. Please allow access in your settings.")
                    .font(.callout)
                    .padding()
            }
            Button {
                guard !canRetry else {
                    openSettings()
                    return
                }
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    switch status {
                    case .denied:
                        DispatchQueue.main.async {
                            self.showAlert = true
                            self.canRetry = true
                        }
                    case .authorized:
                        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                        DispatchQueue.main.async {
                            self.isFirstLaunch = false
                        }
                    default:
                        break
                    }
                }
                
            } label: {
                Text(canRetry ? "Go to settings" : "Continue")
                    .font(.headline)
            }
            .padding()
        }
        .padding()
        .multilineTextAlignment(.center)
        .alert("Access Required", isPresented: $showAlert) {
            Button("Go to Settings") {
                openSettings()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("To organize your photos, we need access to your photo library. Please enable access in Settings.")
        }
    }
    
    private func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

#Preview {
    WelcomeScreen(
        welcomeScreenNumber: .third,
        isFirstLaunch: .constant(false),
        canRetry: false,
        showAlert: true
    )
}

