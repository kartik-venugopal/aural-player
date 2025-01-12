//
//  AudioTrackInfoSource.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 Data source and delegate for the Detailed Track Info popover view
 */
class AudioTrackInfoSource: TrackInfoSource {
    
    private(set) var trackInfo: [KeyValuePair] = []
    
    static let instance: AudioTrackInfoSource = .init()
    
    private init() {}
    
    func loadTrackInfo(for track: Track) {
        
        trackInfo.removeAll()
        
        let audioInfo = track.audioInfo
        
        trackInfo.append(KeyValuePair(key: "Format",
                                      value: audioInfo.format?.capitalizingFirstLetter() ?? TrackInfoConstants.value_unknown))
        
        if let codec = audioInfo.codec {
            trackInfo.append(KeyValuePair(key: "Codec", value: codec))
        }
        
        trackInfo.append(KeyValuePair(key: "Duration",
                                      value: ValueFormatter.formatSecondsToHMS(track.duration)))
        
        if let bitRate = audioInfo.bitRate {
            
            if bitRate < 1000 {
                trackInfo.append(KeyValuePair(key: "Bit Rate",
                                              value: String(format: "%d kbps", bitRate)))
            } else {
                trackInfo.append(KeyValuePair(key: "Bit Rate",
                                              value: String(format: "%@ kbps", ValueFormatter.readableLongInteger(Int64(bitRate)))))
            }
            
        } else {
            trackInfo.append(KeyValuePair(key: "Bit Rate", value: TrackInfoConstants.value_unknown))
        }
        
        if let sampleRate = audioInfo.sampleRate {
            
            trackInfo.append(KeyValuePair(key: "Sample Rate",
                                          value: String(format: "%@ Hz", ValueFormatter.readableLongInteger(Int64(sampleRate)))))
            
        } else {
            trackInfo.append(KeyValuePair(key: "Sample Rate", value: TrackInfoConstants.value_unknown))
        }
        
        if let sampleFormat = audioInfo.sampleFormat {
            trackInfo.append(KeyValuePair(key: "Sample Format", value: sampleFormat))
        }
        
        if let layout = audioInfo.channelLayout {
            trackInfo.append(KeyValuePair(key: "Channel Layout", value: layout.capitalized))
        } else {
            
            if let numChannels = audioInfo.numChannels {
                
                trackInfo.append(KeyValuePair(key: "Channel Layout",
                                              value: channelLayout(numChannels)))
            } else {
                trackInfo.append(KeyValuePair(key: "Channel Layout", value: TrackInfoConstants.value_unknown))
            }
        }
        
        if let frameCount = audioInfo.frames {
            
            trackInfo.append(KeyValuePair(key: "Frames",
                                          value: ValueFormatter.readableLongInteger(frameCount)))
        } else {
            trackInfo.append(KeyValuePair(key: "Frames", value: TrackInfoConstants.value_unknown))
        }
        
        if let replayGain = audioInfo.replayGainFromMetadata {
            
            trackInfo.append(KeyValuePair(key: "Replay Gain (from metadata)",
                                          value: replayGainString(for: replayGain)))
        }
        
        if let replayGain = audioInfo.replayGainFromAnalysis {
            
            trackInfo.append(KeyValuePair(key: "Replay Gain (from analysis)",
                                          value: replayGainString(for: replayGain)))
        }
    }
    
    private func replayGainString(for replayGain: ReplayGain) -> String {
        
        var lines: [String] = []
        
        if let trackGain = replayGain.trackGain {
            lines.append("Track gain: \(String(format: "%.2f dB", trackGain))")
        }
        
        if let trackPeak = replayGain.trackPeak {
            lines.append("Track peak: \(String(format: "%.2f", trackPeak))")
        }
        
        if let albumGain = replayGain.albumGain {
            lines.append("Album gain: \(String(format: "%.2f dB", albumGain))")
        }
        
        if let albumPeak = replayGain.albumPeak {
            lines.append("Album peak: \(String(format: "%.2f", albumPeak))")
        }
        
        return lines.joined(separator: "\n")
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
