//
//  PhotoPurgeApp.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/10/25.
//

import SwiftUI
import GoogleMobileAds
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
      return true
  }
}

@main
struct PhotoPurgeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            let dependency = Dependency()
            let views = dependency.views()
            views.contentView()
                .environment(\.viewsFactory, views)
        }
    }
}

// Create a custom environment key for Dependency.Views
struct ViewsEnvironmentKey: EnvironmentKey {
    static let defaultValue: Dependency.Views = Dependency().views()
}

// Extend EnvironmentValues to include the custom key
extension EnvironmentValues {
    var viewsFactory: Dependency.Views {
        get { self[ViewsEnvironmentKey.self] }
        set { self[ViewsEnvironmentKey.self] = newValue }
    }
}
