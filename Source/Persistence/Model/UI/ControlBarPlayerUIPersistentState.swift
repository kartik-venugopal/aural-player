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
    var cornerRadius: CGFloat?
    
    init() {}
    
    required init?(_ map: NSDictionary) {
        
        windowFrame = map.nsRectValue(forKey: "windowFrame")
        cornerRadius = map.cgFloatValue(forKey: "cornerRadius")
    }
}

extension ControlBarPlayerViewState {
    
    static func initialize(_ persistentState: ControlBarPlayerUIPersistentState?) {
        
        windowFrame = persistentState?.windowFrame
        cornerRadius = persistentState?.cornerRadius ?? defaultCornerRadius
    }
    
    static var persistentState: ControlBarPlayerUIPersistentState {
        
        let state = ControlBarPlayerUIPersistentState()
        
        state.windowFrame = windowFrame
        state.cornerRadius = cornerRadius
        
        return state
    }
}
