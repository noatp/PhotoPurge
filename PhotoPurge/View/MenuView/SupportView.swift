//
//  SupportView.swift
//  PhotoPurger
//
//  Created by Toan Pham on 2/27/25.
//

import SwiftUI

struct SupportView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Need Support?")
                .multilineTextAlignment(.center)
                .font(.title)
                .bold()
            
            Text("If you have any questions or need assistance, we're here to help! Reach out to us via email at dev@photopurger.com")
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    SupportView()
}

extension Dependency.Views {
    func supportView() -> SupportView {
        return SupportView()
    }
}
