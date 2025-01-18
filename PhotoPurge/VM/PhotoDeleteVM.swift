//
//  LandingScreenVM.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/10/25.
//

import Foundation
import Photos
import UIKit

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
    private let navigationPathVM: NavigationPathVM
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
    
    init(
        assets: [PHAsset]?,
        navigationPathVM: NavigationPathVM,
        currentDisplayingAsset: DisplayingAsset? = nil,
        nextImage: UIImage? = nil,
        subtitle: String = "",
        shouldShowUndoButton: Bool = false
    ) {
#if DEBUG
        print("PhotoDeleteVM init")
#endif
        self.assets = assets
        self.navigationPathVM = navigationPathVM
        self.currentDisplayingAsset = currentDisplayingAsset
        self.nextImage = nextImage
        self.subtitle = subtitle
        self.shouldShowUndoButton = shouldShowUndoButton
    }
    
#if DEBUG
    deinit {
        print("PhotoDeleteVM deinit")
    }
#endif
    
    private let imageManager = PHImageManager.default()
    
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
        self.fetchPhotoForAsset(nextAsset) { [weak self] nextImage in
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
            fetchPhotoForAsset(asset) { [weak self] fetchedImage in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.currentDisplayingAsset = .init(assetType: .photo, image: fetchedImage)
                }
                
            }
        }
        else if asset.mediaType == .video {
            fetchVideoForAsset(asset) { [weak self] fetchedVideoUrl in
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
    
    private func fetchPhotoForAsset(_ asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false // Allow asynchronous fetching
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        
        imageManager.requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options
        ) { image, info in
#if DEBUG
            if let error = info?[PHImageErrorKey] as? NSError {
                print("Error fetching image: \(error.localizedDescription)")
            }
#endif
            completion(image)
        }
    }
    
    private func fetchVideoForAsset(_ asset: PHAsset, completion: @escaping (URL?) -> Void) {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .fastFormat
        options.isNetworkAccessAllowed = true
        
        imageManager.requestAVAsset(
            forVideo: asset,
            options: options) { avAsset, _, _ in
                if let urlAsset = avAsset as? AVURLAsset {
                    completion(urlAsset.url)
                } else {
                    completion(nil)
                }
            }
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
        // Ensure we have a valid photo to delete
        guard !assetsToDelete.isEmpty else {
            navigationPathVM.navigateTo(.result(0))
            return
        }
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] accessLevel in
            if accessLevel == .authorized {
                // Ensure we have valid assets to delete
                guard let photoAssetsToDelete = self?.assetsToDelete else { return }
                
                // Perform deletion in a safe way
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.deleteAssets(photoAssetsToDelete as NSFastEnumeration)
                }) { [weak self] success, error in
                    if success {
                        self?.navigationPathVM.navigateTo(.result(photoAssetsToDelete.count))
                    } else if let error = error {
#if DEBUG
                        // Handle error
                        print("Error deleting photo: \(error.localizedDescription)")
#endif
                        
                    }
                }
            } else {
#if DEBUG
                print("Access denied to photo library")
#endif
            }
        }
    }
}

