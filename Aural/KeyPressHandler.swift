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
    static let LETTER_S: UInt16 = 1
    static let SPACE: UInt16 = 49
    static let BACKSPACE: UInt16 = 51
    static let ENTER: UInt16 = 36
    
    // Callback reference to AppDelegate so that its UI controls can be manipulated and its functions called
    static var app: AppDelegate?
    
    // Sets the callback reference to AppDelegate (called only once)
    static func initialize(app : AppDelegate) {
        self.app = app
    }
    
    // Handles a single key press event
    static func handle(event: NSEvent) {
        
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
        let isShift: Bool = event.modifierFlags.contains(NSEventModifierFlags.ShiftKeyMask)
        let isCommand: Bool = event.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask)
        
        // ---------------------- Handlers --------------------------
        
        // (Shift + Up arrow) Shift selected track up in playlist
        if (isShift && event.keyCode == UP_ARROW) {
            app.moveTrackUpAction(event)
        }
        
        // (Shift + Down arrow) Shift selected track down in playlist
        if (isShift && event.keyCode == DOWN_ARROW) {
            app.moveTrackDownAction(event)
        }
        
        // (Up arrow) Change selection (up) in playlist
        if (!isShift && !isCommand && event.keyCode == UP_ARROW) {
            
            let selRow = app.playlistView.selectedRow
            
            if (selRow > 0) {
                app.playlistView.selectRowIndexes(NSIndexSet(index: selRow - 1), byExtendingSelection: false)
            }
            
            app.showPlaylistSelectedRow()
        }
        
        // (Down arrow) Change selection (down) in playlist
        if (!isShift && !isCommand && event.keyCode == DOWN_ARROW) {
            
            let selRow = app.playlistView.selectedRow
            
            if (selRow < (app.playlistView.numberOfRows - 1)) {
                app.playlistView.selectRowIndexes(NSIndexSet(index: selRow + 1), byExtendingSelection: false)
            }
            
            app.showPlaylistSelectedRow()
        }
        
        // (Command + O) Open modal dialog to allow user to add files to playlist
        if (isCommand && event.keyCode == LETTER_O) {
            app.addTracksAction(event)
        }
        
        // (Command + I) Get more detailed track information
        if (isCommand && event.keyCode == LETTER_I) {
            app.moreInfoAction(event)
        }
        
        // (Command + S) Open modal dialog to allow user to save current playlist to a file
        if (isCommand && event.keyCode == LETTER_S) {
            app.savePlaylistAction(event)
        }
        
        // (Command + Up arrow) Volume increase
        if (isCommand && event.keyCode == UP_ARROW) {
            app.increaseVolume()
        }
        
        // (Command + Down arrow) Volume decrease
        if (isCommand && event.keyCode == DOWN_ARROW) {
            app.decreaseVolume()
        }
        
        // (Backward/Left arrow - <) Seek track backward
        if (!isCommand && !isShift && event.keyCode == BACKWARD_ARROW) {
            app.seekBackwardAction(event)
        }
        
        // (Command + Backward/Left arrow) Play previous track
        if (isCommand && event.keyCode == BACKWARD_ARROW) {
            app.prevTrackAction(event)
        }
        
        // (Shift + Backward/Left arrow) Pan left a little bit (L/R balance)
        if (isShift && event.keyCode == BACKWARD_ARROW) {
            app.panLeft()
        }
        
        // (Backward/Left arrow) Seek track forward
        if (!isCommand && !isShift && event.keyCode == FORWARD_ARROW) {
            app.seekForwardAction(event)
        }
        
        // (Command + Forward/Right arrow) Play next track
        if (isCommand && event.keyCode == FORWARD_ARROW) {
            app.nextTrackAction(event)
        }
        
        // (Shift + Forward/Right arrow) Pan right a little bit (L/R balance)
        if (isShift && event.keyCode == FORWARD_ARROW) {
            app.panRight()
        }
        
        // (Space) Toggle play/pause
        if (!isCommand && !isShift && event.keyCode == SPACE) {
            app.playPauseAction(event)
        }
        
        // (Backspace) Delete a single (selected) file from playlist
        if (!isCommand && !isShift && event.keyCode == BACKSPACE) {
            app.removeSingleTrackAction(event)            
        }
        
        // (Enter) Play selected track (same as mouse double click)
        if (!isCommand && !isShift && event.keyCode == ENTER) {
            app.playSelectedTrack()
        }
        
        // Part of the hack mentioned above ... restore the responder for the playlist view so that it may continue receiving key press events
        app.playlistView.window?.makeFirstResponder(resp)
    }
}