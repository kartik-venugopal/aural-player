//
// ReplayGainUnitViewController+Theming.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

extension ReplayGainUnitViewController {
    
    override func fontSchemeChanged() {
        
        super.fontSchemeChanged()
        replayGainUnitView.fontSchemeChanged()
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        
        replayGainUnitView.colorSchemeChanged(unitState: replayGainUnit.state,
                                              unitStateColor: systemColorScheme.colorForEffectsUnitState(replayGainUnit.state))
    }
    
    override func activeControlColorChanged(_ newColor: NSColor) {
        
        super.activeControlColorChanged(newColor)
        
        if replayGainUnit.state == .active {
            replayGainUnitView.activeControlColorChanged(systemColorScheme.colorForEffectsUnitState(.active))
        }
    }
    
    override func inactiveControlColorChanged(_ newColor: NSColor) {
        
        super.inactiveControlColorChanged(newColor)
        
        if replayGainUnit.state == .bypassed {
            replayGainUnitView.activeControlColorChanged(systemColorScheme.colorForEffectsUnitState(.bypassed))
        }
    }
    
    override func suppressedControlColorChanged(_ newColor: NSColor) {
        
        super.suppressedControlColorChanged(newColor)
        
        if replayGainUnit.state == .suppressed {
            replayGainUnitView.activeControlColorChanged(systemColorScheme.colorForEffectsUnitState(.suppressed))
        }
    }
}
