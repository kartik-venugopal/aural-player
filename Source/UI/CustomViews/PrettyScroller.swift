//
//  PrettyScroller.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PrettyScroller: NSScroller {
    
    let barRadius: CGFloat = 0.75
    let barInsetX: CGFloat = 7
    let barInsetY: CGFloat = 0
    
    let knobInsetX: CGFloat = 5
    let knobInsetY: CGFloat = 0
    let knobRadius: CGFloat = 1

    var knobColor: NSColor = NSColor.gray
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var contentView: NSView!
    
    var scrollerKnobColor: NSColor {
        systemColorScheme.inactiveControlColor
    }
    
    var scrollerBarColor: NSColor {
        systemColorScheme.inactiveControlColor
    }
    
    override func awakeFromNib() {
        
        self.scrollerStyle = .overlay
        registerColorSchemeObserver()
    }
    
    override func drawKnob() {
        
        if contentView != nil, scrollView != nil, (contentView.height + (clipView?.contentInsets.top ?? 0) + (clipView?.contentInsets.bottom ?? 0)) <= scrollView.height {
            return
        }
        
        let knobRect = self.rect(for: .knob).insetBy(dx: knobInsetX, dy: knobInsetY)
        if knobRect.height <= 0 || knobRect.width <= 0 {return}
        
        NSBezierPath.fillRoundedRect(knobRect, radius: knobRadius, withColor: scrollerKnobColor)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        let rect = dirtyRect.insetBy(dx: barInsetX, dy: barInsetY)
        NSBezierPath.fillRoundedRect(rect, radius: barRadius, withColor: scrollerBarColor)
        
        self.drawKnob()
    }
}

extension PrettyScroller: ColorSchemeObserver {
    
    @objc func registerColorSchemeObserver() {
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.inactiveControlColor, changeReceiver: self)
    }
    
    func colorSchemeChanged() {
        redraw()
    }
}

extension PrettyScroller: ColorSchemePropertyChangeReceiver {
    
    func colorChanged(_ newColor: NSColor) {
        redraw()
    }
}

class SimplePrettyScroller: PrettyScroller {
    
    override var scrollerKnobColor: NSColor {
        .white40Percent
    }
    
    override var scrollerBarColor: NSColor {
        .white25Percent
    }
    
    override func registerColorSchemeObserver() {}
}
