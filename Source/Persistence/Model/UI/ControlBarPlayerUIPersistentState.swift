//
//  ControlBarPlayerUIPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class ControlBarPlayerUIPersistentState: PersistentStateProtocol {
    
    var windowFrame: NSRect?
    
    init() {}
    
    required init?(_ map: NSDictionary) {
        
        windowFrame = map.nsRectValue(forKey: "windowFrame")
    }
}

extension ControlBarPlayerViewState {
    
    static func initialize(_ persistentState: ControlBarPlayerUIPersistentState?) {
        windowFrame = persistentState?.windowFrame
    }
    
    static var persistentState: ControlBarPlayerUIPersistentState {
        
        let state = ControlBarPlayerUIPersistentState()
        state.windowFrame = windowFrame
        return state
    }
}
