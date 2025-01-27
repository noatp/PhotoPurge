//
//  InterstitialVM.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/25/25.
//

import GoogleMobileAds

class InterstitialVM: NSObject, ObservableObject {
    @Published var shouldShowReturnButton: Bool = false
    private var interstitialAd: GADInterstitialAd?
    
    func loadAd() async {
        do {
            interstitialAd = try await GADInterstitialAd.load(
                withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest())
            interstitialAd?.fullScreenContentDelegate = self
        } catch {
            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        }
    }
    
    func showAd() {
        guard let interstitialAd = interstitialAd else {
            return print("Ad wasn't ready.")
        }
        
        interstitialAd.present(fromRootViewController: nil)
    }
    
    // MARK: - GADFullScreenContentDelegate methods
    
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
    }
}

extension Dependency.ViewModels {
    func interstitialVM() -> InterstitialVM {
        return InterstitialVM()
    }
}
