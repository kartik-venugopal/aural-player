//
//  CoverArtTrackInfoViewDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Data source and delegate for the Detailed Track Info popover view
 */
class CoverArtTrackInfoViewDelegate: TrackInfoViewDelegate {
    
    override var tableId: TrackInfoTab {.coverArt}
    
    override func infoForTrack(_ track: Track) -> [KeyValuePair] {
        
        guard let artInfo = track.art?.metadata else {return []}
        
        var trackInfo: [KeyValuePair] = []
        
        if let type = artInfo.type {
            trackInfo.append((key: "Type", value: type))
        }
        
        if let dimensions = artInfo.dimensions {
            
            let dimStr = String(format: "%.0f x %.0f", round(dimensions.width), round(dimensions.height))
            trackInfo.append((key: "Dimensions", value: dimStr))
        }
        
        if let resolution = artInfo.resolution {
            
            let resStr = String(format: "%.0f x %.0f DPI", round(resolution.width), round(resolution.height))
            trackInfo.append((key: "Resolution", value: resStr))
        }
        
        if let colorSpace = artInfo.colorSpace {
            trackInfo.append((key: "Color Space", value: colorSpace))
        }
        
        if let colorProfile = artInfo.colorProfile {
            trackInfo.append((key: "Color Profile", value: colorProfile))
        }
        
        if let bitDepth = artInfo.bitDepth {
            trackInfo.append((key: "Bit Depth", value: String(format: "%d-bit", bitDepth)))
        }
        
        if let hasAlpha = artInfo.hasAlpha {
            trackInfo.append((key: "Has Alpha?", value: hasAlpha ? "Yes" : "No"))
        }
        
        return trackInfo
    }
}
