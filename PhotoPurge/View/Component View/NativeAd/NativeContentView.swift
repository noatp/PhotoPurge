//
//  NativeContentView.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/26/25.
//

import GoogleMobileAds
import SwiftUI

struct NativeAdConstant {
    static let adDuration: Double = 1.5 //1.5 seconds
    static let photosLimitPerAd: Int = 10 // 10 photos will show an ad
}

struct NativeContentView: View {
    @StateObject private var nativeViewModel = NativeAdViewModel()
    @State private var progress: Double = 0.0
    @State private var timer: Timer?
    
    let navigationTitle: String
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                NativeAdView(nativeViewModel: nativeViewModel)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(.linear)
            }
            
        }
        .onAppear {
            refreshAd()
            startIncrementing()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .navigationTitle(navigationTitle)
    }
    
    private func refreshAd() {
        nativeViewModel.refreshAd()
    }
    
    private func startIncrementing() {
        // Invalidate any existing timer
        timer?.invalidate()
        
        progress = 0.0  // Reset to start
        let steps = 100
        let totalDuration = NativeAdConstant.adDuration
        let stepInterval = totalDuration / Double(steps)
        
        var currentStep = 0
        timer = Timer.scheduledTimer(withTimeInterval: stepInterval, repeats: true) { t in
            currentStep += 1
            progress = Double(currentStep) / Double(steps)
            
            if currentStep >= steps {
                t.invalidate() // Done
            }
        }
    }
}

struct NativeContentView_Previews: PreviewProvider {
    static var previews: some View {
        NativeContentView(navigationTitle: "Native")
    }
}

private struct NativeAdView: UIViewRepresentable {
    typealias UIViewType = GADNativeAdView
    
    @ObservedObject var nativeViewModel: NativeAdViewModel
    
    func makeUIView(context: Context) -> GADNativeAdView {
        return Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)?.first as! GADNativeAdView
    }
    
    func updateUIView(_ nativeAdView: GADNativeAdView, context: Context) {
        guard let nativeAd = nativeViewModel.nativeAd else { return }
        
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        
        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
        
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        
        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        
        // For the SDK to process touch events properly, user interaction should be disabled.
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        // Associate the native ad view with the native ad object. This is required to make the ad
        // clickable.
        // Note: this should always be done after populating the ad views.
        nativeAdView.nativeAd = nativeAd
    }
    
    private func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }
        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        } else {
            return nil
        }
    }
}
