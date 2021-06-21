import Cocoa

/*
    Container for definitions of reusable UI dialogs and alerts
*/
struct DialogsAndAlerts {
    
    // TODO: Reuse some of these alerts/panels
    
    // Used to add tracks/playlists
    static let openDialog: NSOpenPanel = createOpenDialog()
    
    // Used to load a single playlist file (on startup)
    static let openPlaylistDialog: NSOpenPanel = createOpenPlaylistDialog()
    
    // Used to load a single playlist file (on startup)
    static let openFolderDialog: NSOpenPanel = createOpenFolderDialog()
    
    // Used to save current playlist to a file
    static let savePlaylistDialog: NSSavePanel = createSavePlaylistDialog()
    
    // Used to save a recording to a file
    private static let saveDialog: NSSavePanel = createSaveDialog()
    
    // Used to prompt the user, when exiting the app, that a recording is ongoing, and give the user options to save/discard that recording
    static let saveRecordingAlert: NSAlert = createSaveRecordingAlert()
    
    // Used to inform the user of an error condition
    private static let errorAlert: NSAlert = createErrorAlert()
    
    // Used to warn the user that certain files were not added to the playlist
    private static let tracksNotAddedAlert: NSAlert = createTracksNotAddedAlert()
    
    private static func createOpenDialog() -> NSOpenPanel {
        
        let dialog = NSOpenPanel()
        
        dialog.message = String(format: "Choose media, playlists (.%@/.%@), or directories", AppConstants.SupportedTypes.m3u, AppConstants.SupportedTypes.m3u8)
        
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = true
        
        dialog.canChooseDirectories    = true
        
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = true
        dialog.allowedFileTypes        = AppConstants.SupportedTypes.all
        
        dialog.resolvesAliases = true;
        
        dialog.directoryURL = AppConstants.FilesAndPaths.musicDir
        
        return dialog
    }
    
    private static func createSavePlaylistDialog() -> NSSavePanel {
        
        let dialog = NSSavePanel()
        
        dialog.title                   = String(format: "Save current playlist as a (.%@) file", AppConstants.SupportedTypes.m3u8)
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = true
        
        dialog.canCreateDirectories    = true
        dialog.allowedFileTypes        = [AppConstants.SupportedTypes.m3u8]
        
        dialog.directoryURL = AppConstants.FilesAndPaths.musicDir
        
        return dialog
    }
    
    private static func createOpenPlaylistDialog() -> NSOpenPanel {
        
        let dialog = NSOpenPanel()
        
        dialog.message = String(format: "Choose a (.%@/.%@) playlist file", AppConstants.SupportedTypes.m3u, AppConstants.SupportedTypes.m3u8)
        
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = true
        
        dialog.canChooseDirectories    = false
        
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = AppConstants.SupportedTypes.playlistExtensions
        
        dialog.resolvesAliases = true;
        
        dialog.directoryURL = AppConstants.FilesAndPaths.musicDir
        
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
        
        dialog.directoryURL = AppConstants.FilesAndPaths.musicDir
        
        return dialog
    }
    
    private static func createSaveDialog() -> NSSavePanel {
        
        let dialog = NSSavePanel()
        
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        
        dialog.canCreateDirectories    = true
        
        dialog.directoryURL = AppConstants.FilesAndPaths.musicDir
        
        return dialog
    }
    
    static func saveRecordingPanel(_ fileExtension: String) -> NSSavePanel {
        
        saveDialog.message = String(format: "Save recording as a (.%@) file", fileExtension)
        saveDialog.allowedFileTypes = [fileExtension]
        
        return saveDialog
    }
    
    static func exportMetadataPanel(_ fileName: String, _ fileExtension: String) -> NSSavePanel {
        
        saveDialog.nameFieldStringValue = fileName + "." + fileExtension
        
        saveDialog.message = String(format: "Export metadata as a (.%@) file", fileExtension)
        saveDialog.allowedFileTypes = [fileExtension]
        
        return saveDialog
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
    
    private static func createErrorAlert() -> NSAlert {
        
        let alert = NSAlert()
        
        alert.alertStyle = .warning
        alert.icon = Images.imgError

        alert.addButton(withTitle: "OK")
        
        return alert
    }
    
    static func genericErrorAlert(_ title: String, _ message: String, _ info: String) -> NSAlert {
        
        let alert = errorAlert
        
        alert.window.title = title
        alert.messageText = message
        alert.informativeText = info
        
        return alert
    }
    
    static func trackNotPlayedAlertWithError(_ error: InvalidTrackError) -> NSAlert {
        
        let alert = errorAlert
        
        alert.window.title = "Track not played"
        alert.messageText = String(format: "The track '%@' cannot be played back !", error.file.lastPathComponent)
        
        alert.informativeText = error.message
        
        return alert
    }
    
    static func trackNotPlayedAlertWithError(_ error: FileNotFoundError, _ actionMessage: String?) -> NSAlert {
        
        // TODO: Check center alignment in track name label.
        
        let alert = errorAlert
        
        alert.window.title = "Track not played"
        alert.messageText = String(format: "The track '%@' cannot be played back !", error.file.lastPathComponent)
        alert.informativeText = error.message
        
        if let msg = actionMessage {
            alert.buttons[0].title = msg
        }
        
        return alert
    }
    
    static func historyItemNotAddedAlertWithError(_ error: FileNotFoundError, _ actionMessage: String?) -> NSAlert {
        
        let alert = errorAlert
        
        alert.window.title = "History item not found"
        alert.messageText = String(format: "The history item '%@' cannot be added to the playlist !", error.file.lastPathComponent)
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
        
        let rect: NSRect = NSRect(x: alert.window.frame.origin.x, y: alert.window.frame.origin.y, width: alert.window.width, height: 150)
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
