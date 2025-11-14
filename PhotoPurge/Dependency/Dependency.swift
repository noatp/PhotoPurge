//
//  Dependency.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/21/25.
//

import Foundation

class Dependency {
    private let assetService: AssetService
    private let adService: AdService
    private let purchaseService: PurchaseService
    
    init(
        assetService: AssetService = .init(),
        adService: AdService = .init(),
        purchaseService: PurchaseService = .init()
    ) {
        self.assetService = assetService
        self.adService = adService
        self.purchaseService = purchaseService
    }
    
    static let preview: Dependency = .init()
    
    class Services {
        let assetService: AssetService
        let adService: AdService
        let purchaseService: PurchaseService
        
        init(dependency: Dependency) {
            self.assetService = dependency.assetService
            self.adService = dependency.adService
            self.purchaseService = dependency.purchaseService
        }
    }
    
    private func services() -> Services {
        return Services(dependency: self)
    }
    
    class ViewModels {
        let services: Services
        
        init(services: Services) {
            self.services = services
        }
    }
    
    private func viewModels() -> ViewModels {
        return ViewModels(services: services())
    }
    
    class Views {
        let viewModels: ViewModels
        
        init(viewModels: ViewModels) {
            self.viewModels = viewModels
        }
    }
    
    func views() -> Views {
        return Views(viewModels: viewModels())
    }
}
