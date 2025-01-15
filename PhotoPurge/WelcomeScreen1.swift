//
//  WelcomeScreen1.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/14/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct WelcomeScreen1: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dynamic GIFView position
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
                        .font(.callout)
                        .lineLimit(2)
                        .padding()
                    
                    // Continue Button
                    Button {
                        // Action here
                    } label: {
                        Text("Continue")
                            .font(.headline)
                    }
                    .padding()
                }
                .frame(maxWidth: geometry.size.width * 0.9) // Allow 10% padding for readability
                .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    WelcomeScreen1()
}

