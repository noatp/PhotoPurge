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

struct NativeAdContentView: View {
    @ObservedObject private var viewModel: NativeAdVM
    @State private var progress: Double = 0.0
    @State private var timer: Timer?
    
    init(viewModel: NativeAdVM) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                NativeAdView(viewModel: viewModel)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(.linear)
            }
            
        }
        .task {
            refreshAd()
            startIncrementing()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .navigationTitle("Sponsor")
    }
    
    private func refreshAd() {
        viewModel.refreshAd()
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

#Preview {
    CurrentAssetDisplay(displayingAsset: .ads, views: Dependency.preview.views())
}

extension Dependency.Views {
    func nativeAdContentView() -> NativeAdContentView {
        return NativeAdContentView(viewModel: viewModels.nativeAdVM())
    }
}
