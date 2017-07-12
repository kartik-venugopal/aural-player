
import Cocoa

/*
    Container for definitions of reusable UI components
*/
class UIElements {
    
    // Used to add tracks/playlists
    static let openDialog: NSOpenPanel = UIElements.createOpenPanel()
    
    // Used to save current playlist to a file
    static let saveDialog: NSSavePanel = UIElements.createSavePanel()
    
    private static func createOpenPanel() -> NSOpenPanel {
        
        let dialog = NSOpenPanel()
        
        dialog.title                   = "Choose media (.mp3/.m4a) or playlist (.apl) files";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        
        dialog.canChooseDirectories    = true;
        
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = true;
        dialog.allowedFileTypes        = AppConstants.supportedFileTypes_open
        
        dialog.directoryURL = UIConstants.musicDirURL
        
        return dialog
    }
    
    private static func createSavePanel() -> NSSavePanel {
        
        let dialog = NSSavePanel()
        
        dialog.title                   = "Save current playlist as a (.apl) file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        
        dialog.canCreateDirectories    = true
        dialog.allowedFileTypes        = AppConstants.supportedFileTypes_save
        
        dialog.directoryURL = UIConstants.musicDirURL
        
        return dialog
    }
}