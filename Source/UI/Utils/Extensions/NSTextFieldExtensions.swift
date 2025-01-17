//
//  NSTextFieldExtensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension NSTextField {
    
    var isTruncatingText: Bool {
        cell?.expansionFrame(withFrame: frame, in: self) != .zero
    }
}
