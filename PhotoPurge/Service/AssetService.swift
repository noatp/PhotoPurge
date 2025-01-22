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
    @Published var assetsGroupedByMonthYear: [Int: [Date: [PHAsset]]]?
    @Published var assetsByMonth: (Date, [PHAsset])?
    
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
        
        var groupedPhotos: [Int: [Date: [PHAsset]]] = [:]  // Year -> Month -> Photos
        
        assets.enumerateObjects { asset, _, _ in
            if let creationDate = asset.creationDate {
                let startOfMonth = Util.startOfMonth(from: creationDate)
                let year = Calendar.current.component(.year, from: creationDate)
                
                if groupedPhotos[year] == nil {
                    groupedPhotos[year] = [:]
                }
                
                groupedPhotos[year]?[startOfMonth, default: []].append(asset)
            }
        }
        
        self.assetsGroupedByMonthYear = groupedPhotos
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
        }) { success, error in
            if success {
                let deleteResult = DeleteResult(
                    photosDeleted: assetsToDelete.count { $0.mediaType == .image },
                    videosDeleted: assetsToDelete.count { $0.mediaType == .video }
                )
                completion(.success(()))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    func selectMonthWithDate(_ selectedDate: Date) {
        guard let assetsGroupedByMonthYear else { return }
        let selectedYear = Util.getYear(from: selectedDate)
        guard let assetsOfYear = assetsGroupedByMonthYear[selectedYear],
              let assets = assetsOfYear[selectedDate]
        else { return }
        assetsByMonth = (selectedDate, assets)
    }
}
