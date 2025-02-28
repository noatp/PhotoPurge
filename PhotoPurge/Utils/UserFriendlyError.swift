//
//  UserFriendlyError.swift
//  PhotoPurger
//
//  Created by Toan Pham on 2/27/25.
//

import Foundation

protocol UserFriendlyError: LocalizedError {
    /// A user-facing message that hides technical details.
    var userFacingMessage: String { get }
}
