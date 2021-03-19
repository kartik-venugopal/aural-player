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
    
<<<<<<< HEAD:Aural/PlaylistPreferencesViewController.swift
=======
    @IBOutlet weak var btnRememberView: NSButton!
    @IBOutlet weak var btnStartWithView: NSButton!
    @IBOutlet weak var viewMenu: NSPopUpButton!
    
    @IBOutlet weak var btnShowNewTrack: NSButton!
    @IBOutlet weak var btnShowChaptersList: NSButton!
    
>>>>>>> upstream/master:Source/UI/Preferences/Playlist/PlaylistPreferencesViewController.swift
    override var nibName: String? {return "PlaylistPreferences"}
    
    var preferencesView: NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        switch preferences.playlistPreferences.playlistOnStartup {
            
        case .empty:
            btnEmptyPlaylist.on()
            
        case .rememberFromLastAppLaunch:
            btnRememberPlaylist.on()
            
        case .loadFile:
            btnLoadPlaylistFromFile.on()
            
        case .loadFolder:
            btnLoadTracksFromFolder.on()
            
        }
        
        [btnBrowseFile, lblPlaylistFile].forEach({
            $0!.enableIf(btnLoadPlaylistFromFile.isOn)
        })
        
        [btnBrowseFolder, lblFolder].forEach({
            $0!.enableIf(btnLoadTracksFromFolder.isOn)
        })
        
        hideError_playlistFile()
        hideError_tracksFolder()
        
        lblPlaylistFile.stringValue = preferences.playlistPreferences.playlistFile?.path ?? ""
        lblFolder.stringValue = preferences.playlistPreferences.tracksFolder?.path ?? ""
<<<<<<< HEAD:Aural/PlaylistPreferencesViewController.swift
=======
        
        // View on startup
        
        if (playlistPrefs.viewOnStartup.option == .specific) {
            btnStartWithView.on()
        } else {
            btnRememberView.on()
        }
        
        if let item = viewMenu.item(withTitle: playlistPrefs.viewOnStartup.viewName) {
            viewMenu.select(item)
        } else {
            // Default
            viewMenu.select(viewMenu.item(withTitle: "Tracks"))
        }
        viewMenu.enableIf(btnStartWithView.isOn)
        
        // Show new track
        btnShowNewTrack.onIf(playlistPrefs.showNewTrackInPlaylist)
        
        // Show chapters list window
        btnShowChaptersList.onIf(playlistPrefs.showChaptersList)
>>>>>>> upstream/master:Source/UI/Preferences/Playlist/PlaylistPreferencesViewController.swift
    }
    
    @IBAction func startupPlaylistPrefAction(_ sender: Any) {
        
        // Needed for radio button group
        
        [btnBrowseFile, lblPlaylistFile].forEach({
            $0!.enableIf(btnLoadPlaylistFromFile.isOn)
        })
        
        [btnBrowseFolder, lblFolder].forEach({
            $0!.enableIf(btnLoadTracksFromFolder.isOn)
        })
        
        if (btnLoadPlaylistFromFile.isOff && !errorIcon_1.isHidden) {
            hideError_playlistFile()
        }
        
        if (btnLoadTracksFromFolder.isOff && !errorIcon_2.isHidden) {
            hideError_tracksFolder()
        }
    
        if btnLoadPlaylistFromFile.isOn && StringUtils.isStringEmpty(lblPlaylistFile.stringValue) {
            choosePlaylistFileAction(sender)
        }
        
        if btnLoadTracksFromFolder.isOn && StringUtils.isStringEmpty(lblFolder.stringValue) {
            chooseTracksFolderAction(sender)
        }
    }
    
<<<<<<< HEAD:Aural/PlaylistPreferencesViewController.swift
=======
    @IBAction func startupPlaylistViewPrefAction(_ sender: Any) {
        // Needed for radio button group
        viewMenu.enableIf(btnStartWithView.isOn)
    }
    
>>>>>>> upstream/master:Source/UI/Preferences/Playlist/PlaylistPreferencesViewController.swift
    func save(_ preferences: Preferences) throws {
        
        let prefs: PlaylistPreferences = preferences.playlistPreferences
        
        if btnEmptyPlaylist.isOn {
            
            prefs.playlistOnStartup = .empty
            
        } else if btnRememberPlaylist.isOn {
            
            prefs.playlistOnStartup = .rememberFromLastAppLaunch
            
        } else if btnLoadPlaylistFromFile.isOn {
            
            // Make sure 1 - label is not empty, and 2 - no previous error message is shown
            if !StringUtils.isStringEmpty(lblPlaylistFile.stringValue) && errorIcon_1.isHidden {
                
                prefs.playlistOnStartup = .loadFile
                prefs.playlistFile = URL(fileURLWithPath: lblPlaylistFile.stringValue)
                
            } else {
                
                // Error
                showError_playlistFile()
                throw PlaylistFileNotSpecifiedError("No playlist file specified for loading upon app startup")
            }
            
        } else {
            
            // Load tracks from folder
            
            // Make sure 1 - label is not empty, and 2 - no previous error message is shown
            if !StringUtils.isStringEmpty(lblFolder.stringValue) && errorIcon_2.isHidden {
            
                prefs.playlistOnStartup = .loadFolder
                prefs.tracksFolder = URL(fileURLWithPath: lblFolder.stringValue)
                
            } else {
                
                // Error
                showError_tracksFolder()
                throw PlaylistFileNotSpecifiedError("No tracks folder specified for loading tracks upon app startup")
            }
        }
<<<<<<< HEAD:Aural/PlaylistPreferencesViewController.swift
=======
        
        // View on startup
        prefs.viewOnStartup.option = btnStartWithView.isOn ? .specific : .rememberFromLastAppLaunch
        prefs.viewOnStartup.viewName = viewMenu.selectedItem!.title
        
        // Show new track
        prefs.showNewTrackInPlaylist = btnShowNewTrack.isOn
        
        // Show chapters list window
        prefs.showChaptersList = btnShowChaptersList.isOn
>>>>>>> upstream/master:Source/UI/Preferences/Playlist/PlaylistPreferencesViewController.swift
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
        lblPlaylistFile.redraw()
        errorIcon_1.show()
    }
    
    private func showError_tracksFolder() {
        
        lblFolderCell.markError("  Please choose a folder!")
        lblFolder.redraw()
        errorIcon_2.show()
    }
    
    private func hideError_playlistFile() {
        
        lblPlaylistFileCell.clearError()
        lblPlaylistFile.redraw()
        errorIcon_1.hide()
    }
    
    private func hideError_tracksFolder() {
        
        lblFolderCell.clearError()
        lblFolder.redraw()
        errorIcon_2.hide()
    }
}
