//
//  MenuItemMappable.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol MenuItemMappable {
    
    var name: String {get}
    
    var representedObject: Any? {get}
}

extension MenuItemMappable {
    
    var representedObject: Any? {nil}
}
