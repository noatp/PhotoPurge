//
//  RedeemView.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/30/25.
//

import SwiftUI

struct RedeemView: View {
    @ObservedObject private var viewModel: RedeemVM
    @State private var shouldShowAlert: Bool = false
    
    init(viewModel: RedeemVM) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Text("Enter code:")
                .font(.title2)
                .padding()
            TextField("Code", text: $viewModel.code)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .font(.headline)
                .bold()
                .padding()
            LabelActionButton(
                labelText: "Redeem",
                backgroundColor: .accentColor,
                foregroundColor: .white
            ){
                viewModel.disableAds()
            }
            .padding()
        }
        .onChange(of: viewModel.redeemStatusMessage) { oldValue, newValue in
            guard let newValue = newValue, newValue != oldValue else {
                shouldShowAlert = false
                return
            }
            shouldShowAlert = true
        }
        .alert(viewModel.redeemStatusMessage ?? "", isPresented: $shouldShowAlert) {
            Button("OK", role: .cancel) {
                viewModel.resetRedeemStatusMessage()
            }
        }

    }
}

#Preview {
    RedeemView(viewModel: .init(code: ""))
}

extension Dependency.Views {
    func redeemView() -> RedeemView {
        return RedeemView(viewModel: viewModels.redeemVM())
    }
}

