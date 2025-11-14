//
//  RemoveAdsView.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/30/25.
//

import SwiftUI
import StoreKit

struct RemoveAdsView: View {
    @StateObject var viewModel: RemoveAdsVM
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                
                Text("Remove Ads")
                    .font(.title)
                    .bold()
                
                if viewModel.isAdFree {
                    Image(systemName: "checkmark.seal.fill")
                        .imageScale(.large)
                        .foregroundStyle(.green)

                    Text("Ads are removed for the current Apple ID.\nThank you for your purchase!")
                        .foregroundStyle(.green)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Remove ads forever with a simple one-time purchase.")
                        .multilineTextAlignment(.center)

                    Text("Your payment is processed securely through the Apple App Store.\nIf you’ve already bought this before (or on another device), just tap Restore Purchases.")
                        .font(.caption)
                        .multilineTextAlignment(.center)

                    if let price = viewModel.priceText {
                        Text(price)
                            .font(.title2.bold())
                    } else {
                        ProgressView("Loading price…")
                    }
                    
                    ZStack {
                        // Buttons always exist, but fade out when working
                        VStack(spacing: 12) {
                            LabelActionButton(
                                labelText: "Remove Ads",
                                backgroundColor: .accentColor,
                                foregroundColor: .white
                            ) {
                                viewModel.buyButtonTapped()
                            }
                            .disabled(!viewModel.hasProduct || viewModel.isWorking)

                            LabelActionButton(
                                labelText: "Restore Purchases",
                                backgroundColor: .clear,
                                foregroundColor: .accentColor
                            ) {
                                viewModel.restoreButtonTapped()
                            }
                            .disabled(viewModel.isWorking)
                        }
                        .opacity(viewModel.isWorking ? 0 : 1)
                        .allowsHitTesting(!viewModel.isWorking) // don't let taps through when hidden

                        // Spinner always exists too, but fades in when working
                        ProgressView()
                            .opacity(viewModel.isWorking ? 1 : 0)
                    }
                    .animation(.easeInOut(duration: 0.25), value: viewModel.isWorking)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    RemoveAdsView(viewModel: RemoveAdsVM(
        isWorking: false,
        errorMessage: nil,
        isAdFree: true,
        hasProduct: true
    ))
}

extension Dependency.Views {
    func removeAdsView() -> RemoveAdsView {
        return RemoveAdsView(viewModel: self.viewModels.removeAdsVM())
    }
}

