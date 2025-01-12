//
//  ResultView.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/11/25.
//

import SwiftUI

struct ResultView: View {
    @EnvironmentObject var navigationPathVM: NavigationPathVM

    
    var body: some View {
        VStack {
            Text("You have successfully removed")
                .font(.title2)
                .padding()
            
            // Button to pop the views back to MonthPickerView
            Button(action: {
                navigationPathVM.popToRoot()
            }) {
                Text("Go Back to Month Picker")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding()
            }
        }
        .navigationTitle("Congrats!")
        .navigationBarBackButtonHidden(true) // Hide the default back button
    }
}

#Preview {
    ResultView()
}
