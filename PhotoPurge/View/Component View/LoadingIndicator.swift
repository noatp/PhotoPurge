//
//  LoadingIndicator.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/22/25.
//

import SwiftUI

struct LoadingIndicator: View {
    let loadingMessage: String
    
    init(loadingMessage: String = "Loading") {
        self.loadingMessage = loadingMessage
    }
    
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
            Text(loadingMessage)
            Spacer()
        }
    }
}

#Preview {
    LoadingIndicator()
}

