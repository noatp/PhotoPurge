//
//  AssetService.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/21/25.
//

import Foundation
import Photos
import UIKit

class AssetService: ObservableObject {
    @Published var isLoading: Bool?
    @Published var assetsGroupedByMonth: [Date: [PHAsset]]?
    @Published var deleteResult: DeleteResult?
    
    private let imageManager = PHImageManager.default()
    
    func requestAccess(completion: @escaping (Result<Void, Error>) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .denied:
                let errorMessage = "Access to photos is denied. Please go to Settings > Privacy > Photos to enable access."
                let error = NSError(domain: "com.panto.photopurger.error", code: 1001, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                completion(.failure(error))
            case .authorized:
                completion(.success(()))
            default:
                let errorMessage = "Access to photos is not fully authorized. Please go to Settings > Privacy > Photos to enable access."
                let error = NSError(domain: "com.panto.photopurger.error", code: 1002, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                completion(.failure(error))
            }
        }
    }
    
    func fetchAssets() {
        print("LOAD DATA")
        isLoading = true
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let assets = PHAsset.fetchAssets(with: fetchOptions)
        
        var groupedByMonth: [Date: [PHAsset]] = [:]
        
        assets.enumerateObjects { asset, _, _ in
            if let creationDate = asset.creationDate {
                let startOfMonth = Util.startOfMonth(from: creationDate)
                groupedByMonth[startOfMonth, default: []].append(asset)
            }
            else {
#if DEBUG
                print("Warning: Asset has no creation date.")
#endif
            }
        }
        
        self.assetsGroupedByMonth = groupedByMonth
        self.isLoading = false
    }
    
    func fetchPhotoForAsset(_ asset: PHAsset, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false // Allow asynchronous fetching
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        imageManager.requestImage(
            for: asset,
            targetSize: .init(width: 900, height: 900),
            contentMode: .aspectFit,
            options: options
        ) { image, info in
            if let fetchError = info?[PHImageErrorKey] as? NSError {
                let errorMessage = "An issue occurred while fetching the image: \(fetchError.localizedDescription)"
                let error = NSError(domain: "com.panto.photopurger.error", code: 1003, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                completion(.failure(error))
            } else if let image = image {
                completion(.success(image))
            } else {
                let errorMessage = "An issue occurred while fetching the image."
                let error = NSError(domain: "com.panto.photopurger.error", code: 1004, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                completion(.failure(error))
            }
        }
    }
    
    func fetchVideoForAsset(_ asset: PHAsset, completion: @escaping (Result<URL, Error>) -> Void) {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .fastFormat
        options.isNetworkAccessAllowed = true
        
        imageManager.requestAVAsset(
            forVideo: asset,
            options: options) { avAsset, _, _ in
                if let urlAsset = avAsset as? AVURLAsset {
                    // If successfully fetched, pass the URL to completion as success
                    completion(.success(urlAsset.url))
                } else {
                    let errorMessage = "An issue occurred while fetching the video."
                    let error = NSError(domain: "com.panto.photopurger.error", code: 1005, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    completion(.failure(error))
                }
            }
    }

    
    func deleteAssets(_ assetsToDelete: [PHAsset], completion: @escaping (Result<Void, Error>) -> Void) {
        // Ensure we have a valid photo to delete
        guard !assetsToDelete.isEmpty else {
            let errorMessage = "You have not selected any photos to delete."
            let error = NSError(domain: "com.panto.photopurger.error", code: 1006, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            completion(.failure(error))
            return
        }
        
        // Perform deletion in a safe way
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assetsToDelete as NSFastEnumeration)
        }) { [weak self] success, deleteError in
            if success {
                self?.calculateTotalAssetSize(assets: assetsToDelete) { [weak self] result in
                    switch result {
                    case .success(let sizeDeleted):
                        self?.deleteResult = DeleteResult(
                            photosDeleted: assetsToDelete.count { $0.mediaType == .image },
                            videosDeleted: assetsToDelete.count { $0.mediaType == .video },
                            fileSizeDeleted: sizeDeleted
                        )
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            } else if let deleteError = deleteError {
                let errorMessage = "An issue occurred while deleting the photos: \(deleteError.localizedDescription)"
                let error = NSError(domain: "com.panto.photopurger.error", code: 1007, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                completion(.failure(error))
            }
        }
    }
    
    func calculateTotalAssetSize(assets: [PHAsset], completion: @escaping (Result<Int64, Error>) -> Void) {
        var totalSize: Int64 = 0
        let dispatchGroup = DispatchGroup()
        var encounteredError: Error?
        
        for asset in assets {
            if asset.mediaType == .image {
                let options = PHImageRequestOptions()
                options.isNetworkAccessAllowed = true
                
                dispatchGroup.enter()
                imageManager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                    if let data = data {
                        totalSize += Int64(data.count)
                        print("Image size: \(data.count) bytes")
                    } else {
                        encounteredError = NSError(domain: "com.panto.photopurger.error", code: 1008, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch image data or image is not available"])
                    }
                    dispatchGroup.leave()
                }
            } else if asset.mediaType == .video {
                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true  // This allows downloading the video if needed
                
                dispatchGroup.enter()
                imageManager.requestAVAsset(forVideo: asset, options: options) { asset, _, _ in
                    if let avAsset = asset as? AVURLAsset {
                        let fileURL = avAsset.url
                        do {
                            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                            if let fileSize = attributes[.size] as? NSNumber {
                                totalSize += fileSize.int64Value
                                print("Video size: \(fileSize.int64Value) bytes")
                            }
                        } catch let requestError {
                            encounteredError = NSError(domain: "com.panto.photopurger.error", code: 1009, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch AVAsset for video: \(requestError.localizedDescription)"])
                        }
                    } else {
                        encounteredError = NSError(domain: "com.panto.photopurger.error", code: 1010, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch AVAsset for video"])
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if let error = encounteredError {
                completion(.failure(error))
            } else {
                completion(.success(totalSize))
            }
        }
    }

}
