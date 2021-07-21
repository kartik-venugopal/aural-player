//
//  PreferencesPopupMenuCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

// Cell for all preferences popup menus
class PreferencesPopupMenuCell: PopupMenuCell {
    
    override var cellInsetY: CGFloat {5}
    override var rectRadius: CGFloat {2}
    override var arrowXMargin: CGFloat {10}
    override var arrowYMargin: CGFloat {6}
    override var arrowHeight: CGFloat {4}
    override var arrowColor: NSColor {.lightPopupMenuArrowColor}
    
    override var menuGradient: NSGradient {.popupMenuGradient}
}
