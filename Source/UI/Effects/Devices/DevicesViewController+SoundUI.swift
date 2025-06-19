//
// DevicesViewController+SoundUI.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension DevicesViewController: SoundUI {
    
    var id: String {
        className
    }
    
    func panChanged(newPan: Float, displayedPan: String) {
        
        panSlider.floatValue = newPan
        lblPan.stringValue = displayedPan
    }
}
