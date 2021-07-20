//
//  CoverArtTrackInfoViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
    
    @IBOutlet weak var tableViewDelegate: CoverArtTrackInfoViewDelegate!
    
    // Called each time the popover is shown ... refreshes the data in the table view depending on which track is currently playing
    func refresh(forTrack track: Track) {

        artView?.image = track.art?.image
        lblNoArt.showIf(artView?.image == nil)
        
        tableViewDelegate.displayedTrack = track
        tableView.reloadData()
    }
    
    func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
    
        artView?.image = notification.updatedTrack.art?.image
        lblNoArt.showIf(artView?.image == nil)
        tableView.reloadData()
    }
    
    var jsonObject: AnyObject {
        tableView.jsonObject
    }
    
    func writeHTML(forTrack track: Track, to writer: HTMLWriter) {
        
        // Embed art in HTML
        if let image = track.art?.image, let bits = image.representations.first as? NSBitmapImageRep,
           let data = bits.representation(using: .jpeg, properties: [:]) {
            
            let outFile = writer.outputFile
            let imgFile = outFile.parentDir.appendingPathComponent(track.displayName + "-coverArt.jpg", isDirectory: false)
            
            do {
                
                try data.write(to: imgFile)
            } catch {}
            
            writer.addImage(imgFile.lastPathComponent, "(Cover Art)")
            
            // TODO: What about image metadata ?
        }
    }
    
    func exportArt(forTrack track: Track, type: NSBitmapImageRep.FileType, fileExtension: String) {
        
        let dialog = DialogsAndAlerts.exportMetadataDialog(fileName: track.displayName + "-coverArt", fileExtension: fileExtension)
        
        if dialog.runModal() == .OK, let outFile = dialog.url, let image = track.art?.image {
                
            do {
                try image.writeToFile(fileType: type, file: outFile)
                
            } catch {
                
                _ = DialogsAndAlerts.genericErrorAlert("Image file not written", "Unable to export image", error.localizedDescription).showModal()
            }
        }
    }
}
