//
// PlayerViewController+SoundUI.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension PlayerViewController: SoundUI {
    
    func volumeChanged(newVolume: Float, displayedVolume: String, muted: Bool) {
        volumeChanged(volume: newVolume, displayedVolume: displayedVolume, muted: muted)
    }
    
    func mutedChanged(newMuted: Bool, volume: Float, displayedVolume: String) {
        volumeChanged(volume: volume, displayedVolume: displayedVolume, muted: newMuted)
    }
    
    // updateSlider should be true if the action was not triggered by the slider in the first place.
    func volumeChanged(volume: Float, displayedVolume: String, muted: Bool, updateSlider: Bool = true, showFeedback: Bool = true) {
        
        if updateSlider {
            volumeSlider.floatValue = volume
        }
        
        lblVolume.stringValue = displayedVolume
        volumeSlider.toolTip = "Volume: \(displayedVolume)" + (muted ? " (muted)" : "")
        
        updateVolumeMuteButtonImage(volume: volume, displayedVolume: displayedVolume, muted: muted)
        
        // Shows and automatically hides the volume label after a preset time interval
        if showFeedback {
            autoHidingVolumeLabel.showView()
        }
    }
    
    func updateVolumeMuteButtonImage(volume: Float, displayedVolume: String, muted: Bool) {

        if muted {
            btnVolume.image = .imgMute
            
        } else {

            // Zero / Low / Medium / High (different images)
            
            switch volume {
                
            case highVolumeRange:
                btnVolume.image = .imgVolumeHigh
                
            case mediumVolumeRange:
                btnVolume.image = .imgVolumeMedium
                
            case lowVolumeRange:
                btnVolume.image = .imgVolumeLow
                
            default:
                btnVolume.image = .imgVolumeZero
            }
        }
        
        volumeSlider.toolTip = "Volume: \(displayedVolume)" + (muted ? " (muted)" : "")
    }
}
