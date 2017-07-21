/*
    Handles all key press events for AppDelegate
*/

import Cocoa
import AVFoundation

class KeyPressHandler {
    
    // Key code constants
    static let UP_ARROW: UInt16 = 126
    static let DOWN_ARROW: UInt16 = 125
    static let FORWARD_ARROW: UInt16 = 124
    static let BACKWARD_ARROW: UInt16 = 123
    static let LETTER_I: UInt16 = 34
    static let LETTER_O: UInt16 = 31
    static let LETTER_R: UInt16 = 15
    static let LETTER_S: UInt16 = 1
    static let SPACE: UInt16 = 49
    static let BACKSPACE: UInt16 = 51
    static let ENTER: UInt16 = 36
    
    // Callback reference to AppDelegate so that its UI controls can be manipulated and its functions called
    static var app: AppDelegate?
    
    // Sets the callback reference to AppDelegate (called only once)
    static func initialize(_ app : AppDelegate) {
        self.app = app
    }
    
    // Handles a single key press event
    static func handle(_ event: NSEvent) {
        
        let app = self.app!
        
        // Ignore key press events when an open/save dialog is open
        // Otherwise, the handlers here will interfere with dialog interaction
        if (app.modalDialogOpen) {
            return
        }
        
        // NOTE This is kind of a hack to temporarily avoid up/down arrow key presses triggering unwanted changes in track selection when modifier keys are used with the up/down arrow
        let resp = app.playlistView.window?.firstResponder
        app.playlistView.window?.makeFirstResponder(nil)
        
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
        
        // (Command + R) Start/stop recording
        if (isCommand && !isShift && event.keyCode == LETTER_R) {
            app.recorderAction(event)
        }
        
        // Part of the hack mentioned above ... restore the responder for the playlist view so that it may continue receiving key press events
        app.playlistView.window?.makeFirstResponder(resp)
    }
}
