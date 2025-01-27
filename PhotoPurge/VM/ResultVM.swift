//
//  ResultVM.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/21/25.
//

import Combine
import GoogleMobileAds

class ResultVM: NSObject, ObservableObject {
    @Published var deleteResult: DeleteResult?
    @Published var shouldShowReturnButton: Bool = false
    
    private let assetService: AssetService
    private let adService: AdService
    private var subscriptions: [AnyCancellable] = []
    
    private var interstitialAd: GADInterstitialAd?
    
    init(
        assetService: AssetService,
        adService: AdService
    ) {
        self.assetService = assetService
        self.adService = adService
        super.init()
        self.addSubscription()
    }
    
    init(
        deleteResult: DeleteResult,
        shouldShowReturnButton: Bool = false
    ) {
        self.deleteResult = deleteResult
        self.shouldShowReturnButton = shouldShowReturnButton
        self.assetService = .init()
        self.adService = .init()
    }
    
    func showAd() {
        guard let interstitialAd = interstitialAd else {
            DispatchQueue.main.async { [weak self] in
                self?.shouldShowReturnButton = true
            }
            adService.loadInterstitialAd()
            return
        }
        interstitialAd.fullScreenContentDelegate = self
        interstitialAd.present(fromRootViewController: nil)
    }
    
    private func addSubscription() {
        assetService.$deleteResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] deleteResult in
                guard let deleteResult else { return }
                self?.deleteResult = deleteResult
            }
            .store(in: &subscriptions)
        
        adService.$interstitialAd
            .receive(on: DispatchQueue.main)
            .sink { [weak self] interstitialAd in
                guard let self = self else { return }
                self.interstitialAd = interstitialAd
            }
            .store(in: &subscriptions)
    }
}

extension ResultVM: GADFullScreenContentDelegate {
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
    func resultVM() -> ResultVM {
        return ResultVM(
            assetService: services.assetService,
            adService: services.adService
        )
    }
}

