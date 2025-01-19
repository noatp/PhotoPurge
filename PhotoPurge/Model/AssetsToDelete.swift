//
//  PhotosToDelete.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/18/25.
//

import Foundation
import Photos

struct AssetsToDelete: Hashable {
    let date: Date
    let assets: [PHAsset]
    
    init(date: Date, assets: [PHAsset]) {
        self.date = date
        self.assets = assets
    }
}
