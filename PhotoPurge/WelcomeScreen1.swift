//
//  WelcomeScreen1.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/14/25.
//

import SwiftUI

struct WelcomeScreen1: View {
    var body: some View {
        VStack {
            Text("Take some time to tidy up your photo libray!")
                .font(.title)
                .padding()
            Text("Go through your photos month by month and keep only the ones that truly matter to you.")
                .font(.callout)
                .padding()
            Button {
                
            } label: {
                Text("Continue")
            }
        }
        .multilineTextAlignment(.center)
        
        
    }
}

#Preview {
    WelcomeScreen1()
}
