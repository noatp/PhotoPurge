//
//  PhotoPurgeApp.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/10/25.
//

import SwiftUI
import GoogleMobileAds

@main
struct PhotoPurgeApp: App {
    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "8bee8601f0376c96dc2b9bf96e344d0d" ]
    }
    
    var body: some Scene {
        WindowGroup {
            let dependency = Dependency()
            ContentView(views: dependency.views())
        }
    }
}
