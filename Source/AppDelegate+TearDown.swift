//
//  AppDelegate+TearDown.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

fileprivate var recurringPersistenceOpQueue: OperationQueue = OperationQueue(opCount: 1, qos: .background)

fileprivate var tearDownOpQueue: OperationQueue = OperationQueue(opCount: 2, qos: .userInteractive)

extension AppDelegate {
    
    // Called when app exits
    func tearDown() {
        
        // App state persistence and shutting down the audio engine can be performed concurrently
        // on two background threads to save some time when exiting the app.
        
        let _persistentStateOnExit = persistentStateOnExit
        
        tearDownOpQueue.addOperations([
            
            // Persist app state to disk.
            BlockOperation {
                
                if recurringPersistenceOpQueue.operationCount == 0 {
                    
                    // If the recurring persistence task is not running, save state normally.
                    persistenceManager.save(persistentState: _persistentStateOnExit)
                    
                } else {
                    
                    // If the recurring persistence task is running, just wait for it to finish.
                    recurringPersistenceOpQueue.waitUntilAllOperationsAreFinished()
                }
            },
            
            // Tear down the player and audio engine.
            BlockOperation {
                
                player.tearDown()
                audioGraph.tearDown()
            },
            
            // Metadata state
            BlockOperation {
                persistenceManager.save(metadataState: metadataRegistry.persistentState)
            }
            
        ], waitUntilFinished: true)
    }
    
//    func savePersistentState() {
//        
//        // TODO: Store Window frames in memory from Window delegates (onMove and onResize) so this can be done totally from a background thread.
//        
//        let _persistentStateOnExit = persistentStateOnExit
//        
//        // Wait a bit for the main thread task to finish.
//        DispatchQueue.global(qos: .background).async {
//            
//            // Make sure app is not tearing down ! If it is, do nothing here.
//            if tearDownOpQueue.operationCount == 0 {
//                
//                recurringPersistenceOpQueue.addOperation {
//                    persistenceManager.save(persistentState: _persistentStateOnExit)
//                }
//            }
//        }
//    }
}
