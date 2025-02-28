//
//  PhotoLibraryProtocol.swift
//  PhotoPurger
//
//  Created by Toan Pham on 2/28/25.
//

import Photos

protocol PhotoLibraryProtocol {
    func requestAuthorization(for accessLevel: PHAccessLevel, handler: @escaping (PHAuthorizationStatus) -> Void)
}
