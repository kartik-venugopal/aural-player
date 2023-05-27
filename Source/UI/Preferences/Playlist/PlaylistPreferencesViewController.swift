//
//  PlaylistPreferencesViewController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
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
    
    @IBOutlet weak var btnRememberView: NSButton!
    @IBOutlet weak var btnStartWithView: NSButton!
    @IBOutlet weak var viewMenu: NSPopUpButton!
    
    @IBOutlet weak var btnShowNewTrack: NSButton!
    @IBOutlet weak var btnShowChaptersList: NSButton!
    
    @IBOutlet weak var btnDragDropAppend: NSButton!
    @IBOutlet weak var btnDragDropReplace: NSButton!
    @IBOutlet weak var btnDragDropHybrid: NSButton!
    
    @IBOutlet weak var btnOpenWithAppend: NSButton!
    @IBOutlet weak var btnOpenWithReplace: NSButton!
    
    override var nibName: String? {"PlaylistPreferences"}
    
    var preferencesView: NSView {
        self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let playlistPrefs = preferences.playlistPreferences
        
        switch playlistPrefs.playlistOnStartup {
            
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
        
        // View on startup
        
        if playlistPrefs.viewOnStartup.option == .specific {
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
        
        switch playlistPrefs.dragDropAddMode {
            
        case .append:
            
            btnDragDropAppend.on()
            
        case .replace:
            
            btnDragDropReplace.on()
            
        case .hybrid:
            
            btnDragDropHybrid.on()
        }
        
        if playlistPrefs.openWithAddMode == .append {
            btnOpenWithAppend.on()
        } else {
            btnOpenWithReplace.on()
        }
    }
    
    @IBAction func startupPlaylistPrefAction(_ sender: Any) {
        
        // Needed for radio button group
        
        [btnBrowseFile, lblPlaylistFile].forEach({
            $0!.enableIf(btnLoadPlaylistFromFile.isOn)
        })
        
        [btnBrowseFolder, lblFolder].forEach({
            $0!.enableIf(btnLoadTracksFromFolder.isOn)
        })
        
        if btnLoadPlaylistFromFile.isOff {
            
            if errorIcon_1.isShown {
                hideError_playlistFile()
            }
            
            lblPlaylistFile.stringValue = ""
        }
        
        if btnLoadTracksFromFolder.isOff {
            
            if errorIcon_2.isShown {
                hideError_tracksFolder()
            }
            
            lblFolder.stringValue = ""
        }
    
        if btnLoadPlaylistFromFile.isOn && String.isEmpty(lblPlaylistFile.stringValue) {
            choosePlaylistFileAction(sender)
        }
        
        if btnLoadTracksFromFolder.isOn && String.isEmpty(lblFolder.stringValue) {
            chooseTracksFolderAction(sender)
        }
    }
    
    @IBAction func startupPlaylistViewPrefAction(_ sender: Any) {
        // Needed for radio button group
        viewMenu.enableIf(btnStartWithView.isOn)
    }
    
    @IBAction func dragDropAddModePrefAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func openWithAddModePrefAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    func save(_ preferences: Preferences) throws {
        
        let prefs: PlaylistPreferences = preferences.playlistPreferences
        
        if btnEmptyPlaylist.isOn {
            
            prefs.playlistOnStartup = .empty
            
        } else if btnRememberPlaylist.isOn {
            
            prefs.playlistOnStartup = .rememberFromLastAppLaunch
            
        } else if btnLoadPlaylistFromFile.isOn {
            
            // Make sure 1 - label is not empty, and 2 - no previous error message is shown
            if !String.isEmpty(lblPlaylistFile.stringValue) && errorIcon_1.isHidden {
                
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
            if !String.isEmpty(lblFolder.stringValue) && errorIcon_2.isHidden {
            
                prefs.playlistOnStartup = .loadFolder
                prefs.tracksFolder = URL(fileURLWithPath: lblFolder.stringValue)
                
            } else {
                
                // Error
                showError_tracksFolder()
                throw PlaylistFileNotSpecifiedError("No tracks folder specified for loading tracks upon app startup")
            }
        }
        
        // View on startup
        prefs.viewOnStartup.option = btnStartWithView.isOn ? .specific : .rememberFromLastAppLaunch
        prefs.viewOnStartup.viewName = viewMenu.selectedItem!.title
        
        // Show new track
        prefs.showNewTrackInPlaylist = btnShowNewTrack.isOn
        
        // Show chapters list window
        prefs.showChaptersList = btnShowChaptersList.isOn
        
        if btnDragDropAppend.isOn {
            prefs.dragDropAddMode = .append
            
        } else if btnDragDropReplace.isOn {
            prefs.dragDropAddMode = .replace
            
        } else {
            prefs.dragDropAddMode = .hybrid
        }
        
        prefs.openWithAddMode = btnOpenWithAppend.isOn ? .append : .replace
    }
    
    @IBAction func choosePlaylistFileAction(_ sender: Any) {
        
        let dialog = DialogsAndAlerts.openPlaylistFileDialog
        guard dialog.runModal() == .OK else {return}
        
        let playlistFile = dialog.urls[0]
        
        hideError_playlistFile()
        lblPlaylistFile.stringValue = playlistFile.path
    }
    
    @IBAction func chooseTracksFolderAction(_ sender: Any) {
        
        let dialog = DialogsAndAlerts.openFolderDialog
        guard dialog.runModal() == .OK else {return}
        
        let folder = dialog.urls[0]
        
        hideError_tracksFolder()
        lblFolder.stringValue = folder.path
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
