//
//  AssetServiceTests.swift
//  PhotoPurgerTests
//
//  Created by Toan Pham on 2/28/25.
//

import XCTest
import Photos
@testable import PhotoPurger

class AssetServiceTests: XCTestCase {

    // MARK: - Setup for Swizzling (Optional)
    // In order to simulate different authorization statuses, you can use method swizzling
    // to override PHPhotoLibrary.requestAuthorization. For a full solution, consider
    // abstracting the photo library behind a protocol that you can then mock in tests.

    override func setUp() {
        super.setUp()
        // If using swizzling, perform it here.
    }
    
    override func tearDown() {
        // Undo swizzling if applied.
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func testRequestAccess_Success() {
        // Simulate an authorized status.
        // If not swizzling, ensure your test environment is in a state where access is authorized.
        let service = AssetService()
        let expectation = self.expectation(description: "requestAccess completes with success")
        
        service.requestAccess { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got error: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testRequestAccess_Failure() {
        // To simulate a denied status, you would need to override PHPhotoLibrary.requestAuthorization
        // (e.g. via swizzling) so that it calls the completion handler with .denied.
        // The following assumes you have swizzled or injected a fake that returns .denied.
        
        let service = AssetService()
        let expectation = self.expectation(description: "requestAccess completes with failure")
        
        service.requestAccess { result in
            switch result {
            case .success:
                XCTFail("Expected failure when access is denied, but got success.")
            case .failure(let error):
                // Check that the error is the expected .accessDenied error
                if case AssetServiceError.accessDenied = error {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected accessDenied error but got: \(error)")
                }
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
