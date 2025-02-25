//
//  ResultView.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/11/25.
//

import SwiftUI
import FirebaseAnalytics

struct ResultView: View {
    @ObservedObject private var viewModel: ResultVM
    @Environment(\.dismiss) private var dismiss
    @State private var didShowAd: Bool = false
        
    init(
        resultVM: ResultVM
    ) {
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
                
                Button(action: {
                    dismiss()
                    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                      AnalyticsParameterItemID: "id-ResultView-Return"
                    ])
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
        .task {
            if !didShowAd && !viewModel.shouldDisableAds{
                Task {
                    viewModel.showAd()
                    didShowAd = true
                }
            }
        }
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
