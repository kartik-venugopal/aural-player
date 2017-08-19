import Cocoa

/*
    Container for definitions of reusable UI components
*/
class UIElements {
    
    // TODO: Make these lazy vars to reduce memory footprint ???
    
    // Used to add tracks/playlists
    static let openDialog: NSOpenPanel = UIElements.createOpenPanel()
    
    // Used to save current playlist to a file
    static let savePlaylistDialog: NSSavePanel = UIElements.createSavePanel()
    
    // Used to save a recording to a file
    static let saveRecordingDialog: NSSavePanel = UIElements.createSaveRecordingPanel()
    
    // Used to prompt the user, when exiting the app, that a recording is ongoing, and give the user options to save/discard that recording
    static let saveRecordingAlert: NSAlert = UIElements.createSaveRecordingAlert()
    
    // Used to inform the user that a certain track cannot be played back
    static let trackNotPlayedAlert: NSAlert = UIElements.createTrackNotPlayedAlert()
    
    // Used to warn the user that certain files were not added to the playlist
    static let tracksNotAddedAlert: NSAlert = UIElements.createTracksNotAddedAlert()
    
    fileprivate static func createOpenPanel() -> NSOpenPanel {
        
        let dialog = NSOpenPanel()
        
        dialog.title                   = "Choose media (.mp3/.m4a/.aac/.aif/.wav), playlists (.m3u/.m3u8), or directories";
        
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = true;
        
        dialog.canChooseDirectories    = true;
        
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = true;
        dialog.allowedFileTypes        = AppConstants.supportedFileTypes_open
        
        dialog.resolvesAliases = true;
        
        dialog.directoryURL = AppConstants.musicDirURL
        
        return dialog
    }
    
    fileprivate static func createSavePanel() -> NSSavePanel {
        
        let dialog = NSSavePanel()
        
        dialog.title                   = "Save current playlist as a (.m3u) file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = true
        
        dialog.canCreateDirectories    = true
        dialog.allowedFileTypes        = AppConstants.supportedFileTypes_save
        
        dialog.directoryURL = AppConstants.musicDirURL
        
        return dialog
    }
    
    fileprivate static func createSaveRecordingPanel() -> NSSavePanel {
        
        let dialog = NSSavePanel()
        
        dialog.title                   = "Save recording as a (.aac) file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        
        dialog.canCreateDirectories    = true
        dialog.allowedFileTypes        = [RecordingFormat.aac.fileExtension]
        
        dialog.directoryURL = AppConstants.musicDirURL
        
        return dialog
    }
    
    private static func createSaveRecordingAlert() -> NSAlert {
        
        let alert = NSAlert()
        
        alert.window.title = "Save/discard ongoing recording"
        
        alert.messageText = "You have an ongoing recording. Would you like to save it before exiting the app ?"
        alert.alertStyle = .warning
        alert.icon = UIConstants.imgWarning
        
        alert.addButton(withTitle: "Save recording and exit")
        alert.addButton(withTitle: "Discard recording and exit")
        alert.addButton(withTitle: "Don't exit")
        
        return alert
    }
    
    private static func createTrackNotPlayedAlert() -> NSAlert {
        
        let alert = NSAlert()
        
        alert.window.title = "Track not playable"
        
        alert.alertStyle = .warning
        alert.icon = UIConstants.imgError

        alert.addButton(withTitle: "Remove track from playlist")
        
        return alert
    }
    
    static func trackNotPlayedAlertWithError(_ error: InvalidTrackError) -> NSAlert {
        
        let alert = trackNotPlayedAlert
        
        alert.messageText = String(format: "The track '%@' cannot be played back !", error.file.lastPathComponent)
        alert.informativeText = error.message
        
        return alert
    }
    
    private static func createTracksNotAddedAlert() -> NSAlert {
        
        let alert = NSAlert()
        
        alert.window.title = "Files not added"
        alert.messageText = "Some files were not added to the playlist. Details below."
        
        alert.alertStyle = .warning
        alert.icon = UIConstants.imgWarning
        
        alert.addButton(withTitle: "Ok")
        
        return alert
    }
    
    static func tracksNotAddedAlertWithErrors(_ errors: [InvalidTrackError]) -> NSAlert {
        
        let alert = tracksNotAddedAlert
        
        // Display a maximum of 3 entries and a summary of the rest
        
        var infoText: String = ""
        
        let numErrors = errors.count
        for i in 0...min(numErrors - 1, 2) {
            
            let error = errors[i]
            let file = error.file
            let msg = error.message
            
            infoText.append(String(format: "'%@': %@\n\n", file.path, msg))
        }
        
        if (numErrors > 3) {
            let moreErrors = numErrors - 3
            infoText.append(String(format: "... and %d more %@", moreErrors, moreErrors > 1 ? "files" : "file"))
        }
        
        alert.informativeText = infoText
        
        // TODO: Resize alert per number of lines displayed
        
        return alert
    }
}

// Enumeration of all possible responses in the save/discard ongoing recording alert (possibly) displayed when exiting the app
enum RecordingAlertResponse: Int {
    
    case saveAndExit = 1000
    case discardAndExit = 1001
    case dontExit = 1002
}
