//
//  PlayQueuePreferencesViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PlayQueuePreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnEmptyPlayQueue: RadioButton!
    @IBOutlet weak var btnRememberPlayQueue: RadioButton!
    
    @IBOutlet weak var btnLoadPlaylistFile: RadioButton!
    @IBOutlet weak var btnBrowseFile: NSButton!
    
    @IBOutlet weak var btnLoadTracksFromFolder: NSButton!
    @IBOutlet weak var btnBrowseFolder: NSButton!
    
    @IBOutlet weak var errorIcon_1: NSImageView!
    @IBOutlet weak var errorIcon_2: NSImageView!
    
    @IBOutlet weak var lblPlaylistFile: NSTextField!
    @IBOutlet weak var lblPlaylistFileCell: ValidatedLabelCell!
    
    @IBOutlet weak var lblFolder: NSTextField!
    @IBOutlet weak var lblFolderCell: ValidatedLabelCell!
    
    @IBOutlet weak var btnShowNewTrack: CheckBox!
    @IBOutlet weak var btnShowChaptersList: CheckBox!
    
    @IBOutlet weak var btnDragDropAppend: RadioButton!
    @IBOutlet weak var btnDragDropReplace: RadioButton!
    @IBOutlet weak var btnDragDropHybrid: RadioButton!
    
    @IBOutlet weak var btnOpenWithAppend: RadioButton!
    @IBOutlet weak var btnOpenWithReplace: RadioButton!
    
    @IBOutlet weak var btnPlayParentFolder: CheckBox!
    
    override var nibName: NSNib.Name? {"PlayQueuePreferences"}
    
    var preferencesView: NSView {
        self.view
    }
    
    func resetFields() {
        
        let pqPrefs = preferences.playQueuePreferences
        
        switch pqPrefs.playQueueOnStartup {

        case .empty:
            btnEmptyPlayQueue.on()
            
        case .rememberFromLastAppLaunch:
            btnRememberPlayQueue.on()
            
        case .loadPlaylistFile:
            btnLoadPlaylistFile.on()
            
        case .loadFolder:
            btnLoadTracksFromFolder.on()
        }
        
        [btnBrowseFile, lblPlaylistFile].forEach({
            $0!.enableIf(btnLoadPlaylistFile.isOn)
        })
        
        [btnBrowseFolder, lblFolder].forEach({
            $0!.enableIf(btnLoadTracksFromFolder.isOn)
        })
        
        hideError_playlistFile()
        hideError_tracksFolder()
        
        lblPlaylistFile.stringValue = preferences.playQueuePreferences.playlistFile?.path ?? ""
        lblFolder.stringValue = preferences.playQueuePreferences.tracksFolder?.path ?? ""
        
        // Show new track
        btnShowNewTrack.onIf(pqPrefs.showNewTrackInPlayQueue)
        
        // Show chapters list window
        btnShowChaptersList.onIf(pqPrefs.showChaptersList)
        
        switch pqPrefs.dragDropAddMode {
            
        case .append:
            
            btnDragDropAppend.on()
            
        case .replace:
            
            btnDragDropReplace.on()
            
        case .hybrid:
            
            btnDragDropHybrid.on()
        }
        
        if pqPrefs.openWithAddMode == .append {
            btnOpenWithAppend.on()
        } else {
            btnOpenWithReplace.on()
        }
        
        btnPlayParentFolder.onIf(pqPrefs.playParentFolder)
        
        if let appMode = appModeManager.currentMode, !appMode.equalsOneOf(.modular, .unified) {
            
            btnShowChaptersList.disable()
            btnShowChaptersList.toolTip = "<This preference is only applicable to the \"Modular\" and \"Unified\" app modes>"
        }
     }
    
    @IBAction func startupPlayQueuePrefAction(_ sender: Any) {
        
        // Needed for radio button group
        
        [btnBrowseFile, lblPlaylistFile].forEach({
            $0!.enableIf(btnLoadPlaylistFile.isOn)
        })
        
        [btnBrowseFolder, lblFolder].forEach({
            $0!.enableIf(btnLoadTracksFromFolder.isOn)
        })
        
        if btnLoadPlaylistFile.isOff {
            
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
    
        if btnLoadPlaylistFile.isOn && String.isEmpty(lblPlaylistFile.stringValue) {
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
        
        if btnEmptyPlayQueue.isOn {
            
            prefs.playQueueOnStartup = .empty
            
        } else if btnRememberPlayQueue.isOn {
            
            prefs.playQueueOnStartup = .rememberFromLastAppLaunch
            
        } else if btnLoadPlaylistFile.isOn {
            
            // Make sure 1 - label is not empty, and 2 - no previous error message is shown
            if !String.isEmpty(lblPlaylistFile.stringValue) && errorIcon_1.isHidden {
                
                prefs.playQueueOnStartup = .loadPlaylistFile
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
            
                prefs.playQueueOnStartup = .loadFolder
                prefs.tracksFolder = URL(fileURLWithPath: lblFolder.stringValue)
                
            } else {
                
                // Error
                showError_tracksFolder()
                throw PlaylistFileNotSpecifiedError("No tracks folder specified for loading tracks upon app startup")
            }
        }
        
        // Show new track
        prefs.showNewTrackInPlayQueue = btnShowNewTrack.isOn

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
        prefs.playParentFolder = btnPlayParentFolder.isOn
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
