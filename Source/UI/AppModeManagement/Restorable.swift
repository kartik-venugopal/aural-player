//
//  Restorable.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

protocol Restorable {
    
    func restore()
    
    static func restore()
}

extension Restorable {
    
    func restore() {}
    
    static func restore() {}
}

protocol DestroyableAndRestorable: Destroyable, Restorable {}
