//
//  MultiStateImageButton.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    An image button that is capable of switching between any finite number of states, and displays a preset image corresponding to each state (example - repeat/shuffle mode buttons)
 */
class MultiStateImageButton: NSButton, Tintable {
 
    // 1-1 mappings of a particular state to a particular image. Intended to be set by code using this button.
    var stateImageMappings: [(state: Any, imageAndTintFunction: (image: NSImage, tintFunction: TintFunction))]! {
        
        didSet {
            // Each state value is converted to a String representation for storing in a lookup map (map keys needs to be Hashable)
            stateImageMappings.forEach({map[String(describing: $0.state)] = $0.imageAndTintFunction})
        }
    }
    
    // Quick lookup for state -> image mappings
    private var map: [String: (image: NSImage, tintFunction: () -> NSColor)] = [:]
    
    // _state is not to be confused with NSButton.state
    private var _state: Any!
    
    // Switches the button's state to a particular state
    func switchState(_ newState: Any) {
        
        _state = newState
        
        // Set the button's image based on the new state
        if let imageAndTintFunction = map[String(describing: newState)] {
            self.image = imageAndTintFunction.image.filledWithColor(imageAndTintFunction.tintFunction())
        }
    }
    
    func reTint() {

        // NOTE - It is important to use a non-optional value for the map lookup, otherwise the string description won't match the targeted key.
        if let theState = self._state, let imageAndTintFunction = map[String(describing: theState)] {
            self.image = imageAndTintFunction.image.filledWithColor(imageAndTintFunction.tintFunction())
        }
    }
}
