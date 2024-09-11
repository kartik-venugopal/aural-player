//
//  TrackInfoViewController+MenuDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension TrackInfoViewController: NSMenuDelegate {
    
    func menuWillOpen(_ menu: NSMenu) {
        
        let hasImage: Bool = TrackInfoViewContext.displayedTrack?.art?.originalImage != nil
        
        exportArtMenuItem.showIf(hasImage)
        exportHTMLWithArtMenuItem.showIf(hasImage)
    }
    
    @IBAction func exportJPEGAction(_ sender: AnyObject) {
        doExportArt(.jpeg, "jpg")
    }
    
    @IBAction func exportPNGAction(_ sender: AnyObject) {
        doExportArt(.png, "png")
    }
    
    private func doExportArt(_ type: NSBitmapImageRep.FileType, _ fileExtension: String) {
        
        if let track = TrackInfoViewContext.displayedTrack {
            coverArtViewController.exportArt(forTrack: track, type: type, fileExtension: fileExtension)
        }
    }
    
    @IBAction func exportJSONAction(_ sender: AnyObject) {
        
        guard let track = TrackInfoViewContext.displayedTrack else {return}
        
        let dialog = DialogsAndAlerts.exportMetadataDialog(fileName: track.displayName + "-metadata", fileExtension: "json")
        guard dialog.runModal() == .OK, let outFile = dialog.url else {return}
        
        var appDict = [NSString: AnyObject]()
        appDict["version"] = NSApp.appVersion as AnyObject
        appDict["exportDate"] = dateFormatter.string(from: Date()) as AnyObject

        let dict: [NSString: AnyObject?] = ["appInfo": appDict as NSDictionary,
                                           "metadata": metadataViewController.jsonObject,
                                           "coverArt": coverArtViewController.jsonObject,
                                           "lyrics": lyricsViewController.jsonObject,
                                           "audio": audioViewController.jsonObject,
                                           "fileSystem": fileSystemViewController.jsonObject]
        
        do {
            try JSONSerialization.writeObject(dict as NSDictionary, toFile: outFile)
            
        } catch {
            
            if let error = error as? JSONWriteError {
                _ = DialogsAndAlerts.genericErrorAlert("JSON file not written", error.message, error.description).showModal()
            }
        }
    }
    
    @IBAction func exportHTMLWithArtAction(_ sender: AnyObject) {
        doExportHTML(withArt: true)
    }
    
    @IBAction func exportHTMLAction(_ sender: AnyObject) {
        doExportHTML(withArt: false)
    }
        
    private func doExportHTML(withArt includeArt: Bool) {
        
        guard let track = TrackInfoViewContext.displayedTrack else {return}
        
        let dialog = DialogsAndAlerts.exportMetadataDialog(fileName: track.displayName + "-metadata", fileExtension: "html")
        guard dialog.runModal() == .OK, let outFile = dialog.url else {return}
            
        do {
            let writer = HTMLWriter(outputFile: outFile)
            
            writer.addTitle(track.displayName)
            writer.addHeading(track.displayName, 2, false)
            
            let text = String(format: "Metadata exported by Aural Player v%@ on: %@", NSApp.appVersion, dateFormatter.string(from: Date()))
            let exportDate = HTMLText(text: text, underlined: true, bold: false, italic: false, width: nil)
            writer.addParagraph(exportDate)
            
            if includeArt {
                coverArtViewController.writeHTML(to: writer)
            }
            
            ([metadataViewController, lyricsViewController, audioViewController, fileSystemViewController] as? [TrackInfoViewProtocol])?.forEach {
                $0.writeHTML(to: writer)
            }
            
            try writer.writeToFile()
            
        } catch {
            
            if let error = error as? HTMLWriteError {
                _ = DialogsAndAlerts.genericErrorAlert("HTML file not written", error.message, error.description).showModal()
            }
        }
    }
}
