//
//  UserDefaultsExtensions.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

extension UserDefaults {

    ///
    /// A convenient way to access / mutate key-value pairs in this **UserDefaults** instance.
    ///
    subscript(_ key: String) -> Any? {
        
        get {object(forKey: key)}
        set {setValue(newValue, forKey: key)}
    }
}
