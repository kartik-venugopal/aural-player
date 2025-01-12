//
// PrettyHorizontalScroller.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class PrettyHorizontalScroller: NSScroller {
    
    let barRadius: CGFloat = 0.75
    let barInsetX: CGFloat = 0
    let barInsetY: CGFloat = 7
    
    let knobInsetX: CGFloat = 0
    let knobInsetY: CGFloat = 5
    let knobRadius: CGFloat = 1

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var contentView: NSView!
    
    var knobColor: NSColor {
        systemColorScheme.inactiveControlColor
    }
    
    var barColor: NSColor {
        systemColorScheme.inactiveControlColor
    }
    
    override func awakeFromNib() {
        
        self.scrollerStyle = .overlay
        registerColorSchemeObserver()
    }
    
    private var noNeedToDraw: Bool {
        
        contentView != nil &&
        scrollView != nil &&
        (contentView.width + (clipView?.contentInsets.right ?? 0) + (clipView?.contentInsets.left ?? 0)) <= scrollView.width
    }
    
    override func drawKnob() {
        
        if noNeedToDraw {return}
        
        let knobRect = self.rect(for: .knob).insetBy(dx: knobInsetX, dy: knobInsetY)
        if knobRect.height <= 0 || knobRect.width <= 0 {return}
        
        NSBezierPath.fillRoundedRect(knobRect, radius: knobRadius, withColor: knobColor)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        if noNeedToDraw {return}
        
        let rect = dirtyRect.insetBy(dx: barInsetX, dy: barInsetY)
        NSBezierPath.fillRoundedRect(rect, radius: barRadius, withColor: barColor)
        
        self.drawKnob()
    }
}

extension PrettyHorizontalScroller: ColorSchemeObserver {
    
    @objc func registerColorSchemeObserver() {
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.inactiveControlColor, changeReceiver: self)
    }
    
    func colorSchemeChanged() {
        redraw()
    }
}

extension PrettyHorizontalScroller: ColorSchemePropertyChangeReceiver {
    
    func colorChanged(_ newColor: NSColor) {
        redraw()
    }
}
