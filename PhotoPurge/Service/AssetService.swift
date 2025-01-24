//
//  AssetService.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/21/25.
//

import Foundation
import Photos
import UIKit

struct AssetServiceConstant {
    static let imageRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.isSynchronous = false // Allow asynchronous fetching
        options.deliveryMode = .highQualityFormat
        options.version = .current
        options.isNetworkAccessAllowed = true
        return options
    }()
    static let imageRequestTargetSize: CGSize = .init(width: 900, height: 900)
    static let imageRequestContentMode: PHImageContentMode = .aspectFit
    
    static let videoRequestOptions: PHVideoRequestOptions = {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .fastFormat
        return options
    }()
    
    static let prefetchWindowSize: Int = 4
}

class AssetService: ObservableObject {
    @Published var isLoading: Bool?
    @Published var assetsGroupedByMonth: [Date: [PHAsset]]?
    @Published var deleteResult: DeleteResult?
    private let imageManager = PHImageManager.default()
    
    // for caching ---------------------------------------------------------------------------

    private let cachingManager = PHCachingImageManager()
    private var videoDownloadTasks: [PHAsset: PHImageRequestID] = [:] {
        didSet {
#if DEBUG
            print("videoDownloadTasks: \(videoDownloadTasks)\n")
#endif
        }
    }
    private var prefetchedAVPlayerItems: [PHAsset: AVPlayerItem] = [:] {
        didSet{
#if DEBUG
            print("prefetchedAVPlayerItems: \(prefetchedAVPlayerItems)\n")
#endif
        }
    }
    private var previousPrefetchedAssets: [PHAsset] = [] {
        didSet {
#if DEBUG
            print("previousPrefetchedAssets: \(previousPrefetchedAssets)\n")
#endif
        }
    }
    /*---------------------------------------------------------------------------*/
    
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
            targetSize: AssetServiceConstant.imageRequestTargetSize,
            contentMode: AssetServiceConstant.imageRequestContentMode,
            options: AssetServiceConstant.imageRequestOptions
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
    
    func fetchVideoForAsset(_ asset: PHAsset, completion: @escaping (Result<AVPlayerItem, Error>) -> Void) {
        guard let prefetchedAVPlayerItem = prefetchedAVPlayerItems[asset] else {
            let options = PHVideoRequestOptions()
            options.deliveryMode = .fastFormat
            options.isNetworkAccessAllowed = true
            
            imageManager.requestPlayerItem(
                forVideo: asset,
                options: options
            ) { avPlayerItem, info in
                if let fetchError = info?[PHImageErrorKey] as? NSError {
                    let errorMessage = "An issue occurred while fetching the video: \(fetchError.localizedDescription)."
                    let error = NSError(domain: "com.panto.photopurger.error", code: 1005, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    completion(.failure(error))
                } else if let avPlayerItem = avPlayerItem {
                    completion(.success(avPlayerItem))
                }
            }
            return
        }
        print("found prefetched yay")
        completion(.success(prefetchedAVPlayerItem))
    }
    
    func deleteAssets(_ assetsToDelete: [PHAsset], completion: @escaping (Result<Void, Error>) -> Void) {
        // Ensure we have a valid photo to delete
        guard !assetsToDelete.isEmpty else {
            let errorMessage = "You're all set! Let's move to the next month."
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
                let phError = deleteError as NSError
                if phError.domain == "PHPhotosErrorDomain" && phError.code == 3072 {
                    let errorMessage = "Having second thoughts? Whenever you are ready, tap the \"Confirm\" button."
                    let error = NSError(domain: "com.panto.photopurger.error", code: 1007, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    completion(.failure(error))
                } else {
                    let errorMessage = "An issue occurred while deleting the photos: \(deleteError.localizedDescription)"
                    let error = NSError(domain: "com.panto.photopurger.error", code: 1007, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    completion(.failure(error))
                }
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

// MARK: Caching

extension AssetService {
    func prefetchAssets(
        around index: Int,
        from allAssets: [PHAsset]
    ) {
        // Calculate the range of indices to prefetch
        let startIndex = max(0, index - AssetServiceConstant.prefetchWindowSize / 2)
        let endIndex = min(allAssets.count - 1, index + AssetServiceConstant.prefetchWindowSize / 2)
        let prefetchRange = startIndex...endIndex
        let assetsToPrefetch = Array(allAssets[prefetchRange])
        
        startCachingAssets(for: assetsToPrefetch)
        
        let assetsToStopCaching = previousPrefetchedAssets.filter { !assetsToPrefetch.contains($0) }
        stopCachingAssets(for: assetsToStopCaching)
        
        previousPrefetchedAssets = assetsToPrefetch
    }
    
    func clearCache() {
        cachingManager.stopCachingImagesForAllAssets()
        previousPrefetchedAssets.removeAll()
        videoDownloadTasks.removeAll()
    }
    
    private func startCachingAssets(for assets: [PHAsset]) {
        // Filter image assets for caching
        let imageAssets = assets.filter { $0.mediaType == .image }
        cachingManager.startCachingImages(
            for: imageAssets,
            targetSize: AssetServiceConstant.imageRequestTargetSize,
            contentMode: AssetServiceConstant.imageRequestContentMode,
            options: AssetServiceConstant.imageRequestOptions
        )
        
        // Handle video assets manually
        let videoAssets = assets.filter { $0.mediaType == .video }
        prefetchVideos(for: videoAssets)
    }
    
    private func stopCachingAssets(for assets: [PHAsset]) {
        // Filter image assets to stop caching
        let imageAssets = assets.filter { $0.mediaType == .image }
        cachingManager.stopCachingImages(for: imageAssets, targetSize: .zero, contentMode: .aspectFill, options: nil)
        
        // Cancel video downloads
        cancelVideoPrefetch(for: assets.filter { $0.mediaType == .video })
    }
    
    private func prefetchVideos(for videoAssets: [PHAsset]) {
        for videoAsset in videoAssets {
            guard videoDownloadTasks[videoAsset] == nil else { continue }
            let requestID = imageManager.requestPlayerItem(
                forVideo: videoAsset,
                options: AssetServiceConstant.videoRequestOptions
            ) { [weak self] avPlayerItem, info in
                if let fetchError = info?[PHImageErrorKey] as? NSError {
                    let errorMessage = "An issue occurred while fetching the video: \(fetchError.localizedDescription)."
                    let error = NSError(domain: "com.panto.photopurger.error", code: 1005, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                } else if let avPlayerItem = avPlayerItem {
                    self?.prefetchedAVPlayerItems[videoAsset] = avPlayerItem
                }
            }
            
            videoDownloadTasks[videoAsset] = requestID
        }
    }
    
    private func cancelVideoPrefetch(for videoAssets: [PHAsset]) {
        for videoAsset in videoAssets {
            if let requestID = videoDownloadTasks[videoAsset] {
                PHImageManager.default().cancelImageRequest(requestID)
                videoDownloadTasks.removeValue(forKey: videoAsset)
                prefetchedAVPlayerItems.removeValue(forKey: videoAsset)
            }
        }
    }
}
