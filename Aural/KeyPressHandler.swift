/*
    Handles all key press events
*/

import Cocoa
import AVFoundation

class KeyPressHandler {
    
    // Key code constants
    static let UP_ARROW: UInt16 = 126
    static let DOWN_ARROW: UInt16 = 125
    static let LETTER_S: UInt16 = 1
    
    // Handles a single key press event
    static func handle(_ event: NSEvent) {
        
        let modalDialogOpen = NSApp.modalWindow != nil
        if (modalDialogOpen) {
            // Modal dialog open, don't do anything
            return
        }
        
        // Indicate whether or not Shift/Command were pressed
        let isShift: Bool = event.modifierFlags.contains(NSEventModifierFlags.shift)
        let isCommand: Bool = event.modifierFlags.contains(NSEventModifierFlags.command)
        
        // ---------------------- Handlers --------------------------
        
        // (Up arrow) Scroll up one row in playlist
        if (!isShift && !isCommand && event.keyCode == UP_ARROW) {
            SyncMessenger.publishNotification(PlaylistScrollUpNotification.instance)
            return
        }
        
        // (Down arrow) Scroll down one row in playlist
        if (!isShift && !isCommand && event.keyCode == DOWN_ARROW) {
            SyncMessenger.publishNotification(PlaylistScrollDownNotification.instance)
            return
        }
        
        // NOTE - This keyboard shortcut is for debugging purposes only, not inteded for the end user
        // (Shift + Command + S) Print Timer stats
        if (isShift && isCommand && event.keyCode == LETTER_S) {
            TimerUtils.printStats()
            return
        }
    }
}
