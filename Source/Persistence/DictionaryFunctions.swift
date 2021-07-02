//
//  DictionaryFunctions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

extension NSDictionary {
    
    func persistentObjectValue<T: PersistentStateProtocol>(forKey key: String, ofType type: T.Type) -> T? {
        
        if let dict = self[key, NSDictionary.self] {
            return T.init(dict)
        }
        
        return nil
    }
    
    func persistentFactoryObjectValue<T: PersistentStateFactoryProtocol, U: PersistentStateProtocol>(forKey key: String, ofType type: T.Type) -> U? {
        
        if let dict = self[key, NSDictionary.self] {
            return T.deserialize(dict) as? U
        }
        
        return nil
    }
    
    func persistentObjectArrayValue<T: PersistentStateProtocol>(forKey key: String, ofType type: T.Type) -> [T]? {
        
        if let array = self[key, [NSDictionary].self] {
            return array.compactMap {T.init($0)}
        }
        
        return nil
    }
}
