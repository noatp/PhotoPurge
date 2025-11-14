//
//  RemoveAdsViewModel.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/30/25.
//

import Foundation
import StoreKit
import Combine

final class RemoveAdsVM: ObservableObject {
    // UI state
    @Published var isWorking = false
    @Published var errorMessage: String?

    // Data for the view
    @Published private(set) var isAdFree: Bool = false
    @Published private(set) var priceText: String?
    @Published private(set) var hasProduct: Bool = false

    private let purchaseService: PurchaseService
    private var subscriptions: [AnyCancellable] = []

    init(purchaseService: PurchaseService) {
        self.purchaseService = purchaseService
        addSubscription()
    }
    
    init(
        isWorking: Bool,
        errorMessage: String?,
        isAdFree: Bool,
        priceText: String? = "$9.99",
        hasProduct: Bool
    ) {
        self.isWorking = isWorking
        self.errorMessage = errorMessage
        self.isAdFree = isAdFree
        self.priceText = priceText
        self.hasProduct = hasProduct
        self.purchaseService = .init()
    }
    
    private func addSubscription() {
        // Observe PurchaseService so the view updates automatically
        purchaseService.$isAdFree
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAdFree in
                self?.isAdFree = isAdFree
            }
            .store(in: &subscriptions)

        purchaseService.$removeAdsProduct
            .map { product in
                (product != nil, product?.displayPrice)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasProduct, price in
                self?.hasProduct = hasProduct
                self?.priceText  = price
            }
            .store(in: &subscriptions)
    }

    // MARK: - Intents

    func buyButtonTapped() {
        guard hasProduct else { return }
        errorMessage = nil
        isWorking = true

        Task {
            await purchaseService.buyRemoveAds()
            await MainActor.run {
                self.isWorking = false
            }
        }
    }

    func restoreButtonTapped() {
        errorMessage = nil
        isWorking = true

        Task {
            await purchaseService.restorePurchases()
            await MainActor.run {
                self.isWorking = false
            }
        }
    }
}


extension Dependency.ViewModels {
    func removeAdsVM() -> RemoveAdsVM {
        return RemoveAdsVM(purchaseService: services.purchaseService)
    }
}
