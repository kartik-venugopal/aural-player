//
// NSProgressIndicatorExtensions.swift
// Aural
// 
// Copyright © 2024 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

extension NSProgressIndicator {
    
    func animate() {
        
        startAnimation(nil)
        show()
    }
    
    func dismiss() {
        
        hide()
        stopAnimation(nil)
    }
}
