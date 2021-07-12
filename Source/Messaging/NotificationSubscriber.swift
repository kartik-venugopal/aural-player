//
//  NotificationSubscriber.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    A contract for all subscribers of notifications
 */
protocol NotificationSubscriber {
    
    // A unique identifer for this subscriber (typically the class name and some instance identifier like hashValue)
    var subscriberId: String {get}
}

// Default implementations
extension NotificationSubscriber {
    
    // CAUTION - For implementation classes of which multiple instances are subscribers, ensure that hashValue is unique across all those instances.
    
    // Default implementation of subscriberId.
    // NOTE - Subscribers should always override this implementation if they are not an NSObject and not a singleton instance.
    var subscriberId: String {
        
        let className = String(describing: Mirror(reflecting: self).subjectType)
        
        // If the subscriber is an NSObject, its hashValue is appended to the subscriberId to provide more uniqueness.
        if let object = self as? NSObject {
            return "\(className)-\(object.hashValue)"
        }
        
        // For singleton objects, the className will suffice as a unique subscriberId.
        return className
    }
}

protocol NotificationPublisher {
    
}
