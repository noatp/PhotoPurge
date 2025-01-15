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
                withAnimation(.easeInOut(duration: 1)) {
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
            Text("and select the checkmark to keep a photo or the trash bin to remove it.")
                .font(.callout)
                .lineLimit(2)
                .padding()
            
            // Continue Button
            Button {
                welcomeScreenNumber = .first

            } label: {
                Text("Continue")
                    .font(.headline)
            }
            .padding()
        }
    }
}

#Preview {
    WelcomeScreen()
}

