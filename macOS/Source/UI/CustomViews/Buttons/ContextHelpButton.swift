//
//  ContextHelpButton.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

@IBDesignable
class ContextHelpButton: NSButton {
    
    private static let helpTextFontAttributes: [NSAttributedString.Key: Any] = [.font: NSFont.helpInfoTextFont]
    
    @IBInspectable var helpText: String! {
        
        didSet {
            
            NSHelpManager.shared.setContextHelp(NSAttributedString(string: helpText,
                                                                   attributes: Self.helpTextFontAttributes), for: self)
        }
    }
}
