//
// LyricsPreferencesViewController.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class LyricsPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    override var nibName: NSNib.Name? {"LyricsPreferences"}
    
    @IBOutlet weak var btnEnableAutoShowWindow: CheckBox!
    @IBOutlet weak var btnEnableAutoScroll: CheckBox!
    @IBOutlet weak var btnEnableKaraokeMode: CheckBox!
    @IBOutlet weak var lblLyricsFolder: NSTextField!
    
    private var lyricsFilesFolder: URL?
    
    private static let disabledControlTooltip: String = "<This preference is only applicable to the \"Modular\" and \"Unified\" app modes>"
    
    var preferencesView: NSView {
        view
    }
    
    private var lyricsPrefs: LyricsPreferences {
        preferences.metadataPreferences.lyrics
    }
    
    func resetFields() {
        
        btnEnableAutoShowWindow.onIf(lyricsPrefs.showWindowWhenPresent.value)
        btnEnableAutoScroll.onIf(lyricsPrefs.enableAutoScroll.value)
        btnEnableKaraokeMode.onIf(lyricsPrefs.enableKaraokeMode.value)
        
        if let dir = lyricsPrefs.lyricsFilesDirectory.value {
            lblLyricsFolder.stringValue = dir.path
        } else {
            lblLyricsFolder.stringValue = ""
        }
        
        disableIrrelevantControls()
    }
    
    private func disableIrrelevantControls() {
        
        guard let currentMode = appModeManager.currentMode, !currentMode.equalsOneOf(.modular, .unified) else {return}
        
        btnEnableAutoShowWindow.disable()
        btnEnableAutoShowWindow.toolTip = Self.disabledControlTooltip
    }
    
    @IBAction func chooseLyricsFolderAction(_ sender: NSButton) {
        
        let dialog = DialogsAndAlerts.openLyricsFolderDialog
        
        if dialog.runModal() == .OK,
           let folder = dialog.url {
            
            lblLyricsFolder.stringValue = folder.path
        }
    }
    
    @IBAction func clearLyricsFolderAction(_ sender: NSButton) {
        lblLyricsFolder.stringValue = ""
    }
    
    func save() throws {
        
        lyricsPrefs.showWindowWhenPresent.value = btnEnableAutoShowWindow.isOn
        lyricsPrefs.enableAutoScroll.value = btnEnableAutoScroll.isOn
        
        let oldKaraokeModeValue = lyricsPrefs.enableKaraokeMode.value
        lyricsPrefs.enableKaraokeMode.value = btnEnableKaraokeMode.isOn
        
        if !String.isEmpty(lblLyricsFolder.stringValue) {
            lyricsPrefs.lyricsFilesDirectory.value = URL(fileURLWithPath: lblLyricsFolder.stringValue)
        } else {
            lyricsPrefs.lyricsFilesDirectory.value = nil
        }
        
        if lyricsPrefs.enableKaraokeMode.value != oldKaraokeModeValue {
            Messenger.publish(.Lyrics.karaokeModePreferenceUpdated)
        }
    }
}
