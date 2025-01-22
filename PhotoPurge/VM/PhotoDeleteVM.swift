//
//  LandingScreenVM.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/10/25.
//

import Foundation
import Photos
import UIKit
import Combine

enum LatestAction{
    case delete
    case keep
}

class PhotoDeleteVM: ObservableObject {
    @Published var currentDisplayingAsset: DisplayingAsset?
    @Published var nextImage: UIImage?
    @Published var shouldNavigateToResult: Bool = false
    @Published var subtitle: String = ""
    @Published var shouldShowUndoButton: Bool = false
    
    private var currentAssetIndex = -1
    private var assets: [PHAsset]?
    private var assetsToDelete: [PHAsset] = []
    private var pastAction: [LatestAction] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }
                shouldShowUndoButton = pastAction.count > 0
            }
        }
    }
    
    private let assetService: AssetService
    private var subscriptions: [AnyCancellable] = []
    
    init(
        assetService: AssetService
    ) {
        self.assetService = assetService
        self.addSubscription()
    }
    
    init(
        currentDisplayingAsset: DisplayingAsset?,
        nextImage: UIImage?,
        subtitle: String,
        shouldShowUndoButton: Bool
    ) {
        self.currentDisplayingAsset = currentDisplayingAsset
        self.nextImage = nextImage
        self.subtitle = subtitle
        self.shouldShowUndoButton = shouldShowUndoButton
        self.assetService = .init()
    }
    
    private func addSubscription() {
        assetService.$assetsByMonth.sink { [weak self] assetsByMonth in
            guard let assetsByMonth else { return }
            self?.assets = assetsByMonth.1
            self?.subtitle = Util.getMonthString(from: assetsByMonth.0)
        }
        .store(in: &subscriptions)
    }
    
#if DEBUG
    deinit {
        print("PhotoDeleteVM deinit")
    }
#endif
        
    func keepPhoto() {
        pastAction.append(.keep)
        fetchNewPhotos()
    }
    
    func deletePhoto() {
        pastAction.append(.delete)
        guard let assets else { return }
        assetsToDelete.append(assets[currentAssetIndex])
        fetchNewPhotos()
    }
    
    func fetchNewPhotos() {
        if hasNextImage(afterIndex: currentAssetIndex) {
            currentAssetIndex += 1
            fetchAssetAtIndex(currentAssetIndex)
            fetchNextAsset(currentIndex: currentAssetIndex)
        }
        else {
            self.deletePhotoFromDevice()
        }
    }
    
    func fetchPreviousPhotos() {
        currentAssetIndex -= 1
        fetchAssetAtIndex(currentAssetIndex)
        fetchNextAsset(currentIndex: currentAssetIndex)
    }
    
    private func fetchNextAsset(currentIndex: Int) {
        guard let assets, hasNextImage(afterIndex: currentIndex) else {
            DispatchQueue.main.async {
                self.nextImage = nil
            }
            return
        }

        let nextAsset = assets[currentIndex + 1]
        assetService.fetchPhotoForAsset(nextAsset) { [weak self] nextImage in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.nextImage = nextImage
            }
        }
    }
    
    private func fetchAssetAtIndex(_ index: Int) {
        setSubtitle(withIndex: index)
        guard let assets, index < assets.count else { return }
        
        let asset = assets[index]
        
        if asset.mediaType == .image {
            assetService.fetchPhotoForAsset(asset) { [weak self] fetchedImage in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.currentDisplayingAsset = .init(assetType: .photo, image: fetchedImage)
                }
                
            }
        }
        else if asset.mediaType == .video {
            assetService.fetchVideoForAsset(asset) { [weak self] fetchedVideoUrl in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.currentDisplayingAsset = .init(assetType: .video, videoURL: fetchedVideoUrl)
                }
            }
        }
        
        
    }
    
    private func setSubtitle(withIndex index: Int) {
        guard let assets else { return }
        
        subtitle = "\(index + 1) of \(assets.count)"
    }
    
    private func hasNextImage(afterIndex index: Int) -> Bool {
        guard let photoAssets = assets else { return false }
        return index + 1 < photoAssets.count
    }
    
    private func undoDeletePhoto() {
        backtrack()
        if assetsToDelete.count > 0 {
            assetsToDelete.removeLast()
        }
    }
    
    private func backtrack() {
        fetchPreviousPhotos()
    }
    
    func undoLatestAction() {
        let latestAction = pastAction.removeLast()
        switch latestAction {
        case .delete:
            undoDeletePhoto()
        case .keep:
            backtrack()
        }
    }
    
    func deletePhotoFromDevice() {
        assetService.deleteAssets(assetsToDelete) { [weak self] result in
            switch result {
            case .success():
                self?.shouldNavigateToResult = true
            case .failure(let error):
                break
                //should show alert
            }
        }
    }
}

extension Dependency.ViewModels {
    func photoDeleteVM() -> PhotoDeleteVM {
        return PhotoDeleteVM(assetService: services.assetService)
    }
}
