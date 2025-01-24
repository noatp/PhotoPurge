//
//  ResultView.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/11/25.
//

import SwiftUI

struct ResultView: View {
    @ObservedObject private var viewModel: ResultVM
    @Environment(\.dismiss) private var dismiss
    
    init(resultVM: ResultVM) {
        self.viewModel = resultVM
    }
    
    var body: some View {
        VStack {
            if let deleteResult = viewModel.deleteResult {
                Spacer()
                Text("You have removed \(deleteResult.photosDeleted) photos,")
                    .font(.title2)
                Text("and \(deleteResult.videosDeleted) videos from your library.")
                    .font(.title2)
                    .padding(.bottom)
                
                Text("You freed up \(Util.convertByteToHumanReadable(deleteResult.fileSizeDeleted)) of storage.")
                    .font(.title2)
                Spacer()
                
                // Button to pop the views back to MonthPickerView
                Button(action: {
                    dismiss()
                }) {
                    Text("Return")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding()
                }
            }
        }
        .navigationTitle("Result")
        .navigationBarBackButtonHidden(true) // Hide the default back button
    }
}

#Preview {
    ResultView(resultVM: .init(deleteResult: .init()))
}

extension Dependency.Views {
    func resultView() -> ResultView {
        return ResultView(
            resultVM: viewModels.resultVM()
        )
    }
}
