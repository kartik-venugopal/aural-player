//
//  PlayQueuePreferencesViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PlayQueuePreferencesViewController: NSViewController, PreferencesViewProtocol {
    
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
    
    @IBOutlet weak var btnShowNewTrack: NSButton!
    @IBOutlet weak var btnShowChaptersList: NSButton!
    
    @IBOutlet weak var btnDragDropAppend: NSButton!
    @IBOutlet weak var btnDragDropReplace: NSButton!
    @IBOutlet weak var btnDragDropHybrid: NSButton!
    
    @IBOutlet weak var btnOpenWithAppend: NSButton!
    @IBOutlet weak var btnOpenWithReplace: NSButton!
    
    override var nibName: String? {"PlayQueuePreferences"}
    
    var preferencesView: NSView {
        self.view
    }
    
    func resetFields() {
        
        let pqPrefs = preferences.playQueuePreferences
        
        switch pqPrefs.playQueueOnStartup.value {

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
        
        lblPlaylistFile.stringValue = preferences.playQueuePreferences.playlistFile.value?.path ?? ""
        lblFolder.stringValue = preferences.playQueuePreferences.tracksFolder.value?.path ?? ""
        
        // Show new track
        btnShowNewTrack.onIf(pqPrefs.showNewTrackInPlayQueue.value)
        
        // Show chapters list window
        btnShowChaptersList.onIf(pqPrefs.showChaptersList.value)
        
        switch pqPrefs.dragDropAddMode.value {
            
        case .append:
            
            btnDragDropAppend.on()
            
        case .replace:
            
            btnDragDropReplace.on()
            
        case .hybrid:
            
            btnDragDropHybrid.on()
        }
        
        if pqPrefs.openWithAddMode.value == .append {
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
    
    @IBAction func dragDropAddModePrefAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func openWithAddModePrefAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    func save() throws {
        
        let prefs: PlayQueuePreferences = preferences.playQueuePreferences
        
        if btnEmptyPlaylist.isOn {
            
            prefs.playQueueOnStartup.value = .empty
            
        } else if btnRememberPlaylist.isOn {
            
            prefs.playQueueOnStartup.value = .rememberFromLastAppLaunch
            
        } else if btnLoadPlaylistFromFile.isOn {
            
            // Make sure 1 - label is not empty, and 2 - no previous error message is shown
            if !String.isEmpty(lblPlaylistFile.stringValue) && errorIcon_1.isHidden {
                
                prefs.playQueueOnStartup.value = .loadFile
                prefs.playlistFile.value = URL(fileURLWithPath: lblPlaylistFile.stringValue)
                
            } else {
                
                // Error
                showError_playlistFile()
                throw PlaylistFileNotSpecifiedError("No playlist file specified for loading upon app startup")
            }
            
        } else {
            
            // Load tracks from folder
            
            // Make sure 1 - label is not empty, and 2 - no previous error message is shown
            if !String.isEmpty(lblFolder.stringValue) && errorIcon_2.isHidden {
            
                prefs.playQueueOnStartup.value = .loadFolder
                prefs.tracksFolder.value = URL(fileURLWithPath: lblFolder.stringValue)
                
            } else {
                
                // Error
                showError_tracksFolder()
                throw PlaylistFileNotSpecifiedError("No tracks folder specified for loading tracks upon app startup")
            }
        }
        
        // Show new track
        prefs.showNewTrackInPlayQueue.value = btnShowNewTrack.isOn

        // Show chapters list window
        prefs.showChaptersList.value = btnShowChaptersList.isOn

        if btnDragDropAppend.isOn {
            prefs.dragDropAddMode.value = .append

        } else if btnDragDropReplace.isOn {
            prefs.dragDropAddMode.value = .replace

        } else {
            prefs.dragDropAddMode.value = .hybrid
        }
        
        prefs.openWithAddMode.value = btnOpenWithAppend.isOn ? .append : .replace
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
