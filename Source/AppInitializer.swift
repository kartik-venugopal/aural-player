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
    
    func initializeApp() {
        
        dialogController.showWindow(self)
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            for step in self.steps {
                step.execute()
            }
            
            DispatchQueue.main.async {
                
                self.dialogController.window?.close()
                self.dialogController = nil
                appModeManager.presentApp()
            }
        }
    }
}

class AppInitializationStep {
    
    let components: [AppInitializationComponent]
    
    init(components: [AppInitializationComponent]) {
        self.components = components
    }
    
    func execute() {
        
        for component in components {
            
            switch component.priority {
                
            case .userInitiated, .userInteractive:
                component.initialize(onQueue: highPriorityQueue)
                
            case .utility, .default, .unspecified:
                component.initialize(onQueue: mediumPriorityQueue)
                
            case .background:
                component.initialize(onQueue: lowPriorityQueue)
                
            @unknown default:
                return
            }
        }
    }
}

protocol AppInitializationComponent {
    
    var priority: DispatchQoS.QoSClass {get}
    
    func initialize(onQueue queue: OperationQueue)
}
