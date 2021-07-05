//
//  PersistentModelObject.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
protocol PersistentModelObject {
    
    associatedtype T: Codable
    
    // Retrieves persistent state for this model object
    var persistentState: T {get}
}
