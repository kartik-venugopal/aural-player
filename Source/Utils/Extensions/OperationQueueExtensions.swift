//
//  OperationQueueExtensions.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

extension OperationQueue {
    
    convenience init(opCount: Int, qos: DispatchQoS.QoSClass) {
        
        self.init()
        self.maxConcurrentOperationCount = opCount
        self.underlyingQueue = .global(qos: qos)
    }
}
