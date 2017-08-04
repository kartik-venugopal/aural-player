/*
    Handles all key press events for AppDelegate
*/

import Cocoa
import AVFoundation

class KeyPressHandler {
    
    // Key code constants
    static let UP_ARROW: UInt16 = 126
    static let DOWN_ARROW: UInt16 = 125
    static let LETTER_S: UInt16 = 1
    
    // Callback reference to AppDelegate so that its UI controls can be manipulated and its functions called
    static var app: AppDelegate?
    
    // Sets the callback reference to AppDelegate (called only once)
    static func initialize(_ app : AppDelegate) {
        self.app = app
    }
    
    // Handles a single key press event
    static func handle(_ event: NSEvent) {
        
        let app = self.app!
        
        // Modal dialog open, don't do anything
        if (app.modalDialogOpen()) {
            return
        }
        
        // Indicate whether or not Shift/Command were pressed
        let isShift: Bool = event.modifierFlags.contains(NSEventModifierFlags.shift)
        let isCommand: Bool = event.modifierFlags.contains(NSEventModifierFlags.command)
        
        // ---------------------- Handlers --------------------------
        
        // (Up arrow) Change selection (up) in playlist
        if (!isShift && !isCommand && event.keyCode == UP_ARROW) {
            
            let selRow = app.playlistView.selectedRow
            
            if (selRow > 0) {
                app.playlistView.selectRowIndexes(IndexSet(integer: selRow - 1), byExtendingSelection: false)
            }
            
            app.showPlaylistSelectedRow()
        }
        
        // (Down arrow) Change selection (down) in playlist
        if (!isShift && !isCommand && event.keyCode == DOWN_ARROW) {
            
            let selRow = app.playlistView.selectedRow
            
            if (selRow < (app.playlistView.numberOfRows - 1)) {
                app.playlistView.selectRowIndexes(IndexSet(integer: selRow + 1), byExtendingSelection: false)
            }
            
            app.showPlaylistSelectedRow()
        }
        
        // NOTE - This keyboard shortcut is for debugging purposes only, not intended for the end user
        // (Shift + Command + S) Print Timer stats
        if (isShift && isCommand && event.keyCode == LETTER_S) {
            TimerUtils.printStats()
        }
    }
}
