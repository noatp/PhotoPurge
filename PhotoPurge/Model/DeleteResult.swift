//
//  DeleteResult.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/18/25.
//

struct DeleteResult: Hashable {
    let photosDeleted: Int
    let videosDeleted: Int
    let fileSizeDeleted: Int64
    
    init(photosDeleted: Int = 0, videosDeleted: Int = 0, fileSizeDeleted: Int64 = 0) {
        self.photosDeleted = photosDeleted
        self.videosDeleted = videosDeleted
        self.fileSizeDeleted = fileSizeDeleted
    }
}
