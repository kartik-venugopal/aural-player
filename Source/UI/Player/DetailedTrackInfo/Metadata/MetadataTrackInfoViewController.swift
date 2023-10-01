//
//  MetadataTrackInfoViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class MetadataTrackInfoViewController: NSViewController, TrackInfoViewProtocol {
    
    override var nibName: String? {"MetadataTrackInfo"}
    
    @IBOutlet weak var tableViewDelegate: MetadataTrackInfoViewDelegate!
    
    // The table view that displays the track info
    @IBOutlet weak var tableView: NSTableView! {
        
        didSet {
            tableView.enclosingScrollView?.scrollerInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 1)
        }
    }
    
    // Called each time the popover is shown ... refreshes the data in the table view depending on which track is currently playing
    func refresh(forTrack track: Track) {
        
        tableViewDelegate.displayedTrack = track
        tableView.reloadData()
    }
    
    var jsonObject: AnyObject? {
        tableView.jsonObject
    }
    
    func writeHTML(forTrack track: Track, to writer: HTMLWriter) {
        writer.addTable("Metadata:", 3, nil, tableView.htmlTable)
    }
}
