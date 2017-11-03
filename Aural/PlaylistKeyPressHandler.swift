/*
    Forwards key press events (keyDown) to the Playlist table view. This is required because the app's main window does not have a title bar. Hence, keyDown events are not forwarded to the playlist table view.
*/

import Cocoa

class PlaylistKeyPressHandler {
    
    private let playlistViews: [PlaylistType: NSTableView]
    
    init(_ playlistViews: [PlaylistType: NSTableView]) {
        self.playlistViews = playlistViews
    }
    
    // Handles a single key press event
    func handle(_ event: NSEvent) {
        
        if (NSApp.modalWindow != nil) {
            // Modal dialog open, don't do anything
            return
        }
        
        // Indicate whether or not Shift/Command/Option were pressed
        let isShift: Bool = event.modifierFlags.contains(NSEventModifierFlags.shift)
        let isCommand: Bool = event.modifierFlags.contains(NSEventModifierFlags.command)
        let isOption: Bool = event.modifierFlags.contains(NSEventModifierFlags.option)
        
        let isArrow: Bool = KeyCodeConstants.arrows.contains(event.keyCode)
        
        let chars = event.charactersIgnoringModifiers
        let isAlphaNumeric = chars != nil && chars!.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil
        
        // ---------------------- Handlers --------------------------
        
        // Arrows enable natural playlist scrolling and group expansion/collapsing, and alphanumeric characters enable type selection by track name
        if (!isShift && !isCommand && !isOption && (isArrow || isAlphaNumeric)) {
            
            // Forward the event to the playlist view
            playlistViews[PlaylistViewState.current]!.keyDown(with: event)
            return
        }
        
        // NOTE - This keyboard shortcut is for debugging purposes only, not inteded for the end user
        // (Shift + Command + S) Print Timer stats
        if (isShift && isCommand && (chars != nil && chars! == "S")) {
            TimerUtils.printStats()
            return
        }
    }
}

fileprivate class KeyCodeConstants {

    // TODO: Are these system-independent ???
    static let UP_ARROW: UInt16 = 126
    static let DOWN_ARROW: UInt16 = 125
    
    static let LEFT_ARROW: UInt16 = 123
    static let RIGHT_ARROW: UInt16 = 124
    
    static let arrows = [KeyCodeConstants.UP_ARROW, KeyCodeConstants.DOWN_ARROW, KeyCodeConstants.LEFT_ARROW, KeyCodeConstants.RIGHT_ARROW]
}
