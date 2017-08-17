
import Cocoa

/*
    Container for definitions of reusable UI components
*/
class UIElements {
    
    // Used to add tracks/playlists
    static let openDialog: NSOpenPanel = UIElements.createOpenPanel()
    
    // Used to save current playlist to a file
    static let savePlaylistDialog: NSSavePanel = UIElements.createSavePanel()
    
    // Used to save a recording to a file
    static let saveRecordingDialog: NSSavePanel = UIElements.createSaveRecordingPanel()
    
    // Used to prompt the user, when exiting the app, that a recording is ongoing, and give the user options to save/discard that recording
    static let saveRecordingAlert: NSAlert = UIElements.createSaveRecordingAlert()
    
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
}
