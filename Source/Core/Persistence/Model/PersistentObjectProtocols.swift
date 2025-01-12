//
//  PersistentObjectProtocols.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

///
/// A persistent object that has its own JSON file.
///
protocol PersistentRootObject: PersistentModelObject {
    
    var filename: String {get}
    
    
}

///
/// Protocol that marks an object as having state that must be persisted upon app exit.
///
protocol PersistentModelObject {
    
    associatedtype T: Codable
    
    // Retrieves persistent state for this model object
    var persistentState: T {get}
}
