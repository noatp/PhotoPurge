//
//  ResultView.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/11/25.
//

import SwiftUI

struct ResultView: View {
    @ObservedObject private var viewModel: ResultVM
    @ObservedObject private var interstitialVM: InterstitialVM
    @Environment(\.dismiss) private var dismiss
    @State private var didShowAd: Bool = false
        
    init(
        resultVM: ResultVM,
        interstitialVM: InterstitialVM
    ) {
        self.viewModel = resultVM
        self.interstitialVM = interstitialVM
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
                if interstitialVM.shouldShowReturnButton {
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
        }
        .navigationTitle("Result")
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .task {
            if !didShowAd {
                Task {
                    interstitialVM.showAd()
                    didShowAd = true
                }
            }
        }
    }
}

#Preview {
    ResultView(resultVM: .init(deleteResult: .init()), interstitialVM: .init(shouldShowReturnButton: true))
}

extension Dependency.Views {
    func resultView() -> ResultView {
        return ResultView(
            resultVM: viewModels.resultVM(),
            interstitialVM: viewModels.interstitialVM()
        )
    }
}
