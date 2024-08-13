//
//  NSMenuItemExtensions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSMenu {
    
    func addItem(withTitle title: String, action: Selector? = nil) {
        addItem(withTitle: title, action: action, keyEquivalent: "")
    }
    
    func recreateMenu(insertingItemsAt index: Int, withTitles titles: [String],
                      action: Selector? = nil, target: AnyObject? = nil,
                      indentationLevel: Int? = nil) {
        
        // Remove all user-defined preset items (i.e. all items before the first separator)
        while index < items.count, let item = item(at: index), !item.isSeparatorItem {
            removeItem(at: index)
        }
        
        // Recreate the user-defined color scheme items
        titles.forEach {
            
            let item: NSMenuItem = NSMenuItem(title: $0, action: action, keyEquivalent: "")
            item.target = target
            
            if let level = indentationLevel {
                item.indentationLevel = level
            }

            if items.isNonEmpty {
                insertItem(item, at: index)
            } else {
                addItem(item)
            }
        }
    }
    
    func recreateMenu<T: MenuItemMappable>(insertingItemsAt index: Int, fromItems mappableItems: [T],
                                             action: Selector? = nil, target: AnyObject? = nil,
                                             indentationLevel: Int? = nil) {
        
        guard mappableItems.isNonEmpty else {return}
        
        recreateMenu(insertingItemsAt: index, withTitles: mappableItems.map {$0.name},
                     action: action, target: target, indentationLevel: indentationLevel)
    }
    
    func importItems(from otherMenu: NSMenu) {
        
        let items = otherMenu.items
        
        for item in items {
            otherMenu.removeItem(item)
        }
        
        self.items = items
        self.delegate = otherMenu.delegate
    }
}

extension NSPopUpButton {
    
    func recreateMenu<T: MenuItemMappable>(insertingItemsAt index: Int, fromItems mappableItems: [T],
                                             indentationLevel: Int? = nil) {
        
        menu?.recreateMenu(insertingItemsAt: index, fromItems: mappableItems,
                           action: action, target: target,
                           indentationLevel: indentationLevel)
    }
    
    func deselect() {
        selectItem(at: -1)
    }
}

extension NSPopUpButton: ColorSchemePropertyChangeReceiver {
    
    override func colorChanged(_ newColor: NSColor) {
        contentTintColor = newColor
    }
}

extension NSMenuItem {
    
    convenience init(title: String) {
        self.init(title: title, action: nil, keyEquivalent: "")
    }
    
    convenience init(title: String, action: Selector) {
        self.init(title: title, action: action, keyEquivalent: "")
    }
    
    convenience init(view: NSView) {
        
        self.init(title: "", action: nil, keyEquivalent: "")
        self.view = view
    }
    
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
    
    func toggleShownOrHidden() {
        self.isHidden.toggle()
    }
    
    // Creates a menu item that serves only to describe other items in the menu. The item will have no action.
    static func createDescriptor(title: String) -> NSMenuItem {
        
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.disable()  // Descriptor items cannot be clicked
        return item
    }
}

extension NSPopUpButtonCell {

    @objc func redraw() {
        controlView?.redraw()
    }
}
