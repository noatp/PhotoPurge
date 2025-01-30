//
//  Untitled.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/30/25.
//

import Combine
import Foundation

class RedeemVM: ObservableObject {
    @Published var code: String = ""
    @Published var redeemStatusMessage: String?
    
    private let adService: AdService
    private var subscriptions: [AnyCancellable] = []
    
    init(
        adService: AdService
    ) {
        self.adService = adService
    }
    
    init(code: String) {
        self.code = code
        self.adService = .init()
    }
    
    func disableAds() {
        adService.disableAds(code: code) { message in
            DispatchQueue.main.async { [weak self] in
                self?.redeemStatusMessage = message
            }
        }
    }
    
    func resetRedeemStatusMessage() {
        redeemStatusMessage = nil
    }
    
}

extension Dependency.ViewModels {
    func redeemVM() -> RedeemVM {
        return RedeemVM(adService: services.adService)
    }
}
