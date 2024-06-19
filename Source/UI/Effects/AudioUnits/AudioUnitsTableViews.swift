//
//  AudioUnitsTableViews.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

/*
    Custom view for a NSTableView row that displays a single Audio Unit. Customizes the selection look and feel.
 */
class AudioUnitsTableRowView: NSTableRowView {
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if self.selectionHighlightStyle != .none {
            
            let selectionRect = bounds.insetBy(dx: 30, dy: 0).offsetBy(dx: -5, dy: 0)
            NSBezierPath.fillRoundedRect(selectionRect, radius: 2, withColor: systemColorScheme.textSelectionColor)
        }
    }
}

class AudioUnitNameCellView: NSTableCellView {
    
    var rowSelectionStateFunction: () -> Bool = {false}
    
    var unselectedTextColor: NSColor {systemColorScheme.primaryTextColor}
    var selectedTextColor: NSColor {systemColorScheme.primarySelectedTextColor}
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    private lazy var textFieldConstraintsManager = LayoutConstraintsManager(for: textField!)
    
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            backgroundStyleChanged()
        }
    }
    
    func backgroundStyleChanged() {
        
        // Check if this row is selected, change color accordingly.
        textColor = rowIsSelected ?  selectedTextColor : unselectedTextColor
    }
    
    // Constraints
    func realignText(yOffset: CGFloat) {
        
        textFieldConstraintsManager.removeAll(withAttributes: [.bottom])
        textFieldConstraintsManager.setBottom(relatedToBottomOf: self, offset: yOffset)
    }
}

@IBDesignable
class AudioUnitSwitchCellView: NSTableCellView {
    
    @IBOutlet weak var btnSwitch: EffectsUnitTriStateBypassButton!
    
    var action: (() -> Void)! {
        
        didSet {
            
            btnSwitch.action = #selector(self.toggleAudioUnitStateAction(_:))
            btnSwitch.target = self
        }
    }
    
    @objc func toggleAudioUnitStateAction(_ sender: Any) {
        self.action?()
    }
}

@IBDesignable
class AudioUnitEditCellView: NSTableCellView {
    
    @IBOutlet weak var btnEdit: TintedImageButton! {
        
        didSet {
//            colorSchemesManager.registerObserver(btnEdit, forProperty: \.buttonColor)
        }
    }
    
    var action: (() -> Void)! {
        
        didSet {
            
            btnEdit.action = #selector(self.editAudioUnitAction(_:))
            btnEdit.target = self
        }
    }
    
    @objc func editAudioUnitAction(_ sender: Any) {
        self.action()
    }
}
