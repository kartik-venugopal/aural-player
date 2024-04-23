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

class AudioTrackInfoViewController: TrackInfoKVListViewController {
    
    override var trackInfoSource: TrackInfoSource {
        AudioTrackInfoSource.instance
    }
    
    override func writeHTML(to writer: HTMLWriter) {
//        writer.addTable("Audio:", 3, nil, tableView.htmlTable)
    }
}
