//
//  ScreenArrangement.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class ScreenArrangement {
    
    let screens: [NSRect]
    
    var numberOfScreens: Int {
        screens.count
    }
    
    init(screens: [NSRect]) {
        self.screens = screens
    }
    
    static var current: ScreenArrangement {
        .init(screens: NSScreen.screens.map {$0.visibleFrame})
    }
}

extension ScreenArrangement: Equatable {
    
    static func == (lhs: ScreenArrangement, rhs: ScreenArrangement) -> Bool {
        
        if lhs.numberOfScreens != rhs.numberOfScreens {
            return false
        }
        
        for (index, screen) in lhs.screens.enumerated() {
            
            let other = rhs.screens[index]
            
            if screen != other {
                return false
            }
        }
        
        return true
    }
}
