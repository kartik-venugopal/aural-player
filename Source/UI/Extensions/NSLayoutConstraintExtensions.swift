//
//  NSLayoutConstraintExtensions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSLayoutConstraint {
    
    static func widthConstraint(forItem item: Any, equalTo width: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint(item: item, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width)
    }
    
    static func heightConstraint(forItem item: Any, equalTo height: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
    }
    
    static func trailingLeadingConstraint(forItem item: Any, relatedTo otherItem: Any, offset: CGFloat = 0) -> NSLayoutConstraint {
        NSLayoutConstraint(item: item, attribute: .trailing, relatedBy: .equal, toItem: otherItem, attribute: .leading, multiplier: 1, constant: offset)
    }
    
    static func bottomTopConstraint(forItem item: Any, relatedTo otherItem: Any, offset: CGFloat = 0) -> NSLayoutConstraint {
        NSLayoutConstraint(item: item, attribute: .bottom, relatedBy: .equal, toItem: otherItem, attribute: .top, multiplier: 1, constant: offset)
    }
}
