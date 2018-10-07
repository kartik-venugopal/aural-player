import Cocoa

class PlaylistPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnEmptyPlaylist: NSButton!
    @IBOutlet weak var btnRememberPlaylist: NSButton!
    
    @IBOutlet weak var btnLoadPlaylistFromFile: NSButton!
    @IBOutlet weak var btnBrowseFile: NSButton!
    
    @IBOutlet weak var btnLoadTracksFromFolder: NSButton!
    @IBOutlet weak var btnBrowseFolder: NSButton!
    
    @IBOutlet weak var errorIcon_1: NSImageView!
    @IBOutlet weak var errorIcon_2: NSImageView!
    
    @IBOutlet weak var lblPlaylistFile: NSTextField!
    @IBOutlet weak var lblPlaylistFileCell: ValidatedLabelCell!
    
    @IBOutlet weak var lblFolder: NSTextField!
    @IBOutlet weak var lblFolderCell: ValidatedLabelCell!
    
    override var nibName: String? {return "PlaylistPreferences"}
    
    func getView() -> NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        switch preferences.playlistPreferences.playlistOnStartup {
            
        case .empty:
            btnEmptyPlaylist.state = UIConstants.buttonState_1
            
        case .rememberFromLastAppLaunch:
            btnRememberPlaylist.state = UIConstants.buttonState_1
            
        case .loadFile:
            btnLoadPlaylistFromFile.state = UIConstants.buttonState_1
            
        case .loadFolder:
            btnLoadTracksFromFolder.state = UIConstants.buttonState_1
            
        }
        
        [btnBrowseFile, lblPlaylistFile].forEach({
            $0!.isEnabled = Bool(btnLoadPlaylistFromFile.state.rawValue)
        })
        
        [btnBrowseFolder, lblFolder].forEach({
            $0!.isEnabled = Bool(btnLoadTracksFromFolder.state.rawValue)
        })
        
        hideError_playlistFile()
        hideError_tracksFolder()
        
        lblPlaylistFile.stringValue = preferences.playlistPreferences.playlistFile?.path ?? ""
        lblFolder.stringValue = preferences.playlistPreferences.tracksFolder?.path ?? ""
    }
    
    @IBAction func startupPlaylistPrefAction(_ sender: Any) {
        
        // Needed for radio button group
        
        [btnBrowseFile, lblPlaylistFile].forEach({
            $0!.isEnabled = Bool(btnLoadPlaylistFromFile.state.rawValue)
        })
        
        [btnBrowseFolder, lblFolder].forEach({
            $0!.isEnabled = Bool(btnLoadTracksFromFolder.state.rawValue)
        })
        
        if (btnLoadPlaylistFromFile.state.rawValue == 0 && !errorIcon_1.isHidden) {
            hideError_playlistFile()
        }
    
        if btnLoadPlaylistFromFile.state.rawValue == 1 && StringUtils.isStringEmpty(lblPlaylistFile.stringValue) {
            choosePlaylistFileAction(sender)
        }
        
        if (btnLoadTracksFromFolder.state.rawValue == 0 && !errorIcon_2.isHidden) {
            hideError_tracksFolder()
        }
        
        if btnLoadTracksFromFolder.state.rawValue == 1 && StringUtils.isStringEmpty(lblFolder.stringValue) {
            chooseTracksFolderAction(sender)
        }
    }
    
    func save(_ preferences: Preferences) throws {
        
        if btnEmptyPlaylist.state.rawValue == 1 {
            
            preferences.playlistPreferences.playlistOnStartup = .empty
            
        } else if btnRememberPlaylist.state.rawValue == 1 {
            
            preferences.playlistPreferences.playlistOnStartup = .rememberFromLastAppLaunch
            
        } else if btnLoadPlaylistFromFile.state.rawValue == 1 {
            
            preferences.playlistPreferences.playlistOnStartup = .loadFile
            
            // Make sure 1 - label is not empty, and 2 - no previous error message is shown
            if !StringUtils.isStringEmpty(lblPlaylistFile.stringValue) && errorIcon_1.isHidden {
                
                preferences.playlistPreferences.playlistFile = URL(fileURLWithPath: lblPlaylistFile.stringValue)
                
            } else {
                
                // Error
                showError_playlistFile()
                throw PlaylistFileNotSpecifiedError("No playlist file specified for loading upon app startup")
            }
            
        } else {
            
            // Load tracks from folder
            
            preferences.playlistPreferences.playlistOnStartup = .loadFolder
            
            // Make sure 1 - label is not empty, and 2 - no previous error message is shown
            if !StringUtils.isStringEmpty(lblFolder.stringValue) && errorIcon_2.isHidden {
                
                preferences.playlistPreferences.tracksFolder = URL(fileURLWithPath: lblFolder.stringValue)
                
            } else {
                
                // Error
                showError_tracksFolder()
                throw PlaylistFileNotSpecifiedError("No tracks folder specified for loading tracks upon app startup")
            }
        }
    }
    
    @IBAction func choosePlaylistFileAction(_ sender: Any) {
        
        let dialog = DialogsAndAlerts.openPlaylistDialog
        
        let modalResponse = dialog.runModal()
        
        if (modalResponse == NSApplication.ModalResponse.OK) {
            
            let playlistFile = dialog.urls[0]
            
            hideError_playlistFile()
            lblPlaylistFile.stringValue = playlistFile.path
        }
    }
    
    @IBAction func chooseTracksFolderAction(_ sender: Any) {
        
        let dialog = DialogsAndAlerts.openFolderDialog
        
        let modalResponse = dialog.runModal()
        
        if (modalResponse == NSApplication.ModalResponse.OK) {
            
            let folder = dialog.urls[0]
            
            hideError_tracksFolder()
            lblFolder.stringValue = folder.path
        }
    }
    
    private func showError_playlistFile() {
        
        lblPlaylistFileCell.markError("  Please choose a playlist file!")
        lblPlaylistFile.setNeedsDisplay()
        errorIcon_1.isHidden = false
    }
    
    private func showError_tracksFolder() {
        
        lblFolderCell.markError("  Please choose a folder!")
        lblFolder.setNeedsDisplay()
        errorIcon_2.isHidden = false
    }
    
    private func hideError_playlistFile() {
        
        lblPlaylistFileCell.clearError()
        lblPlaylistFile.setNeedsDisplay()
        errorIcon_1.isHidden = true
    }
    
    private func hideError_tracksFolder() {
        
        lblFolderCell.clearError()
        lblFolder.setNeedsDisplay()
        errorIcon_2.isHidden = true
    }
}
