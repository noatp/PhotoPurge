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
                completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
            case .authorized:
                completion(.success(()))
            default:
                break
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
        }
        
        self.assetsGroupedByMonth = groupedByMonth
        self.isLoading = false
    }

    
    func fetchPhotoForAsset(_ asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
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
    
    func fetchVideoForAsset(_ asset: PHAsset, completion: @escaping (URL?) -> Void) {
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
    
    func deleteAssets(_ assetsToDelete: [PHAsset], completion: @escaping (Result<Void, Error>) -> Void) {
        // Ensure we have a valid photo to delete
        guard !assetsToDelete.isEmpty else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
            return
        }
        
        // Perform deletion in a safe way
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assetsToDelete as NSFastEnumeration)
        }) { [weak self] success, error in
            if success {
                self?.calculateTotalAssetSize(assets: assetsToDelete) { [weak self] sizeDeleted in
                    self?.deleteResult = DeleteResult(
                        photosDeleted: assetsToDelete.count { $0.mediaType == .image },
                        videosDeleted: assetsToDelete.count { $0.mediaType == .video },
                        fileSizeDeleted: sizeDeleted
                    )
                    completion(.success(()))
                }
                
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    func calculateTotalAssetSize(assets: [PHAsset], completion: @escaping (Int64) -> Void) {
        var totalSize: Int64 = 0
        let dispatchGroup = DispatchGroup()
        
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
                        print("Failed to fetch image data or image is not available")
                    }
                    dispatchGroup.leave()
                }
            } else if asset.mediaType == .video {
                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true  // This allows downloading the video if needed
                
                dispatchGroup.enter()
                imageManager.requestAVAsset(forVideo: asset, options: options) { asset, _, _ in
                    if let avAsset = asset as? AVURLAsset {
                        // Now we have the AVURLAsset, and we can fetch its size
                        let fileURL = avAsset.url
                        do {
                            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                            if let fileSize = attributes[.size] as? NSNumber {
                                totalSize += fileSize.int64Value
                                print("Video size: \(fileSize.int64Value) bytes")
                            }
                        } catch {
                            print("Failed to fetch file size for video: \(error.localizedDescription)")
                        }
                    } else {
                        print("Failed to fetch AVAsset for video")
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(totalSize)
        }
    }
}
