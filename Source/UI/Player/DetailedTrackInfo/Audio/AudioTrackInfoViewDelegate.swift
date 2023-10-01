//
//  AudioTrackInfoViewDelegate.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Data source and delegate for the Detailed Track Info popover view
 */
class AudioTrackInfoViewDelegate: TrackInfoViewDelegate {
    
    override func infoForTrack(_ track: Track) -> [KeyValuePair] {
        
        var trackInfo: [KeyValuePair] = []
        
        trackInfo.append(KeyValuePair(key: "Format",
                                      value: track.audioInfo?.format?.capitalizingFirstLetter() ?? value_unknown))
        
        if let codec = track.audioInfo?.codec {
            trackInfo.append(KeyValuePair(key: "Codec", value: codec))
        }
        
        trackInfo.append(KeyValuePair(key: "Duration",
                                      value: ValueFormatter.formatSecondsToHMS(track.duration)))
        
        if let bitRate = track.audioInfo?.bitRate {
            
            if bitRate < 1000 {
                trackInfo.append(KeyValuePair(key: "Bit Rate",
                                              value: String(format: "%d kbps", bitRate)))
            } else {
                trackInfo.append(KeyValuePair(key: "Bit Rate",
                                              value: String(format: "%@ kbps", ValueFormatter.readableLongInteger(Int64(bitRate)))))
            }
            
        } else {
            trackInfo.append(KeyValuePair(key: "Bit Rate", value: value_unknown))
        }

        if let sampleRate = track.audioInfo?.sampleRate {
            
            trackInfo.append(KeyValuePair(key: "Sample Rate",
                                          value: String(format: "%@ Hz", ValueFormatter.readableLongInteger(Int64(sampleRate)))))
            
        } else {
            trackInfo.append(KeyValuePair(key: "Sample Rate", value: value_unknown))
        }
        
        if let sampleFormat = track.audioInfo?.sampleFormat {
            trackInfo.append(KeyValuePair(key: "Sample Format", value: sampleFormat))
        }
        
        if let layout = track.audioInfo?.channelLayout {
            trackInfo.append(KeyValuePair(key: "Channel Layout", value: layout.capitalized))
        } else {
            
            if let numChannels = track.audioInfo?.numChannels {
                
                trackInfo.append(KeyValuePair(key: "Channel Layout",
                                              value: channelLayout(numChannels)))
            } else {
                trackInfo.append(KeyValuePair(key: "Channel Layout", value: value_unknown))
            }
        }
        
        if let frameCount = track.audioInfo?.frames {
            
            trackInfo.append(KeyValuePair(key: "Frames",
                                          value: ValueFormatter.readableLongInteger(frameCount)))
        } else {
            trackInfo.append(KeyValuePair(key: "Frames", value: value_unknown))
        }
        
        return trackInfo
    }
    
    private func channelLayout(_ numChannels: Int) -> String {
        
        switch numChannels {
            
        case 1: return "Mono (1 ch)"
            
        case 2: return "Stereo (2 ch)"
            
        case 6: return "5.1 (6 ch)"
            
        case 8: return "7.1 (8 ch)"
            
        case 10: return "9.1 (10 ch)"
            
        default: return String(format: "%d channels", numChannels)
            
        }
    }
}
