//
//  ResultView.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/11/25.
//

import SwiftUI

struct ResultView: View {
    private let navigationPathVM: NavigationPathVM
    private let deleteResult: DeleteResult
    
    
    init(deleteResult: DeleteResult, navigationPathVM: NavigationPathVM) {
        self.deleteResult = deleteResult
        self.navigationPathVM = navigationPathVM
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("You have removed \(deleteResult.photosDeleted) photos,")
                .font(.title2)
            Text("and \(deleteResult.videosDeleted) videos from your library.")
                .font(.title2)
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
        .navigationTitle("Result")
        .navigationBarBackButtonHidden(true) // Hide the default back button
    }
}

#Preview {
    ResultView(deleteResult: .init(), navigationPathVM: .init())
}
