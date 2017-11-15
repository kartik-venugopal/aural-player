import Cocoa

/*
    An image button that can be toggled On/Off and displays different images depending on its state
 */
class OnOffImageButton: NSButton {
    
    // The image displayed when the button is in an "Off" state
    var offStateImage: NSImage?
    
    // The image displayed when the button is in an "On" state
    var onStateImage: NSImage?
    
    private var _isOn: Bool = false
    
    // Sets the button state to be "Off"
    func off() {
        self.image = offStateImage
        _isOn = false
    }
    
    // Sets the button state to be "On"
    func on() {
        self.image = onStateImage
        _isOn = true
    }
    
    // Toggles the On/Off state
    func toggle() {
        _isOn ? off() : on()
    }
    
    // Returns true if the button is in the On state, false otherwise.
    func isOn() -> Bool {
        return _isOn
    }
}

/*
    A special case On/Off image button used as a bypass switch for Effects units, with preset images
 */
class EffectsUnitBypassButton: OnOffImageButton {
    
    override var offStateImage: NSImage? {
        
        get {
            return Images.imgSwitchOff
        }
        
        // Image should never change, so don't allow a setter
        set {}
    }
    
    override var onStateImage: NSImage? {
        
        get {
            return Images.imgSwitchOn
        }
        
        // Image should never change, so don't allow a setter
        set {}
    }
    
    // Bypass is the inverse of "On". If bypass is true, state is "Off".
    func setBypassState(_ bypass: Bool) {
        bypass ? off() : on()
    }
}

/*
    An on/off image button that also displays text that can be highlighted
 
    NOTE - This button class is intended to be used in collaboration with OnOffImageAndTextButtonCell for the button cell
 */
class OnOffImageAndTextButton: OnOffImageButton {
    
    func setHighlightColor(_ color: NSColor) {
        
        // Set highlight color and redraw the button, if cell is a OnOffImageAndTextButtonCell
        if let onOffCell = self.cell as? OnOffImageAndTextButtonCell {
            
            onOffCell.highlightColor = color
            self.setNeedsDisplay()
        }
    }
    
    override func off() {
        
        super.off()
        
        // Set the highlight state of the cell, if it is a OnOffImageAndTextButtonCell
        if let onOffCell = self.cell as? OnOffImageAndTextButtonCell {
            onOffCell.shouldHighlight = false
        }
    }
    
    override func on() {
        
        super.on()
        
        // Set the highlight state of the cell, if it is a OnOffImageAndTextButtonCell
        if let onOffCell = self.cell as? OnOffImageAndTextButtonCell {
            onOffCell.shouldHighlight = true
        }
    }
}
