//
//  AdService.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/26/25.
//

import GoogleMobileAds
import FirebaseCrashlytics

enum AdServiceError: LocalizedError {
    case failToLoadInterstitialAd(message: String)
    case failToLoadNativeAd(message: String)
    
    var errorDescription: String? {
        switch self {
        case .failToLoadInterstitialAd(let message):
            return message
        case .failToLoadNativeAd(let message):
            return message
        }
    }
}

class AdService: NSObject, ObservableObject {
    @Published var nativeAd: GADNativeAd?
    @Published var interstitialAd: GADInterstitialAd?
    @Published var shouldDisableAds: Bool = false
    
    private var adLoader: GADAdLoader!
    
    override init() {
        super.init()
        checkIfShouldDisableAds()
        if !shouldDisableAds {
            refreshNativeAd()
            loadInterstitialAd()
        }
    }
    
    // MARK: - Native Ad Logic
    func refreshNativeAd() {
        guard !shouldDisableAds else { return }
#if DEBUG
        let adUnitID = "ca-app-pub-3940256099942544/3986624511"
#else
        let adUnitID = "ca-app-pub-3768609381082312/4401168640"
#endif
        
        adLoader = GADAdLoader(
            adUnitID: adUnitID,
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
        guard !shouldDisableAds else { return }
#if DEBUG
        let adUnitID = "ca-app-pub-3940256099942544/4411468910"
#else
        let adUnitID = "ca-app-pub-3768609381082312/1253577779"
#endif
        GADInterstitialAd.load(
            withAdUnitID: adUnitID,
            request: GADRequest()) { interstitialAd, error in
                if let error {
                    let adError = AdServiceError.failToLoadInterstitialAd(message: error.localizedDescription)
                    Crashlytics.crashlytics().record(error: adError)
#if DEBUG
                    print("Failed to load interstitial ad: \(error.localizedDescription)")
#endif
                }
                else if let interstitialAd {
                    self.interstitialAd = interstitialAd
                }
                else {
                    let adError = AdServiceError.failToLoadInterstitialAd(message: "No ad and no error provided")
                    Crashlytics.crashlytics().record(error: adError)
#if DEBUG
                    print("Failed to load interstitial ad")
#endif
                }
            }
    }
    
    private func checkIfShouldDisableAds() {
        shouldDisableAds = UserDefaults.standard.bool(forKey: "shouldDisableAds")
    }
    
    func disableAds(code: String, completion: @escaping (_ message: String) -> Void) {
        if code == "220896" {
            UserDefaults.standard.set(true, forKey: "shouldDisableAds")
            shouldDisableAds = true
            completion("Redeem successfully!")
        }
        else {
            completion("Code entered is incorrect.")
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
        let adError = AdServiceError.failToLoadNativeAd(message: error.localizedDescription)
        Crashlytics.crashlytics().record(error: adError)
#if DEBUG
        print("Failed to load native ad: \(error.localizedDescription)")
#endif
    }
}

extension AdService: GADNativeAdDelegate {
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
#if DEBUG
        print("Native ad clicked.")
#endif
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
#if DEBUG
        print("Native ad impression recorded.")
#endif
    }
}
