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
        self.state = .off
    }
    
    @objc func on() {
        self.state = .on
    }
    
    @objc func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    @objc var isOn: Bool {
        return self.state == .on
    }
    
    @objc var isOff: Bool {
        return self.state == .off
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
    
    func hideIf(_ condition: Bool) {
        condition ? hide() : show()
    }
    
    func showIf(_ condition: Bool) {
        condition ? show() : hide()
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

