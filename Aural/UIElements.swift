
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
    
    fileprivate static func createOpenPanel() -> NSOpenPanel {
        
        let dialog = NSOpenPanel()
        
        dialog.title                   = "Choose media (.mp3/.m4a) or playlist (.apl) files";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = true;
        
        dialog.canChooseDirectories    = true;
        
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = true;
        dialog.allowedFileTypes        = AppConstants.supportedFileTypes_open
        
        dialog.directoryURL = AppConstants.musicDirURL
        
        return dialog
    }
    
    fileprivate static func createSavePanel() -> NSSavePanel {
        
        let dialog = NSSavePanel()
        
        dialog.title                   = "Save current playlist as a (.apl) file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = true
        
        dialog.canCreateDirectories    = true
        dialog.allowedFileTypes        = AppConstants.supportedFileTypes_save
        
        dialog.directoryURL = AppConstants.musicDirURL
        
        return dialog
    }
    
    fileprivate static func createSaveRecordingPanel() -> NSSavePanel {
        
        let dialog = NSSavePanel()
        
        dialog.title                   = "Save recording"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        
        dialog.canCreateDirectories    = true
        dialog.allowedFileTypes        = [RecordingFormat.aac.fileExtension]
        
        dialog.directoryURL = AppConstants.musicDirURL
        
        return dialog
    }
}
