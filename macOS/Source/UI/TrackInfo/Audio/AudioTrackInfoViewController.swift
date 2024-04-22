//
//  AudioTrackInfoViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class AudioTrackInfoViewController: NSViewController, TrackInfoViewProtocol {
    
    override var nibName: String? {"AudioTrackInfo"}
    
    // The table view that displays the track info
    @IBOutlet weak var tableView: NSTableView!
    
    private let trackInfoSource: AudioTrackInfoSource = .init()
    @IBOutlet weak var tableViewDelegate: TrackInfoViewDelegate! {
        
        didSet {
            tableViewDelegate.trackInfoSource = trackInfoSource
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
        writer.addTable("Audio:", 3, nil, tableView.htmlTable)
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

class CompactPlayerAudioTrackInfoViewController: AudioTrackInfoViewController {
    
    override var nibName: String? {"CompactPlayerAudioTrackInfo"}
}
