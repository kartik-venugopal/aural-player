//
//  MetadataTrackInfoViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class MetadataTrackInfoViewController: NSViewController, TrackInfoViewProtocol {
    
    override var nibName: String? {"MetadataTrackInfo"}
    
    private let trackInfoSource: MetadataTrackInfoSource = .init()
    @IBOutlet weak var tableViewDelegate: TrackInfoViewDelegate! {
        
        didSet {
            tableViewDelegate.trackInfoSource = trackInfoSource
        }
    }
    
    // The table view that displays the track info
    @IBOutlet weak var tableView: NSTableView! {
        
        didSet {
            tableView.enclosingScrollView?.scrollerInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 1)
        }
    }
    
    // Called each time the popover is shown ... refreshes the data in the table view depending on which track is currently playing
    func refresh() {
        
        guard let track = TrackInfoViewContext.displayedTrack else {return}
        trackInfoSource.loadTrackInfo(for: track)
        tableView.reloadData()
    }
    
    var jsonObject: AnyObject? {
        tableView.jsonObject
    }
    
    func writeHTML(to writer: HTMLWriter) {
        writer.addTable("Metadata:", 3, nil, tableView.htmlTable)
    }
    
    // MARK: Theming ---------------------------------------------------
    
    func fontSchemeChanged() {
        tableView.reloadData()
    }
    
    func colorSchemeChanged() {
        
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

class CompactPlayerMetadataTrackInfoViewController: MetadataTrackInfoViewController {
    
    override var nibName: String? {"CompactPlayerMetadataTrackInfo"}
}
