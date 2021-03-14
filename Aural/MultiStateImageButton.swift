import Cocoa

/*
    An image button that is capable of switching between any finite number of states, and displays a preset image corresponding to each state (example - repeat/shuffle mode buttons)
 */
class MultiStateImageButton: NSButton {
 
    // 1-1 mappings of a particular state to a particular image. Intended to be set by code using this button.
    var stateImageMappings: [(state: Any, image: NSImage)]! {
        
        didSet {
            // Each state value is converted to a String representation for storing in a lookup map (map keys needs to be Hashable)
            stateImageMappings.forEach({map[String(describing: $0.state)] = $0.image})
        }
    }
    
    // Quick lookup for state -> image mappings
    private var map: [String: NSImage] = [:]
    
    // _state is not to be confused with NSButton.state
    private var _state: Any!
    
    // Switches the button's state to a particular state
    func switchState(_ state: Any) {
        
        _state = state
        
        // Set the button's image based on the new state
        self.image = map[String(describing: state)]
    }
}

class ColorSensitiveMultiStateImageButton: NSButton {
    
    // var stateFunction: (() -> EffectsUnitState)?
    
    // 1-1 mappings of a particular state to a particular image. Intended to be set by code using this button.
    var stateImageMappings: [(state: Any, imageFunction: (() -> NSImage))]! {
        
        didSet {
            // Each state value is converted to a String representation for storing in a lookup map (map keys needs to be Hashable)
            stateImageMappings.forEach({
                map[String(describing: $0.state)] = $0.imageFunction
            })
        }
    }
    
    // Quick lookup for state -> image mappings
    private var map: [String: (() -> NSImage)] = [:]
    
    // _state is not to be confused with NSButton.state
    private var _state: Any!
    
    // Switches the button's state to a particular state
    func switchState(_ state: Any) {
        
        _state = state
        
        // Set the button's image based on the new state
        if let imgFunc = map[String(describing: state)] {
            self.image = imgFunc()
        }
    }
    
    func colorSchemeChanged() {
        
        if let state = _state, let imgFunc = map[String(describing: state)] {
            self.image = imgFunc()
        }
    }
}
