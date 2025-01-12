//
//  MetadataTrackInfoViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class MetadataTrackInfoViewController: TrackInfoKVListViewController {
    
    override var trackInfoSource: TrackInfoSource {
        MetadataTrackInfoSource.instance
    }
    
    override var htmlTableName: String {"Metadata"}
    
    // Constructs the formatted "rich" text to be displayed in the text view
    override func update() {
        
        guard appModeManager.currentMode == .compact else {
            
            super.update()
            return
        }
        
        // First, clear the view to remove any old text
        textView.string = ""
        
        // In Compact mode, there is no caption label, so start with the track title/artist string up top
        if let track = TrackInfoViewContext.displayedTrack {
            
            let titleAndArtist = track.titleAndArtist
            let trackDisplayString: NSMutableAttributedString
            
            if let artist = titleAndArtist.artist {
                
                trackDisplayString = "\(artist) ".attributed(font: systemFontScheme.prominentFont, color: systemColorScheme.secondaryTextColor) + ("\(titleAndArtist.title)\n").attributed(font: systemFontScheme.prominentFont, color: systemColorScheme.primaryTextColor)
                
            } else {
                trackDisplayString = ("\(titleAndArtist.title)\n").attributed(font: systemFontScheme.prominentFont, color: systemColorScheme.primaryTextColor)
            }
            
            textView.textStorage?.append(trackDisplayString)
        }
        
        for (key, value) in trackInfoSource.trackInfo {
            
            appendString(text: key, font: systemFontScheme.normalFont, color: systemColorScheme.secondaryTextColor, lineSpacing: 20)
            appendString(text: value, font: systemFontScheme.normalFont, color: systemColorScheme.primaryTextColor, lineSpacing: 5)
        }
    }
}
