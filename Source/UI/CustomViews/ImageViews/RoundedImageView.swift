//
//  RoundedImageView.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// A custom NSImageView that allows for rounded corners.
///
@IBDesignable
class RoundedImageView: NSImageView {
    
    ///
    /// The corner rounding radius of the image view. Can be edited in Interface Builder.
    ///
    @IBInspectable var roundingRadius: CGFloat = 2 {
        didSet {layer?.cornerRadius = roundingRadius}
    }
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect)
        
        wantsLayer = true
        layer?.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        wantsLayer = true
        layer?.masksToBounds = true
    }
    
    override func awakeFromNib() {
        layer?.cornerRadius = roundingRadius
    }
}
