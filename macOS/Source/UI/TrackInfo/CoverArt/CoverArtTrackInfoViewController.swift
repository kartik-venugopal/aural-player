//
//  CoverArtTrackInfoViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class CoverArtTrackInfoViewController: NSViewController, TrackInfoViewProtocol {
    
    override var nibName: String? {"CoverArtTrackInfo"}
    
    @IBOutlet weak var tableView: NSTableView!
    
    // Displays track artwork
    @IBOutlet weak var artView: NSImageView!
    @IBOutlet weak var lblNoArt: NSTextField!
    
    private let trackInfoSource: CoverArtTrackInfoSource = .init()
    @IBOutlet weak var tableViewDelegate: TrackInfoViewDelegate! {
        
        didSet {
            tableViewDelegate.trackInfoSource = trackInfoSource
        }
    }
    
    // Called each time the popover is shown ... refreshes the data in the table view depending on which track is currently playing
    func refresh() {
        
        guard let track = TrackInfoViewContext.displayedTrack else {return}
        trackInfoSource.loadTrackInfo(for: track)
        
        artView?.image = track.art?.image
        lblNoArt.showIf(artView?.image == nil)
        
        tableView.reloadData()
    }
    
    func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        refresh()
    }
    
    var jsonObject: AnyObject? {
        artView.image != nil ? tableView.jsonObject : nil
    }
    
    func writeHTML(to writer: HTMLWriter) {
        
        guard let track = TrackInfoViewContext.displayedTrack else {return}
        
        // Embed art in HTML
        guard let image = track.art?.image,
              let bits = image.representations.first as? NSBitmapImageRep,
              let data = bits.representation(using: .jpeg, properties: [:]) else {return}
        
        let outFile = writer.outputFile
        let imgFile = outFile.parentDir.appendingPathComponent(track.displayName + "-coverArt.jpg", isDirectory: false)
        
        do {
            try data.write(to: imgFile)
            
        } catch {}
        
        writer.addImage(imgFile.lastPathComponent, "(Cover Art)")
        
        if artView.image != nil {
            writer.addTable("Cover Art Metadata:", 3, nil, tableView.htmlTable)
        }
    }
    
    func exportArt(forTrack track: Track, type: NSBitmapImageRep.FileType, fileExtension: String) {
        
        let dialog = DialogsAndAlerts.exportMetadataDialog(fileName: track.displayName + "-coverArt",
                                                           fileExtension: fileExtension)
        
        guard dialog.runModal() == .OK, let outFile = dialog.url,
              let image = track.art?.image else {return}
        
        do {
            try image.writeToFile(fileType: type, file: outFile)
            
        } catch {
            
            _ = DialogsAndAlerts.genericErrorAlert("Image file not written", "Unable to export image", error.localizedDescription).showModal()
        }
    }
    
    // MARK: Theming ---------------------------------------------------
    
    func fontSchemeChanged() {
        
        lblNoArt.font = systemFontScheme.normalFont
        tableView.reloadData()
    }
    
    func colorSchemeChanged() {
        
        lblNoArt.textColor = systemColorScheme.primaryTextColor
        tableView.setBackgroundColor(systemColorScheme.backgroundColor)
        tableView.reloadData()
    }
    
    func backgroundColorChanged(_ newColor: PlatformColor) {
        tableView.setBackgroundColor(newColor)
    }
    
    func primaryTextColorChanged(_ newColor: PlatformColor) {
        tableView.reloadAllRows(columns: [1])
    }
    
    func secondaryTextColorChanged(_ newColor: PlatformColor) {
        tableView.reloadAllRows(columns: [0])
    }
}

class CompactPlayerCoverArtTrackInfoViewController: CoverArtTrackInfoViewController {
    
    override var nibName: String? {"CompactPlayerCoverArtTrackInfo"}
}
