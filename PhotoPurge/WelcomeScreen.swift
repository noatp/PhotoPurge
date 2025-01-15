//
//  WelcomeScreen.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/14/25.
//

import SwiftUI

enum WelcomeScreenNumber {
    case first
    case second
}

struct WelcomeScreen: View {
    @State private var welcomeScreenNumber: WelcomeScreenNumber = .first
    @Binding var isFirstLaunch: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dynamic GIFView position
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
                    }
                }
                .frame(maxWidth: geometry.size.width * 0.9) // Allow 10% padding for readability
                .multilineTextAlignment(.center)
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
                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                isFirstLaunch = false
            } label: {
                Text("Continue")
                    .font(.headline)
            }
            .padding()
        }
    }
}

#Preview {
    WelcomeScreen(isFirstLaunch: .constant(true))
}

