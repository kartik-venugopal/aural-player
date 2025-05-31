//
//  DialogsAndAlerts.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Container for definitions of reusable UI dialogs and alerts
*/
struct DialogsAndAlerts {
    
    // MARK: NSOpenPanel ------------------------------------------
    
    private static let openPanel: NSOpenPanel = NSOpenPanel()
    
    // Used to add tracks/playlists.
    static var openFilesAndFoldersDialog: NSOpenPanel {
        
        configureOpenPanel(title: String(format: "Choose audio files, playlists (.%@/.%@), or directories",
                                         SupportedTypes.m3u, SupportedTypes.m3u8),
                           canChooseFiles: true,
                           canChooseDirectories: true,
                           allowsMultipleSelection: true,
                           allowedFileTypes: SupportedTypes.all)
        
        return openPanel
    }
    
    // Used to load a single playlist file (on startup).
    static var openPlaylistFileDialog: NSOpenPanel {
        
        configureOpenPanel(title: String(format: "Choose a (.%@/.%@) playlist file", SupportedTypes.m3u, SupportedTypes.m3u8),
                           canChooseFiles: true,
                           canChooseDirectories: false,
                           allowsMultipleSelection: false,
                           allowedFileTypes: SupportedTypes.playlistExtensions)
        
        return openPanel
    }
    
    static var openLyricsFileDialog: NSOpenPanel {
        
        configureOpenPanel(title: "Choose a (.\(SupportedTypes.lrc)/.\(SupportedTypes.lrcx)) lyrics file",
                           canChooseFiles: true,
                           canChooseDirectories: false,
                           allowsMultipleSelection: false,
                           allowedFileTypes: SupportedTypes.lyricsFileExtensions)
        
        return openPanel
    }
    
    // Used to load a single folder (on startup).
    static var openFolderDialog: NSOpenPanel {
        
        configureOpenPanel(title: "Choose a folder containing tracks",
                               canChooseFiles: false,
                               canChooseDirectories: true,
                               allowsMultipleSelection: false,
                               allowedFileTypes: nil)
        
        return openPanel
    }
    
    static var openLyricsFolderDialog: NSOpenPanel {
        
        configureOpenPanel(title: "Choose a folder containing (.\(SupportedTypes.lrc)/.\(SupportedTypes.lrcx)) lyrics files",
                               canChooseFiles: false,
                               canChooseDirectories: true,
                               allowsMultipleSelection: false,
                               allowedFileTypes: nil)
        
        return openPanel
    }
    
    private static func configureOpenPanel(title: String, canChooseFiles: Bool, canChooseDirectories: Bool,
                                        allowsMultipleSelection: Bool, allowedFileTypes: [String]?) {
        
        openPanel.message = title
        
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = true
        
        openPanel.canChooseFiles = canChooseFiles
        openPanel.allowedFileTypes = allowedFileTypes
        openPanel.canChooseDirectories = canChooseDirectories
        openPanel.allowsMultipleSelection = allowsMultipleSelection
        
        openPanel.canCreateDirectories = false
        openPanel.resolvesAliases = true;
        openPanel.directoryURL = FilesAndPaths.musicDir
    }
    
    // MARK: NSSavePanel ------------------------------------------
    
    private static let savePanel: NSSavePanel = NSSavePanel()
    
    // Used to save current playlist to a file
    static var savePlaylistDialog: NSSavePanel {
        
        configureSavePanel(title: String(format: "Save current playlist as a (.%@) file", SupportedTypes.m3u8),
                           allowedFileTypes: [SupportedTypes.m3u8])
        
        return savePanel
    }
    
    // Used when exporting track metadata / cover art to an HTML / JPEG / PNG file.
    static func exportMetadataDialog(fileName: String, fileExtension: String) -> NSSavePanel {
        
        configureSavePanel(title: String(format: "Export metadata as a (.%@) file", fileExtension),
                           allowedFileTypes: [fileExtension], nameField: "\(fileName).\(fileExtension)")
        
        return savePanel
    }
    
    private static func configureSavePanel(title: String, allowedFileTypes: [String]?, nameField: String? = nil) {
        
        savePanel.title = title
        savePanel.showsResizeIndicator = true
        savePanel.showsHiddenFiles = true
        
        savePanel.canCreateDirectories = true
        savePanel.allowedFileTypes = allowedFileTypes
        
        if let theNameField = nameField {
            savePanel.nameFieldStringValue = theNameField
        }
        
        savePanel.directoryURL = FilesAndPaths.musicDir
    }
    
    // MARK: NSAlert ------------------------------------------
    
    static let alert: NSAlert = NSAlert()
    
    static func genericErrorAlert(_ title: String, _ message: String, _ info: String) -> NSAlert {
        
        configureAlert(alert, title: title,
                       message: message,
                       info: info,
                       icon: .imgError,
                       buttonTitles: ["OK"])
        
        return alert
    }
    
    // Used to warn the user that certain files were not added to the playlist
    static func tracksNotAddedAlert(errors: [DisplayableError]) -> NSAlert {
        
        configureAlert(alert, title: "File(s) not added",
                       message: String(format: "%d of your chosen files were not added to the playlist. Possible reasons are listed below.", errors.count),
                       info: "- File(s) point to missing/broken paths.\n- Playlist file(s) point to audio file(s) with missing/broken paths.\n- File(s) are corrupted/damaged.",
                       icon: .imgWarning,
                       buttonTitles: ["OK"])
        
        let rect: NSRect = NSRect(x: alert.window.x, y: alert.window.y, width: alert.window.width, height: 150)
        alert.window.setFrame(rect, display: true)
        
        return alert
    }
    
    private static func configureAlert(_ alert: NSAlert, title: String, message: String, info: String,
                                       icon: NSImage, buttonTitles: [String] = []) {
        
        alert.window.title = title
        alert.messageText = message
        alert.informativeText = info
        
        alert.alertStyle = .warning
        alert.icon = icon
        
        for (index, buttonTitle) in buttonTitles.enumerated() {

            if index >= alert.buttons.count {
                alert.addButton(withTitle: buttonTitle)
            } else {
                alert.buttons[index].title = buttonTitle
            }
        }
    }
}
