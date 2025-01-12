//
//  LandingScreenVM.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/10/25.
//

import Foundation
import Photos
import UIKit

class PhotoDeleteVM: ObservableObject {
    @Published var currentPhoto: UIImage?
    @Published var nextPhoto: UIImage?
    @Published var shouldNavigateToResult: Bool = false
    @Published var subtitle: String = ""
    
    private var currentPhotoIndex = -1
    private var photoAssets: [PHAsset]?
    private var photoAssetsToDelete: [PHAsset] = []
    private let navigationPathVM: NavigationPathVM
    
    init(
        photoAssets: [PHAsset]?,
        navigationPathVM: NavigationPathVM
    ) {
        print("PhotoDeleteVM init")
        self.photoAssets = photoAssets
        self.navigationPathVM = navigationPathVM
    }
    
    deinit {
        print("PhotoDeleteVM deinit")
    }
    
    private let imageManager = PHImageManager.default()
    
    // Fetch photos and corresponding assets
    func fetchPhotoInMonth() {
        guard let photoAssets else { return }
        print("photo counts: \(photoAssets.count)")
        fetchNewPhotos()
    }
    
    private func fetchNewPhotos() {
        guard let photoAssets else { return }
        
        if hasNextImage() {
            currentPhotoIndex += 1
            print("current photo index: \(currentPhotoIndex)")
            subtitle = "\(currentPhotoIndex + 1) of \(photoAssets.count)"
            fetchPhotosAtIndex(currentPhotoIndex) { [weak self] currentImage in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.currentPhoto = currentImage
                }
                
            }
            if self.hasNextImage() {
                self.fetchPhotosAtIndex(self.currentPhotoIndex + 1) { [weak self] nextImage in
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
        } else {
            DispatchQueue.main.async {
                self.deletePhotoFromDevice()
            }
        }
    }

    
    
    private func fetchPhotosAtIndex(_ index: Int, completion: @escaping (UIImage?) -> Void) {
        guard let photoAssets else {
            print("No photo assets available")
            completion(nil)
            return
        }
        
        if index >= photoAssets.count {
            print("Index out of bounds: \(index)")
            completion(nil)
            return
        }
        
        let asset = photoAssets[index]
        print("Fetching photo at index: \(index)")
        
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
            if let error = info?[PHImageErrorKey] as? NSError {
                print("Error fetching image: \(error.localizedDescription)")
            }
            completion(image)
        }
    }

    
    
    private func hasNextImage() -> Bool {
        guard let photoAssets = photoAssets else { return false }
        return currentPhotoIndex + 1 < photoAssets.count
    }
    
    func keepPhoto() {
        fetchNewPhotos()
    }
    
    func deletePhoto() {
        guard let photoAssets else { return }
        photoAssetsToDelete.append(photoAssets[currentPhotoIndex])
        fetchNewPhotos()
    }
    
    func deletePhotoFromDevice() {
        // Ensure we have a valid photo to delete
        guard !photoAssetsToDelete.isEmpty else {
            navigationPathVM.navigateTo(.result)
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
                        self?.navigationPathVM.navigateTo(.result)
                    } else if let error = error {
                        // Handle error
                        print("Error deleting photo: \(error.localizedDescription)")
                    }
                }
            } else {
                print("Access denied to photo library")
            }
        }
    }
}

