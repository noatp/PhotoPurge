//
//  InstructionView.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/28/25.
//

import SwiftUI

struct InstructionView: View {
    @Environment(\.viewsFactory) var views: Dependency.Views
    private let shouldShowContinueButton: Bool
    
    init(shouldShowContinueButton: Bool) {
        self.shouldShowContinueButton = shouldShowContinueButton
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                GIFView(gifName: "demo")
                    .scaledToFill()
                    .frame(maxWidth: geometry.size.width) // Full screen width
                    .offset(y: -geometry.size.height * 0.5) // Offset by 30% of screen height
                
                VStack {
                    Spacer()
                    
                    Text("Navigate through your photos of a month,")
                        .font(.title)
                        .lineLimit(4)
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
                    .font(.title3)
                    .padding()
                    
                    if shouldShowContinueButton {
                        NavigationLink("Continue", value: WelcomeScreen.requestAccess)
                            .font(.headline)
                            .padding()
                    }
                }
                .frame(maxWidth: geometry.size.width * 0.9) // Allow 10% padding for readability
                .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    NavigationStack {
        InstructionView(shouldShowContinueButton: false)
    }
}

extension Dependency.Views {
    func instructionView(shouldShowContinueButton: Bool) -> InstructionView {
        return InstructionView(shouldShowContinueButton: shouldShowContinueButton)
    }
}
