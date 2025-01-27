//
//  InterstitialVM.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/25/25.
//

import GoogleMobileAds
import Combine

class InterstitialVM: NSObject, ObservableObject {
    @Published var shouldShowReturnButton: Bool = false
    private let adService: AdService

    private var interstitialAd: GADInterstitialAd?
    private var subscriptions: Set<AnyCancellable> = []
    
    init(adService: AdService) {
        self.adService = adService
        super.init()
        addSubscription()
    }
    
    init(shouldShowReturnButton: Bool) {
        self.shouldShowReturnButton = shouldShowReturnButton
        self.adService = .init()
        super.init()
    }

    func showAd() {
        guard let interstitialAd = interstitialAd else {
            return print("Ad wasn't ready.")
        }
        interstitialAd.fullScreenContentDelegate = self
        interstitialAd.present(fromRootViewController: nil)
    }
    
    private func addSubscription() {
        adService.$interstitialAd.sink { [weak self] interstitialAd in
            guard let self = self else { return }
            self.interstitialAd = interstitialAd
        }
        .store(in: &subscriptions)
    }
}

extension InterstitialVM: GADFullScreenContentDelegate {
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    func ad(
        _ ad: GADFullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        print("\(#function) called")
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
        DispatchQueue.main.async { [weak self] in
            self?.shouldShowReturnButton = true
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
        // Clear the interstitial ad.
        interstitialAd = nil
        adService.loadInterstitialAd()
    }
}

extension Dependency.ViewModels {
    func interstitialVM() -> InterstitialVM {
        return InterstitialVM(adService: services.adService)
    }
}
