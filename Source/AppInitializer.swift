//
// AppInitializer.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

fileprivate let highPriorityQueue: OperationQueue = .init(opCount: max(4, System.physicalCores), qos: .userInteractive)
fileprivate let mediumPriorityQueue: OperationQueue = .init(opCount: max(2, System.physicalCores / 2), qos: .utility)
fileprivate let lowPriorityQueue: OperationQueue = .init(opCount: max(2, System.physicalCores / 2), qos: .background)

class AppInitializer {
    
    let steps: [AppInitializationStep]
    
    private var dialogController: AppInitializerDialogController! = .init()
    
    init(steps: [AppInitializationStep]) {
        self.steps = steps
    }
    
    func initializeApp(completionHandler: @escaping () -> Void) {
        
        dialogController.showWindow(self)
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            for step in self.steps {
            
                DispatchQueue.main.async {
                    self.dialogController.stepChanged(to: step)
                }
                
                step.execute()
            }
            
            DispatchQueue.main.async {
                
                self.dialogController.window?.close()
                self.dialogController = nil
                
                appModeManager.presentApp()
                
                completionHandler()
            }
        }
    }
}

class AppInitializationStep {
    
    let description: String
    let components: [AppInitializationComponent]
    let isBlocking: Bool
    
    init(description: String, components: [AppInitializationComponent], isBlocking: Bool) {
        
        self.description = description
        self.components = components
        self.isBlocking = isBlocking
    }
    
    func execute() {
        
        var queues: Set<OperationQueue> = Set()
        
        for component in components {
            
            switch component.priority {
                
            case .userInitiated, .userInteractive:
                
                component.initialize(onQueue: highPriorityQueue)
                queues.insert(highPriorityQueue)
                
            case .utility, .default, .unspecified:
                
                component.initialize(onQueue: mediumPriorityQueue)
                queues.insert(mediumPriorityQueue)
                
            case .background:
                
                component.initialize(onQueue: lowPriorityQueue)
                queues.insert(lowPriorityQueue)
                
            @unknown default:
                return
            }
        }
        
        if isBlocking {
            queues.forEach {$0.waitUntilAllOperationsAreFinished()}
        }
    }
}

protocol AppInitializationComponent {
    
    var priority: DispatchQoS.QoSClass {get}
    
    func initialize(onQueue queue: OperationQueue)
}

///
/// Does nothing ... simply referencing objects in the caller will cause them to be eagerly initialized.
///
func eagerlyInitializeObjects(_ : Any...) {}

class PersistentStateInitializer: AppInitializationComponent {
    
    var priority: DispatchQoS.QoSClass {
        .userInteractive
    }
    
    func initialize(onQueue queue: OperationQueue) {
        
        queue.addOperation {
            
            // Force eager loading of persistent state
            eagerlyInitializeObjects(appPersistentState)
        }
    }
}

class SecondaryObjectsInitializer: AppInitializationComponent {
    
    var priority: DispatchQoS.QoSClass {
        .background
    }
    
    func initialize(onQueue queue: OperationQueue) {
        
        queue.addOperation {
            
            // Force initialization of objects that would not be initialized soon enough otherwise
            // (they are not referred to in code that is executed on app startup).
            
            //        _ = libraryDelegate
            
//            eagerlyInitializeObjects(mediaKeyHandler, remoteControlManager, replayGainScanner)
            eagerlyInitializeObjects(mediaKeyHandler, remoteControlManager)
            WaveformView.initializeImageCache()
            lastFMClient.retryFailedScrobbleAttempts()
        }
    }
}
