//
//  TintedImageButton.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A special image button to which a tint can be applied, to conform to the current system color scheme.
 */
@IBDesignable
class TintedImageButton: NSButton {
    
    var weight: NSFont.Weight = .heavy {
        
        didSet {
            image = image?.withSymbolConfiguration(.init(pointSize: 12, weight: weight))
        }
    }
    
    override var image: NSImage? {
        
        didSet {
            image?.isTemplate = true
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        image?.isTemplate = true
    }
    
    override func colorChanged(_ newColor: NSColor) {
        contentTintColor = newColor
    }
}

@IBDesignable
class FillableImageButton: NSButton {
    
    override var contentTintColor: NSColor? {
        
        didSet {
            
            if !isReTinting {
                reTint()
            }
        }
    }
    
    override var image: NSImage? {
        
        didSet {
            
            if !isReTinting {
                reTint()
            }
        }
    }
    
    private var isReTinting: Bool = false
    
    private func reTint() {
        
        if let contentTintColor = self.contentTintColor {
            
            isReTinting = true
            
            self.image = image?.filledWithColor(contentTintColor)
            image?.isTemplate = false
            
            isReTinting = false
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        reTint()
    }
    
    func fill(image: NSImage, withColor tintColor: NSColor) {
        
        isReTinting = true
        
        self.contentTintColor = tintColor
        self.image = image.filledWithColor(tintColor)
        
        isReTinting = false
    }
    
    override func colorChanged(_ newColor: NSColor) {
        self.contentTintColor = newColor
    }
}

extension NSButton: ColorSchemePropertyChangeReceiver {
    
    @objc func colorChanged(_ newColor: NSColor) {
        redraw()
    }
}
