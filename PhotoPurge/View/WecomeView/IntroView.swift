//
//  IntroView.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/28/25.
//

import SwiftUI

enum WelcomeScreen: Hashable {
    case intro
    case instruction
    case requestAccess
}

struct IntroView: View {
    @Environment(\.viewsFactory) var views: Dependency.Views

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                GIFView(gifName: "demo")
                    .scaledToFill()
                    .frame(maxWidth: geometry.size.width) // Full screen width
                    .offset(y: -geometry.size.height * 0.5) // Offset by 30% of screen height
                
                VStack {
                    Spacer()
                    
                    // Texts
                    Text("Take some time to tidy up your photo library!")
                        .font(.title)
                        .lineLimit(2)
                        .padding()
                    Text("Go through your photos month by month and keep only the ones that truly matter to you.")
                        .font(.title3)
                        .lineLimit(4)
                        .padding()
                    NavigationLink("Continue", value: WelcomeScreen.instruction)
                        .font(.headline)
                        .padding()
                }
                .frame(maxWidth: geometry.size.width * 0.9) // Allow 10% padding for readability
                .multilineTextAlignment(.center)
            }
        }
        .navigationDestination(for: WelcomeScreen.self) { welcomeScreen in
            switch welcomeScreen {
            case .intro:
                views.introView()
            case .instruction:
                views.instructionView()
            case .requestAccess:
                views.requestAccessView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        IntroView()
    }
}

extension Dependency.Views {
    func introView() -> IntroView {
        return IntroView()
    }
}
