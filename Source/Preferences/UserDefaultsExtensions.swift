//
//  UserDefaultsExtensions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

extension UserDefaults {
    
    subscript(_ key: String) -> Any? {
        
        get {self.object(forKey: key)}
        set {self.setValue(newValue, forKey: key)}
    }
}
