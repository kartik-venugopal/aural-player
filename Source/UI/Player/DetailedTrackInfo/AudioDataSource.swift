import Cocoa

/*
 Data source and delegate for the Detailed Track Info popover view
 */
class AudioDataSource: TrackInfoDataSource {
    
    override var tableId: TrackInfoTab {return .audio}
    
    override func infoForTrack(_ track: Track) -> [(key: String, value: String)] {
        
        // TODO: Should use track.audioInfo here ... not playbackInfo.
        
        var trackInfo: [(key: String, value: String)] = []
        
//        trackInfo.append((key: "Format", value: track.audioInfo?.format?.capitalizingFirstLetter() ?? value_unknown))
//        trackInfo.append((key: "Codec", value: track.audioInfo?.codec ?? value_unknown))
//        
//        trackInfo.append((key: "Track Duration", value: ValueFormatter.formatSecondsToHMS(track.duration)))
//        
//        if let bitRate = track.audioInfo?.bitRate {
//            trackInfo.append((key: "Bit Rate", value: String(format: "%d kbps", bitRate)))
//        } else {
//            trackInfo.append((key: "Bit Rate", value: value_unknown))
//        }
//
//        if let sampleRate = track.playbackInfo?.sampleRate {
//            trackInfo.append((key: "Sample Rate", value: String(format: "%@ Hz", ValueFormatter.readableLongInteger(Int64(sampleRate)))))
//        } else {
//            trackInfo.append((key: "Sample Rate", value: value_unknown))
//        }
//        
//        if let layout = track.audioInfo?.channelLayout {
//            trackInfo.append((key: "Channel Layout", value: layout.capitalized))
//        } else {
//            
//            if let numChannels = track.playbackInfo?.numChannels {
//                trackInfo.append((key: "Channel Layout", value: channelLayout(numChannels)))
//            } else {
//                trackInfo.append((key: "Channel Layout", value: value_unknown))
//            }
//        }
//        
//        // TODO: If playback info is present (prepared for playback), frame count is exact. Otherwise, it is an estimate.
//        // If it's an estimate, note it in the caption, i.e. "Frames (estimated)", OR actually calculate it.
//        if let frameCount = track.playbackInfo?.frames {
//            trackInfo.append((key: "Frames", value: ValueFormatter.readableLongInteger(frameCount)))
//        } else {
//            trackInfo.append((key: "Frames", value: value_unknown))
//        }
        
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
