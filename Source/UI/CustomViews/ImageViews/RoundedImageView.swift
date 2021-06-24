//
//  RoundedImageView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
        didSet {self.layer?.cornerRadius = roundingRadius}
    }
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect)
        
        self.wantsLayer = true
        self.layer?.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        self.wantsLayer = true
        self.layer?.masksToBounds = true
    }
    
    override func awakeFromNib() {
        self.layer?.cornerRadius = roundingRadius
    }
}
