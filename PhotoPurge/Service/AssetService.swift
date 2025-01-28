//
//  AssetService.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/21/25.
//

import Foundation
import Photos
import UIKit

struct AssetServiceConstants {
    static let imageRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.isSynchronous = false // Allow asynchronous fetching
        options.deliveryMode = .highQualityFormat
        options.version = .current
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        return options
    }()
    static let imageRequestTargetSize: CGSize = .init(width: 900, height: 900)
    static let imageRequestContentMode: PHImageContentMode = .aspectFit
    
    static let videoRequestOptions: PHVideoRequestOptions = {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .fastFormat
        options.version = .current
        return options
    }()
    
    static let prefetchWindowSize: Int = 10
}

enum AssetServiceError: LocalizedError {
    case accessDenied (message: String)
    case authorizationIssue (message: String)
    case fetchImageFailed_1003 (message: String)
    case fetchImageFailed_1004 (message: String)
    case fetchVideoFailed_1005 (message: String)
    case fetchVideoFailed_1006 (message: String)
    case deleteEmptyList (message: String)
    case denyDeletePrompt (message: String)
    case deleteAssetFailed (message: String)
    case failedToFetchImageDataForSize (message: String)
    case failedToFetchVideoDataForSize (message: String)
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            "Access to photos is denied. Please go to Settings > Privacy > Photos to enable access."
        case .authorizationIssue:
            "Access to photos is not fully authorized. Please go to Settings > Privacy > Photos to enable access."
        case .fetchImageFailed_1003:
            "An issue occurred while fetching the image - 1003"
        case .fetchImageFailed_1004:
            "An issue occurred while fetching the image - 1004"
        case .fetchVideoFailed_1005:
            "An issue occurred while fetching the video - 1005"
        case .fetchVideoFailed_1006:
            "An issue occurred while fetching the video - 1006"
        case .deleteEmptyList:
            "You're all set! Let's move to the next month."
        case .denyDeletePrompt:
            "Having second thoughts? Whenever you are ready, tap the \"Confirm\" button."
        case .deleteAssetFailed:
            "An issue occurred while deleting the photos."
        case .failedToFetchImageDataForSize:
            "An issue occurred while fetching image data for size calculating."
        case .failedToFetchVideoDataForSize:
            "An issue occurred while fetching video data for size calculating."
        }
    }
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
            //            print("videoDownloadTasks: \(videoDownloadTasks)\n")
