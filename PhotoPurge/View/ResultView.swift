//
//  ResultView.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/11/25.
//

import SwiftUI

struct ResultView: View {
    private let navigationPathVM: NavigationPathVM
    private let numberOfPhotosRemoved: Int
    
    init(numberOfPhotosRemoved: Int, navigationPathVM: NavigationPathVM) {
        self.numberOfPhotosRemoved = numberOfPhotosRemoved
        self.navigationPathVM = navigationPathVM
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("You have removed \(numberOfPhotosRemoved) photos")
                .font(.title2)
                .padding()
            Spacer()
            // Button to pop the views back to MonthPickerView
            Button(action: {
                navigationPathVM.popToRoot()
            }) {
                Text("Return")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding()
            }
        }
        .navigationTitle("Photos removed")
        .navigationBarBackButtonHidden(true) // Hide the default back button
    }
}

#Preview {
    ResultView(numberOfPhotosRemoved: 3, navigationPathVM: .init())
}
