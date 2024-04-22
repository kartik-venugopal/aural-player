//
//  AppDelegate.swift
//  Aural-iOS
//
//  Created by Kartik Venugopal on 06/01/22.
//

import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("\nHome Dir is: \(NSHomeDirectory()), User Docs Dir is: \(FilesAndPaths.userDocumentsDirectory.path)\n")
        
        let dir = URL(fileURLWithPath: NSHomeDirectory())

        for child in dir.children ?? [] {
            print("Child: \(child.lastPathComponent)")
        }
        
        // Override point for customization after application launch.
        playQueueDelegate.loadTracks(from: FilesAndPaths.userDocumentsDirectory.children ?? [], autoplay: false)
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        tearDown()
    }
    
    private lazy var tearDownOpQueue: OperationQueue = OperationQueue(opCount: 2, qos: .userInteractive)
    
    // Called when app exits
    private func tearDown() {
        
        print("\nTearing down app ...\n")
        
        // App state persistence and shutting down the audio engine can be performed concurrently
        // on two background threads to save some time when exiting the app.
        
        let _persistentStateOnExit = persistentStateOnExit
        
        tearDownOpQueue.addOperations([
            
            // Persist app state to disk.
            BlockOperation {
                persistenceManager.save(_persistentStateOnExit)
            },
            
            // Tear down the player and audio engine.
            BlockOperation {
                player.tearDown()
                audioGraph.tearDown()
            }
            
        ], waitUntilFinished: true)
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

let appVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString", String.self]!
