//
//  NSMenuItemExtensions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSMenuItem {
    
    @objc func off() {
        self.state = .offState
    }
    
    @objc func on() {
        self.state = .onState
    }
    
    @objc func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    @objc var isOn: Bool {
        return self.state == .onState
    }
    
    @objc var isOff: Bool {
        return self.state == .offState
    }
    
    @objc func toggle() {
        isOn ? off() : on()
    }
    
    var isShown: Bool {
        return !isHidden
    }
    
    func hide() {
        self.isHidden = true
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hideIf_elseShow(_ condition: Bool) {
        self.isHidden = condition
    }
    
    func showIf_elseHide(_ condition: Bool) {
        self.isHidden = !condition
    }
    
    var isDisabled: Bool {
        return !isEnabled
    }
    
    func enable() {
        self.enableIf(true)
    }
    
    func disable() {
        self.enableIf(false)
    }
    
    func enableIf(_ condition: Bool) {
        self.isEnabled = condition
    }
    
    func disableIf(_ condition: Bool) {
        self.isEnabled = !condition
    }
    
    // Creates a menu item that serves only to describe other items in the menu. The item will have no action.
    static func createDescriptor(title: String) -> NSMenuItem {
        
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.disable()  // Descriptor items cannot be clicked
        return item
    }
}

