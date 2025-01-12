//
//  NavigationPathVM.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/11/25.
//

import SwiftUI
import Photos

enum NavigationDestination: Hashable {
    case photoDelete([PHAsset]?)
    case result
}

class NavigationPathVM: ObservableObject {
    @Published var path: [NavigationDestination] = [] {
        didSet {
            print(path)
        }
    }
    
    func navigateTo(_ destination: NavigationDestination) {
        DispatchQueue.main.async { [ weak self] in
            self?.path.append(destination)
        }
    }
    
    func popToRoot() {
        DispatchQueue.main.async { [ weak self] in
            self?.path.removeAll()
        }
    }
}

