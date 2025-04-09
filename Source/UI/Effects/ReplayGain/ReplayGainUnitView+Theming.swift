//
// ReplayGainUnitView+Theming.swift
// Aural
//
// Copyright © 2025 Kartik Venugopal. All rights reserved.
//
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

extension ReplayGainUnitView {
    
    func fontSchemeChanged() {
        modeMenuButton.redraw()
    }
    
    func colorSchemeChanged(unitState: EffectsUnitState, unitStateColor: NSColor) {
        
        btnPreventClipping.redraw(forState: unitState)
        modeMenuButtonCell.tintColor = unitStateColor
    }
    
    func activeControlColorChanged(_ newColor: NSColor) {
        
        btnPreventClipping.redraw(withTintColor: newColor)
        modeMenuButtonCell.tintColor = newColor
    }
    
    func inactiveControlColorChanged(_ newColor: NSColor) {
        
        btnPreventClipping.redraw(withTintColor: newColor)
        modeMenuButtonCell.tintColor = newColor
    }
    
    func suppressedControlColorChanged(_ newColor: NSColor) {
        
        btnPreventClipping.redraw(withTintColor: newColor)
        modeMenuButtonCell.tintColor = newColor
    }
}
