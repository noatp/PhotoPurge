//
//  PurchaseService.swift
//  PhotoPurger
//
//  Created by Toan Pham on 11/13/25.
//

import StoreKit

final class PurchaseService: ObservableObject {
    @Published private(set) var isAdFree = UserDefaults.standard.bool(forKey: AdServiceConstants.isAdFreeUserDefaultKey)
    @Published private(set) var removeAdsProduct: Product?
    private var updatesTask: Task<Void, Never>?

    let removeAdsProductID = "panto.PhotoPurger.removeAds"
    
    init() {
        Task {
            await loadProducts()
            await updateEntitlements()
        }
        updatesTask = listenForTransactionUpdates()
    }
    
    deinit {
        updatesTask?.cancel()
    }

    private func loadProducts() async {
        do {
            let products = try await Product.products(for: [removeAdsProductID])
            removeAdsProduct = products.first
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    private func listenForTransactionUpdates() -> Task<Void, Never> {
        return Task.detached(priority: .background) { [weak self] in
            for await update in Transaction.updates {
                guard let self else { continue }
                if case .verified(let transaction) = update {
                    await self.updateEntitlements()
                    await transaction.finish()
                } else {
                    // Ignore unverified updates; they won't grant entitlement
                    continue
                }
            }
        }
    }
}

extension PurchaseService {
    func buyRemoveAds() async {
        guard let product = removeAdsProduct else { return }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verificationResult):
                if let transaction = checkVerified(verificationResult) {
                    // Non-consumable purchased → grant entitlement
                    await updateEntitlements()

                    // Finish the transaction so it’s not delivered again
                    await transaction.finish()
                }

            case .userCancelled:
                break

            default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) -> T? {
        switch result {
        case .unverified:
            print("Unverified transaction")
            return nil
        case .verified(let safe):
            return safe
        }
    }
}

extension PurchaseService {
    func updateEntitlements() async {
        // Default
        var adFree = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == removeAdsProductID {
                    adFree = true
                }
            }
        }
        // Update your published state (drives UI / ad logic)
        await MainActor.run {
            self.isAdFree = adFree
            UserDefaults.standard.set(adFree, forKey: AdServiceConstants.isAdFreeUserDefaultKey)
        }
    }
}

extension PurchaseService {
    func restorePurchases() async {
        // Recheck current entitlements – this is usually enough for non-consumables
        await updateEntitlements()
    }
}
