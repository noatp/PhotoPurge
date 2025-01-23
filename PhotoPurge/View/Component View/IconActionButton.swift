//
//  IconActionButton.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/22/25.
//

import SwiftUI

struct IconActionButton: View {
    private let iconName: String
    private let backgroundColor: Color
    private let foregroundColor: Color
    private let action: () -> Void
    
    init(iconName: String, backgroundColor: Color, foregroundColor: Color, action: @escaping () -> Void) {
        self.iconName = iconName
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 44)
                .foregroundColor(foregroundColor)
                .padding(.vertical)
        }
        .background(backgroundColor)
        .cornerRadius(8)
    }
}

#Preview {
    IconActionButton(iconName: "checkmark", backgroundColor: .green, foregroundColor: .white) {
        print("keep")
    }
}
