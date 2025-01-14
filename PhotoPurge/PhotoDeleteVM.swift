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
    @Published var currentPhoto: UIImage?
    @Published var nextPhoto: UIImage?
    @Published var shouldNavigateToResult: Bool = false
    @Published var subtitle: String = ""
    @Published var shouldShowUndoButton: Bool = false
    
    private var currentPhotoIndex = -1
    private var photoAssets: [PHAsset]?
    private var photoAssetsToDelete: [PHAsset] = []
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
        photoAssets: [PHAsset]?,
        navigationPathVM: NavigationPathVM,
        currentPhoto: UIImage? = nil,
        nextPhoto: UIImage? = nil,
        subtitle: String = "",
        shouldShowUndoButton: Bool = false
    ) {
#if DEBUG
        print("PhotoDeleteVM init")
#endif
        self.photoAssets = photoAssets
        self.navigationPathVM = navigationPathVM
        self.currentPhoto = currentPhoto
        self.nextPhoto = nextPhoto
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
        guard let photoAssets else { return }
        photoAssetsToDelete.append(photoAssets[currentPhotoIndex])
        fetchNewPhotos()
    }
    
    func fetchNewPhotos() {
        if hasNextImage(afterIndex: currentPhotoIndex) {
            currentPhotoIndex += 1
            fetchPhotosAtIndex(currentPhotoIndex)
        }
        else {
            self.deletePhotoFromDevice()
        }
    }
    
    private func fetchPhotosAtIndex(_ index: Int) {
        setSubtitle(withIndex: index)
        
        fetchPhotoAtIndex(index) { [weak self] currentImage in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.currentPhoto = currentImage
            }
            
        }
        if self.hasNextImage(afterIndex: index) {
            self.fetchPhotoAtIndex(index + 1) { [weak self] nextImage in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.nextPhoto = nextImage
                }
            }
        } else {
            DispatchQueue.main.async {
                self.nextPhoto = nil
            }
        }
    }
    
    private func setSubtitle(withIndex index: Int) {
        guard let photoAssets else { return }
        
        subtitle = "\(index + 1) of \(photoAssets.count)"
    }
    
    private func fetchPhotoAtIndex(_ index: Int, completion: @escaping (UIImage?) -> Void) {
        guard let photoAssets else {
            completion(nil)
            return
        }
        
        if index >= photoAssets.count {
            completion(nil)
            return
        }
        
        let asset = photoAssets[index]
        
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
    
    private func hasNextImage(afterIndex index: Int) -> Bool {
        guard let photoAssets = photoAssets else { return false }
        return index + 1 < photoAssets.count
    }
    
    private func undoDeletePhoto() {
        backtrack()
        if photoAssetsToDelete.count > 0 {
            photoAssetsToDelete.removeLast()
        }
    }
    
    private func backtrack() {
        currentPhotoIndex -= 1
        fetchPhotosAtIndex(currentPhotoIndex)
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
        guard !photoAssetsToDelete.isEmpty else {
            navigationPathVM.navigateTo(.result(0))
            return
        }
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] accessLevel in
            if accessLevel == .authorized {
                // Ensure we have valid assets to delete
                guard let photoAssetsToDelete = self?.photoAssetsToDelete else { return }
                
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

