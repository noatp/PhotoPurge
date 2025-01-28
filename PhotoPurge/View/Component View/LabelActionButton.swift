//
//  LabelActionButton.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/27/25.
//

import SwiftUI

struct LabelActionButton: View {
    private let labelText: String
    private let backgroundColor: Color
    private let foregroundColor: Color
    private let action: () -> Void
    
    init(
        labelText: String,
        backgroundColor: Color,
        foregroundColor: Color,
        action: @escaping () -> Void
    ) {
        self.labelText = labelText
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(labelText)
                .font(.headline)
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
    LabelActionButton(
        labelText: "Preview",
        backgroundColor: .blue,
        foregroundColor: .white
    ){
        print("preview")
    }
}