#endif
        }
    }
    private var prefetchedAVPlayerItems: [PHAsset: AVPlayerItem] = [:] {
        didSet{
#if DEBUG
            //            print("prefetchedAVPlayerItems: \(prefetchedAVPlayerItems)\n")
#endif
        }
    }
    private var previousPrefetchedAssets: [PHAsset] = [] {
        didSet {
#if DEBUG
            //            print("previousPrefetchedAssets: \(previousPrefetchedAssets)\n")
#endif
        }
    }
    /*---------------------------------------------------------------------------*/
    
    func requestAccess(completion: @escaping (Result<Void, AssetServiceError>) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .denied:
                completion(.failure(AssetServiceError.accessDenied(message: "")))
            case .authorized:
                completion(.success(()))
            default:
                completion(.failure(AssetServiceError.authorizationIssue(message: "\(status.rawValue)")))
            }
        }
    }
    
    func fetchAssets() {
#if DEBUG
        print("LOAD DATA")
#endif
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
    
    func fetchPhotoForAsset(_ asset: PHAsset, completion: @escaping (Result<UIImage, AssetServiceError>) -> Void) {
        imageManager.requestImage(
            for: asset,
            targetSize: AssetServiceConstants.imageRequestTargetSize,
            contentMode: AssetServiceConstants.imageRequestContentMode,
            options: AssetServiceConstants.imageRequestOptions
        ) { image, info in
            if let fetchError = info?[PHImageErrorKey] as? NSError {
                completion(.failure(AssetServiceError.fetchImageFailed_1003(message: fetchError.localizedDescription)))
            } else if let image = image {
                completion(.success(image))
            } else {
                completion(.failure(AssetServiceError.fetchImageFailed_1004(message: "")))
            }
        }
    }
    
    func fetchVideoForAsset(_ asset: PHAsset, completion: @escaping (Result<AVPlayerItem, AssetServiceError>) -> Void) {
        // If we already have a prefetched AVPlayerItem in our cache/dictionary, return it immediately
        if let prefetchedAVPlayerItem = prefetchedAVPlayerItems[asset] {
            completion(.success(prefetchedAVPlayerItem))
            return
        }
        
        // Otherwise, request the AVAsset instead of an AVPlayerItem
        requestAVAsset(asset, completion: completion)
    }
    
    private func requestAVAsset(_ asset: PHAsset, completion: @escaping (Result<AVPlayerItem, AssetServiceError>) -> Void) {
        imageManager.requestAVAsset(forVideo: asset, options: AssetServiceConstants.videoRequestOptions) { avAsset, audioMix, info in
            if let fetchError = info?[PHImageErrorKey] as? NSError {
                completion(.failure(AssetServiceError.fetchVideoFailed_1005(message: fetchError.localizedDescription)))
            } else if let avAsset = avAsset {
                Task {
                    do {
                        let _ = try await avAsset.load(.preferredTransform, .tracks, .duration, .metadata)
                        let playerItem = await AVPlayerItem(asset: avAsset)
                        
                        completion(.success(playerItem))

                    } catch {
#if DEBUG
                        print("Failed to load transform: \(error)")
#endif
                    }
                }
            } else {
                completion(.failure(AssetServiceError.fetchVideoFailed_1006(message: "")))
            }
        }
    }
    
    func deleteAssets(_ assetsToDelete: [PHAsset], completion: @escaping (Result<Void, AssetServiceError>) -> Void) {
        // Ensure we have a valid photo to delete
        guard !assetsToDelete.isEmpty else {
            completion(.failure(AssetServiceError.deleteEmptyList(message: "")))
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
                    completion(.failure(AssetServiceError.denyDeletePrompt(message: "")))
                } else {
                    completion(.failure(AssetServiceError.deleteAssetFailed(message: deleteError.localizedDescription)))
                }
            }
        }
    }
    
    func calculateTotalAssetSize(assets: [PHAsset], completion: @escaping (Result<Int64, AssetServiceError>) -> Void) {
        var totalSize: Int64 = 0
        let dispatchGroup = DispatchGroup()
        var encounteredError: AssetServiceError?
        
        for asset in assets {
            if asset.mediaType == .image {
                let options = PHImageRequestOptions()
                options.isNetworkAccessAllowed = true
                
                dispatchGroup.enter()
                imageManager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                    if let data = data {
                        totalSize += Int64(data.count)
                    } else {
                        encounteredError = AssetServiceError.failedToFetchImageDataForSize(message: "")
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
                            }
                        } catch let requestError {
                            encounteredError = AssetServiceError.failedToFetchVideoDataForSize(message: requestError.localizedDescription)
                        }
                    } else {
                        encounteredError = AssetServiceError.failedToFetchVideoDataForSize(message: "")
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if let error = encounteredError {
                completion(.success(totalSize))
#if DEBUG
                print("Error calculating total asset size: \(error)")
#endif
//                completion(.failure(error))
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
        let startIndex = max(0, index - AssetServiceConstants.prefetchWindowSize * 2 / 10)
        let endIndex = min(allAssets.count - 1, index + AssetServiceConstants.prefetchWindowSize * 8 / 10)
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
        prefetchedAVPlayerItems.removeAll()
        videoDownloadTasks.removeAll()
    }
    
    private func startCachingAssets(for assets: [PHAsset]) {
        // Filter image assets for caching
        let imageAssets = assets.filter { $0.mediaType == .image }
        cachingManager.startCachingImages(
            for: imageAssets,
            targetSize: AssetServiceConstants.imageRequestTargetSize,
            contentMode: AssetServiceConstants.imageRequestContentMode,
            options: AssetServiceConstants.imageRequestOptions
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
            let requestID = imageManager.requestAVAsset(forVideo: videoAsset, options: AssetServiceConstants.videoRequestOptions)
            { [weak self] avAsset, audioMix, info in
                if let fetchError = info?[PHImageErrorKey] as? NSError {
#if DEBUG
                    print(fetchError.localizedDescription)
#endif
                } else if let avAsset = avAsset {
                    Task {
                        do {
                            let _ = try await avAsset.load(.preferredTransform, .tracks, .duration, .metadata)
                            let playerItem = await AVPlayerItem(asset: avAsset)
                            
                            self?.prefetchedAVPlayerItems[videoAsset] = playerItem

                        } catch {
#if DEBUG
                            print("Failed to load transform: \(error)")
#endif
                        }
                    }
                } else {
#if DEBUG
                    print("Warning: unable to retrieve video")
#endif
                }
            }
            
            videoDownloadTasks[videoAsset] = requestID
        }
    }
    
    private func preparePlayerItem(_ playerItem: AVPlayerItem) {
        Task {
            let asset = await playerItem.asset
            do {
                let _ = try await asset.load(.tracks, .duration, .preferredTransform)
            } catch let error {
#if DEBUG
                print(error.localizedDescription)
#endif
            }
        }
    }
    
    private func cancelVideoPrefetch(for videoAssets: [PHAsset]) {
        for videoAsset in videoAssets {
            if let requestID = videoDownloadTasks[videoAsset] {
                PHImageManager.default().cancelImageRequest(requestID)
            }
            videoDownloadTasks.removeValue(forKey: videoAsset)
            prefetchedAVPlayerItems.removeValue(forKey: videoAsset)
        }
    }
}
