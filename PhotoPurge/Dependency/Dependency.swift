//
//  Dependency.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/21/25.
//

import Foundation

class Dependency {
    private let assetService: AssetService
    
    init(assetService: AssetService = .init()) {
        self.assetService = assetService
    }
    
    static let preview: Dependency = .init()
    
    class Services {
        let assetService: AssetService
        
        init(dependency: Dependency) {
            self.assetService = dependency.assetService
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
