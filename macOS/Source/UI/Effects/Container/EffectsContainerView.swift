//
//  EffectsContainerView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

///
/// Mouse tracking view to auto-hide the effects unit presets and settings menu.
///
class EffectsContainerView: MouseTrackingView {
    
    private lazy var messenger: Messenger = .init(for: self)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        startTracking()
    }
    
    override func mouseEntered(with event: NSEvent) {
        messenger.publish(.Effects.showPresetsAndSettingsMenu)
    }
    
    override func mouseExited(with event: NSEvent) {
        messenger.publish(.Effects.hidePresetsAndSettingsMenu)
    }
}
