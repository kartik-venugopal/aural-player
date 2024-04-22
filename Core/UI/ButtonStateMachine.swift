//
//  ButtonStateMachine.swift
//  Aural-macOS
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class ButtonStateMachine<E>: NSObject, ColorSchemeObserver where E: Hashable {
    
    var state: E
    private let button: NSButton
    private(set) var mappings: [E: StateMapping] = [:]
    
//    var hashValue: Int {
//        button.hashValue
//    }
    
    struct StateMapping {
        
        let state: E
        let image: PlatformImage
        let colorProperty: ColorSchemeProperty
        let toolTip: String?
    }
    
    init(initialState: E, mappings: [StateMapping], button: NSButton) {
        
        self.state = initialState
        self.button = button
        
        for mapping in mappings {
            self.mappings[mapping.state] = mapping
        }
        
        super.init()

        doSetState(initialState)
        colorSchemesManager.registerSchemeObserver(self)
    }
    
    // Switches the button's state to a particular state
    func setState(_ newState: E) {
        
        if self.state != newState {
            doSetState(newState)
        }
    }
    
    private func doSetState(_ newState: E) {
        
        guard let mapping = mappings[newState] else {return}
        
        let oldState = self.state
        self.state = newState
        
        button.image = mapping.image
        button.toolTip = mapping.toolTip
        
        // Register for color scheme property observation for the new color property, if different from the previous one.
        guard let oldColorProp = mappings[oldState]?.colorProperty, oldColorProp != mapping.colorProperty else {return}
        
        // Color scheme property customization possible only in modular or unified app modes.
        if let currentAppMode = appModeManager.currentMode, currentAppMode.equalsOneOf(.modular, .unified) {
            
            colorSchemesManager.removePropertyObserver(self, forProperty: oldColorProp)
            colorSchemesManager.registerPropertyObserver(self, forProperty: mapping.colorProperty, changeReceiver: button)
            
        } else {
            updateButtonColor()
        }
    }
    
    func colorSchemeChanged() {
        updateButtonColor()
    }
    
    private func updateButtonColor() {
        
        if let colorProp = mappings[state]?.colorProperty {
            button.colorChanged(systemColorScheme[keyPath: colorProp])
        }
    }
}
