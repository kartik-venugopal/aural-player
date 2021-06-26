//
//  TintedImageView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

@IBDesignable
class TintedImageView: NSImageView, Tintable {
    
    @IBInspectable var baseImage: NSImage? {
        didSet {reTint()}
    }
    
    var tintFunction: () -> NSColor = {Colors.functionButtonColor} {
        didSet {reTint()}
    }
    
    func reTint() {
        self.image = self.baseImage?.filledWithColor(tintFunction())
    }
}
