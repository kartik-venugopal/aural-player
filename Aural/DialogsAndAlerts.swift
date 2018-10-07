import Cocoa

/*
    Container for definitions of reusable UI dialogs and alerts
*/
struct DialogsAndAlerts {
    
    // Used to add tracks/playlists
    static let openDialog: NSOpenPanel = DialogsAndAlerts.createOpenDialog()
    
    // Used to load a single playlist file (on startup)
    static let openPlaylistDialog: NSOpenPanel = DialogsAndAlerts.createOpenPlaylistDialog()
    
    // Used to load a single playlist file (on startup)
    static let openFolderDialog: NSOpenPanel = DialogsAndAlerts.createOpenFolderDialog()
    
    // Used to save current playlist to a file
    static let savePlaylistDialog: NSSavePanel = DialogsAndAlerts.createSavePlaylistDialog()
    
    // Used to save a recording to a file
    private static let saveRecordingDialog: NSSavePanel = DialogsAndAlerts.createSaveRecordingDialog()
    
    // Used to prompt the user, when exiting the app, that a recording is ongoing, and give the user options to save/discard that recording
    static let saveRecordingAlert: NSAlert = DialogsAndAlerts.createSaveRecordingAlert()
    
    // Used to inform the user that a certain track cannot be played back
    private static let trackNotPlayedAlert: NSAlert = DialogsAndAlerts.createTrackNotPlayedAlert()
    
    // Used to warn the user that certain files were not added to the playlist
    private static let tracksNotAddedAlert: NSAlert = DialogsAndAlerts.createTracksNotAddedAlert()
    
    private static func createOpenDialog() -> NSOpenPanel {
        
        let dialog = NSOpenPanel()
        
        dialog.message = String(format: "Choose media, playlists (.%@/.%@), or directories", AppConstants.m3u, AppConstants.m3u8)
        
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = true
        
        dialog.canChooseDirectories    = true
        
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = true
        dialog.allowedFileTypes        = AppConstants.supportedFileTypes_open
        
        dialog.resolvesAliases = true;
        
        dialog.directoryURL = AppConstants.musicDirURL
        
        return dialog
    }
    
    private static func createSavePlaylistDialog() -> NSSavePanel {
        
        let dialog = NSSavePanel()
        
        dialog.title                   = String(format: "Save current playlist as a (.%@) file", AppConstants.m3u)
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = true
        
        dialog.canCreateDirectories    = true
        dialog.allowedFileTypes        = [AppConstants.m3u]
        
        dialog.directoryURL = AppConstants.musicDirURL
        
        return dialog
    }
    
    private static func createOpenPlaylistDialog() -> NSOpenPanel {
        
        let dialog = NSOpenPanel()
        
        dialog.message = String(format: "Choose a (.%@/.%@) playlist file", AppConstants.m3u, AppConstants.m3u8)
        
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = true
        
        dialog.canChooseDirectories    = false
        
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = [AppConstants.m3u, AppConstants.m3u8]
        
        dialog.resolvesAliases = true;
        
        dialog.directoryURL = AppConstants.musicDirURL
        
        return dialog
    }
    
    private static func createOpenFolderDialog() -> NSOpenPanel {
        
        let dialog = NSOpenPanel()
        
        dialog.message = "Choose a folder containing tracks"
        
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = true
        
        dialog.canChooseDirectories    = true
        dialog.canChooseFiles = false
        
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        
        dialog.resolvesAliases = true;
        
        dialog.directoryURL = AppConstants.musicDirURL
        
        return dialog
    }
    
    private static func createSaveRecordingDialog() -> NSSavePanel {
        
        let dialog = NSSavePanel()
        
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        
        dialog.canCreateDirectories    = true
        
        dialog.directoryURL = AppConstants.musicDirURL
        
        return dialog
    }
    
    static func saveRecordingPanel(_ fileExtension: String) -> NSSavePanel {
        
        saveRecordingDialog.title = String(format: "Save recording as a (.%@) file", fileExtension)
        saveRecordingDialog.allowedFileTypes = [fileExtension]
        
        return saveRecordingDialog
    }
    
    private static func createSaveRecordingAlert() -> NSAlert {
        
        let alert = NSAlert()
        
        alert.window.title = "Save/discard ongoing recording"
        
        alert.messageText = "You have an ongoing recording. Would you like to save it before exiting the app ?"
        alert.alertStyle = .warning
        alert.icon = Images.imgWarning
        
        alert.addButton(withTitle: "Save recording and exit")
        alert.addButton(withTitle: "Discard recording and exit")
        alert.addButton(withTitle: "Don't exit")
        
        return alert
    }
    
    private static func createTrackNotPlayedAlert() -> NSAlert {
        
        let alert = NSAlert()
        
        alert.window.title = "Track not playable"
        
        alert.alertStyle = .warning
        alert.icon = Images.imgError

        alert.addButton(withTitle: "Remove track from playlist")
        
        return alert
    }
    
    static func trackNotPlayedAlertWithError(_ error: InvalidTrackError) -> NSAlert {
        
        let alert = trackNotPlayedAlert
        
        alert.messageText = String(format: "The track '%@' cannot be played back !", error.track.file.lastPathComponent)
        alert.informativeText = error.message
        
        return alert
    }
    
    static func trackNotPlayedAlertWithError(_ error: FileNotFoundError, _ actionMessage: String?) -> NSAlert {
        
        let alert = trackNotPlayedAlert
        
        alert.messageText = String(format: "The track '%@' cannot be played back !", error.file.lastPathComponent)
        alert.informativeText = error.message
        
        if let msg = actionMessage {
            alert.buttons[0].title = msg
        }
        
        return alert
    }
    
    private static func createTracksNotAddedAlert() -> NSAlert {
        
        let alert = NSAlert()
        
        alert.window.title = "File(s) not added"
        
        let infoText: String = "- File(s) point to missing/broken paths.\n- Playlist file(s) point to audio file(s) with missing/broken paths.\n- File(s) are corrupted/damaged."
        
        alert.informativeText = infoText
        
        alert.alertStyle = .warning
        alert.icon = Images.imgWarning
        
        let rect: NSRect = NSRect(x: alert.window.frame.origin.x, y: alert.window.frame.origin.y, width: alert.window.frame.width, height: 150)
        alert.window.setFrame(rect, display: true)
        
        alert.addButton(withTitle: "Ok")
        
        return alert
    }
    
    static func tracksNotAddedAlertWithErrors(_ errors: [DisplayableError]) -> NSAlert {
        
        let alert = tracksNotAddedAlert
        
        let numErrors = errors.count
        
        alert.messageText = String(format: "%d of your chosen files were not added to the playlist. Possible reasons are listed below.", numErrors)
        
        return alert
    }
}

// Enumeration of all possible responses in the save/discard ongoing recording alert (possibly) displayed when exiting the app
enum RecordingAlertResponse: Int {
    
    case saveAndExit = 1000
    case discardAndExit = 1001
    case dontExit = 1002
}
