//
//  WelcomeVM.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/28/25.
//

import Combine
import Foundation
import UIKit

class WelcomeVM: ObservableObject {
    @Published var canRetry: Bool = false
    @Published var showAlert: Bool = false
    @Published var isFirstLaunch: Bool


    private let assetService: AssetService
    private var subscriptions: [AnyCancellable] = []
    
    init(
        assetService: AssetService
    ) {
        self.assetService = assetService
        self.isFirstLaunch = UserDefaults.standard.bool(forKey: "hasLaunchedBefore") == false
        self.addSubscription()
    }
    
    init(
        canRetry: Bool,
        showAlert: Bool,
        isFirstLaunch: Bool
    ) {
        self.canRetry = canRetry
        self.showAlert = showAlert
        self.isFirstLaunch = isFirstLaunch
        self.assetService = .init()
    }
    
    private func addSubscription() {
        
    }
    
    func requestAccess() {
        assetService.requestAccess { result in
            switch result {
            case .success:
                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                DispatchQueue.main.async { [weak self] in
                    self?.isFirstLaunch = false
                }
            case .failure:
                DispatchQueue.main.async { [weak self] in
                    self?.showAlert = true
                    self?.canRetry = true
                }
            }
        }
    }
    
    func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

extension Dependency.ViewModels {
    func welcomeVM() -> WelcomeVM {
        return WelcomeVM(
            assetService: services.assetService
        )
    }
}
