//
//  TestView.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/22/25.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        Button("Submit") {
            print("Button pressed")
        }
        .buttonStyle(.borderedProminent)
        .disabled(false)
    }
}

#Preview {
    TestView()
}
