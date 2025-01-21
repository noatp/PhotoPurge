//
//  MonthPickerVM.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/11/25.
//

import Photos
import UIKit
import Combine

class MonthPickerVM: ObservableObject {
    @Published var isLoading: Bool?
    @Published var assetsGroupedByMonthYear: [Int: [Date: [PHAsset]]]?
    
    private let assetService: AssetService
    private var subscriptions: [AnyCancellable] = []
        
    init(
        assetService: AssetService
    ) {
        self.assetService = assetService
        self.addSubscription()
    }
    
    init(
        isLoading: Bool?,
        assetsGroupedByMonthYear: [Int: [Date: [PHAsset]]]?
    ) {
        self.isLoading = isLoading
        self.assetsGroupedByMonthYear = assetsGroupedByMonthYear
        self.assetService = .init()
    }

    func addSubscription() {
        assetService.$isLoading.sink { [weak self] isLoading in
            guard let isLoading else { return }
            self?.isLoading = isLoading
        }
        .store(in: &subscriptions)
        
        assetService.$assetsGroupedByMonthYear.sink { [weak self] assetsGroupedByMonthYear in
            guard let assetsGroupedByMonthYear else { return }
            self?.assetsGroupedByMonthYear = assetsGroupedByMonthYear
        }
        .store(in: &subscriptions)
    }
    
    func fetchAsset() {
        print("LOAD DATA")
        assetService.fetchAssets()
    }
}

extension Dependency.ViewModels {
    func monthPickerVM() -> MonthPickerVM {
        return MonthPickerVM(assetService: services.assetService)
    }
}
