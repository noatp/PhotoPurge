//
//  DisplayingAsset.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/18/25.
//

import UIKit

enum AssetType {
    case photo
    case video
}

struct DisplayingAsset {
    let assetType: AssetType
    let videoURL: URL?
    let image: UIImage?
    
    init(assetType: AssetType, videoURL: URL? = nil, image: UIImage? = nil) {
        self.assetType = assetType
        self.videoURL = videoURL
        self.image = image
    }
}
