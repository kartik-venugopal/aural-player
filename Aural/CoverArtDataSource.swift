import Cocoa

/*
 Data source and delegate for the Detailed Track Info popover view
 */
class CoverArtDataSource: TrackInfoDataSource {
    
    override var tableId: TrackInfoTab {return .audio}
    
    override func awakeFromNib() {
        
        // Store a reference to trackInfoView that is easily accessible
        TrackInfoViewHolder.tablesMap[.coverArt] = table
    }
    
    override func infoForTrack(_ track: Track) -> [(key: String, value: String)] {
        
        let imgData = track.displayInfo.art?.tiffRepresentation as! NSData
        if let info = ParserUtils.getImageMetadata(imgData) {
        
        for (k, v) in info {
            print(k, v)
        }
        }
        
        var trackInfo: [(key: String, value: String)] = []
        
//        trackInfo.append((key: "Format", value: track.audioInfo?.format?.capitalizingFirstLetter() ?? value_unknown))
//
//        if let codec = track.audioInfo?.codec {
//            trackInfo.append((key: "Codec", value: codec))
//        }
//
//        trackInfo.append((key: "Track Duration", value: StringUtils.formatSecondsToHMS(track.duration)))
//        trackInfo.append((key: "Bit Rate", value: String(format: "%d kbps", track.audioInfo?.bitRate ?? value_unknown)))
//
//        trackInfo.append((key: "Sample Rate", value: track.playbackInfo?.sampleRate != nil ? String(format: "%@ Hz", StringUtils.readableLongInteger(Int64(track.playbackInfo!.sampleRate!))) : value_unknown))
//
//        if let layout = track.audioInfo?.channelLayout {
//            trackInfo.append((key: "Channel Layout", value: layout.capitalized))
//        } else {
//            trackInfo.append((key: "Channel Layout", value: track.playbackInfo?.numChannels != nil ? channelLayout(track.playbackInfo!.numChannels!) : value_unknown))
//        }
//
//        trackInfo.append((key: "Frames", value: track.playbackInfo?.frames != nil ? StringUtils.readableLongInteger(track.playbackInfo!.frames!) : value_unknown))
        
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
