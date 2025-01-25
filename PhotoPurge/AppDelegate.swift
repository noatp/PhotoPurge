//
//  AppDelegate.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/25/25.
//

import GoogleMobileAds

class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    GADMobileAds.sharedInstance().start(completionHandler: nil)
    GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "8bee8601f0376c96dc2b9bf96e344d0d" ]

    return true
  }
}
