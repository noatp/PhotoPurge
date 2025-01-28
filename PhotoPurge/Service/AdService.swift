//
//  AdService.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/26/25.
//

import GoogleMobileAds

class AdService: NSObject, ObservableObject {
    @Published var nativeAd: GADNativeAd?
    @Published var interstitialAd: GADInterstitialAd?

    private var adLoader: GADAdLoader!

    override init() {
        super.init()
        refreshNativeAd() // Load native ad on init
        loadInterstitialAd()
    }

    // MARK: - Native Ad Logic
    func refreshNativeAd() {
        adLoader = GADAdLoader(
            adUnitID: "ca-app-pub-3940256099942544/3986624511",
            // The UIViewController parameter is optional.
            rootViewController: nil,
            adTypes: [.native],
            options: nil
        )
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }

    // MARK: - Interstitial Ad Logic
    func loadInterstitialAd() {
        GADInterstitialAd.load(
            withAdUnitID: "ca-app-pub-3940256099942544/4411468910",
            request: GADRequest()) { interstitialAd, error in
                if let error {
                    print("Failed to load interstitial ad: \(error.localizedDescription)")
                }
                else if let interstitialAd {
                    self.interstitialAd = interstitialAd
                }
                else {
                    print("Failed to load interstitial ad")
                }
            }
    }
}

// MARK: - Native Ad Delegate
extension AdService: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        self.nativeAd = nativeAd
        nativeAd.delegate = self
    }

    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: any Error) {
        print("Failed to load native ad: \(error.localizedDescription)")
    }
}

extension AdService: GADNativeAdDelegate {
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        print("Native ad clicked.")
    }

    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        print("Native ad impression recorded.")
    }
}
