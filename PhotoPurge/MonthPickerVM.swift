//
//  MonthPickerVM.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/11/25.
//

import Photos
import UIKit

class MonthPickerVM: ObservableObject {
    @Published var photoGroups: [Date: [PHAsset]] = [:]
    @Published var isLoading: Bool = false
    
    func getPhotosByMonth() {
        isLoading = true
        // Request access to the photo library
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            guard status == .authorized else {
                DispatchQueue.main.async { [weak self] in
                    self?.isLoading = false
                }
                return
            }
            
            // Fetch all photos
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            // Group photos by month
            var groupedPhotos: [Date: [PHAsset]] = [:]  // Store with Date key for sorting
            
            assets.enumerateObjects { asset, _, _ in
                if let creationDate = asset.creationDate {
                    let startOfMonth = self.startOfMonth(from: creationDate)  // Use first day of the month
                    groupedPhotos[startOfMonth, default: []].append(asset)
                }
            }
            
            DispatchQueue.main.async {
                self.photoGroups = groupedPhotos
                self.isLoading = false
            }
        }
    }
    
    private func startOfMonth(from date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
}
