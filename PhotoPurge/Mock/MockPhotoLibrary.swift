//
//  MockPhotoLibrary.swift
//  PhotoPurger
//
//  Created by Toan Pham on 2/28/25.
//

import Photos

class MockPhotoLibrary: PhotoLibraryProtocol {
    var authorizationStatus: PHAuthorizationStatus
    
    init(authorizationStatus: PHAuthorizationStatus) {
        self.authorizationStatus = authorizationStatus
    }
    
    func requestAuthorization(for accessLevel: PHAccessLevel, handler: @escaping (PHAuthorizationStatus) -> Void) {
        handler(authorizationStatus)
    }
}
