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
    
    static func leadingLeadingConstraint(forItem item: Any, relatedTo otherItem: Any, offset: CGFloat = 0) -> NSLayoutConstraint {
        NSLayoutConstraint(item: item, attribute: .leading, relatedBy: .equal, toItem: otherItem, attribute: .leading, multiplier: 1, constant: offset)
    }
    
    static func leadingTrailingConstraint(forItem item: Any, relatedTo otherItem: Any, offset: CGFloat = 0) -> NSLayoutConstraint {
        NSLayoutConstraint(item: item, attribute: .leading, relatedBy: .equal, toItem: otherItem, attribute: .trailing, multiplier: 1, constant: offset)
    }
    
    static func bottomTopConstraint(forItem item: Any, relatedTo otherItem: Any, offset: CGFloat = 0) -> NSLayoutConstraint {
        NSLayoutConstraint(item: item, attribute: .bottom, relatedBy: .equal, toItem: otherItem, attribute: .top, multiplier: 1, constant: offset)
    }
}

class LayoutConstraintsManager {
    
    let view: NSView
    var superview: NSView? {view.superview}
    
    init(for view: NSView) {
        
        self.view = view
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func removeAll(withAttributes attributes: [NSLayoutConstraint.Attribute]? = nil) {
        view.removeAllConstraintsFromSuperview(attributes: attributes)
    }
    
    func setWidth(_ width: CGFloat) {
        
        let constraint = NSLayoutConstraint.widthConstraint(forItem: view, equalTo: width)
        superview?.activateAndAddConstraint(constraint)
    }
    
    func setHeight(_ height: CGFloat) {
        
        let constraint = NSLayoutConstraint.heightConstraint(forItem: view, equalTo: height)
        superview?.activateAndAddConstraint(constraint)
    }
    
    func setLeading(relatedToTrailingOf otherView: NSView, offset: CGFloat = 0) {
        
        let constraint = NSLayoutConstraint.leadingTrailingConstraint(forItem: view,
                                                                      relatedTo: otherView, offset: offset)
        
        superview?.activateAndAddConstraint(constraint)
    }
    
    func setLeading(relatedToLeadingOf otherView: NSView, offset: CGFloat = 0) {
        
        let constraint = NSLayoutConstraint.leadingLeadingConstraint(forItem: view,
                                                                      relatedTo: otherView, offset: offset)
        
        superview?.activateAndAddConstraint(constraint)
    }
    
    func setTrailing(relatedToLeadingOf otherView: NSView, offset: CGFloat = 0) {
        
        let constraint = NSLayoutConstraint.trailingLeadingConstraint(forItem: view,
                                                                      relatedTo: otherView, offset: offset)
        
        superview?.activateAndAddConstraint(constraint)
    }
    
    func setBottom(relatedToTopOf otherView: NSView, offset: CGFloat = 0) {
        
        let constraint = NSLayoutConstraint.bottomTopConstraint(forItem: view,
                                                                relatedTo: otherView, offset: offset)
        
        superview?.activateAndAddConstraint(constraint)
    }
}
