//
//  NativeAdVM.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/26/25.
//

import GoogleMobileAds
import Combine

class NativeAdVM: ObservableObject{
    @Published var nativeAd: GADNativeAd?
    
    private let adService: AdService
    private var subscriptions: [AnyCancellable] = []
    
    init(adService: AdService) {
        self.adService = adService
        self.addSubscription()
    }
    
    private func addSubscription() {
        adService.$nativeAd
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nativeAd in
                self?.nativeAd = nativeAd
                if nativeAd == nil {
                    self?.adService.refreshNativeAd()
                }
            }
            .store(in: &subscriptions)
    }
}

extension Dependency.ViewModels {
    func nativeAdVM() -> NativeAdVM {
        return NativeAdVM(adService: services.adService)
    }
}
