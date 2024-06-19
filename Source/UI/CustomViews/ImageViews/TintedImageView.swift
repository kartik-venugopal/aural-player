//
//  TintedImageView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

@IBDesignable
class TintedImageView: NSImageView {
    
    private var kvoToken: NSKeyValueObservation?
    
    override var image: NSImage? {
        
        didSet {
            image?.isTemplate = true
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        image?.isTemplate = true
    }
}

extension NSImageView: ColorSchemePropertyChangeReceiver {
    
    func colorChanged(_ newColor: NSColor) {
        contentTintColor = newColor
    }
}

class AppLogoView: TintedImageView {
    
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}
