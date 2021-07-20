//
//  AudioTrackInfoViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class AudioTrackInfoViewController: NSViewController, TrackInfoViewProtocol {
    
    override var nibName: String? {"AudioTrackInfo"}
    
    // The table view that displays the track info
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var tableViewDelegate: AudioTrackInfoViewDelegate!
    
    // Called each time the popover is shown ... refreshes the data in the table view depending on which track is currently playing
    func refresh(forTrack track: Track) {
        
        tableViewDelegate.displayedTrack = track
        tableView.reloadData()
    }
    
    var jsonObject: AnyObject? {
        tableView.jsonObject
    }
    
    func writeHTML(forTrack track: Track, to writer: HTMLWriter) {
        writer.addTable("Audio:", 3, nil, tableView.htmlTable)
    }
}
