//
//  MonthPickerVM.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/11/25.
//

import Photos
import UIKit

class MonthPickerVM: ObservableObject {
    @Published var isLoading: Bool
    @Published var groupedByYear: [Int: [Date: [PHAsset]]]
    
    init(
        isLoading: Bool = false,
        groupedByYear: [Int : [Date : [PHAsset]]] = [:]
    ) {
        self.isLoading = isLoading
        self.groupedByYear = groupedByYear
    }

    func getPhotosByMonth() {
        isLoading = true
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            guard status == .authorized else {
                DispatchQueue.main.async { [weak self] in
                    self?.isLoading = false
                }
                return
            }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let assets = PHAsset.fetchAssets(with: fetchOptions)
            
            var groupedPhotos: [Int: [Date: [PHAsset]]] = [:]  // Year -> Month -> Photos
            
            assets.enumerateObjects { asset, _, _ in
                if let creationDate = asset.creationDate {
                    let startOfMonth = self.startOfMonth(from: creationDate)
                    let year = Calendar.current.component(.year, from: creationDate)
                    
                    if groupedPhotos[year] == nil {
                        groupedPhotos[year] = [:]
                    }
                    
                    groupedPhotos[year]?[startOfMonth, default: []].append(asset)
                }
            }
            
            DispatchQueue.main.async {
                self.groupedByYear = groupedPhotos
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
