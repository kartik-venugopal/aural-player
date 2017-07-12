/*
Reads track info from the filesystem
*/

import Cocoa
import AVFoundation

class TrackIO {
    
    // Load track info from specified file
    static func loadTrack(file: NSURL) -> Track? {
        
        let track: Track = Track()
        track.file = file
        
        let sourceAsset = AVURLAsset(URL: file, options: nil)
        track.avAsset = sourceAsset
        track.duration = sourceAsset.duration.seconds

        let metadataList = sourceAsset.commonMetadata
        var title: String?
        var artist: String?
        var art: NSImage?
        
        for item in metadataList {
            
            if item.commonKey == nil || item.value == nil {
                continue
            }
            
            if let key = item.commonKey, let value = item.value {
                
                if key == "title" {
                    if (!Utils.isStringEmpty(item.stringValue)) {
                        title = item.stringValue!
                    }
                    
                } else if key == "artist" {
                    if (!Utils.isStringEmpty(item.stringValue)) {
                        artist = item.stringValue!
                    }
                } else if key == "artwork" {
                    if let artwork = NSImage(data: value as! NSData) {
                        art = artwork
                    }
                }
            }
        }
        
        var shortDisplayName: String = ""
        var longDisplayName: (title: String?, artist: String?)?
        
        if (title != nil) {
            
            if (artist != nil) {
                shortDisplayName = artist! + " - "
                longDisplayName = (title: title!, artist: artist!)
            } else {
                longDisplayName = (title: title!, artist: nil)
            }
            
            shortDisplayName += title!
            
        } else {
            shortDisplayName = (file.URLByDeletingPathExtension?.lastPathComponent)!
            longDisplayName = nil
        }
        
        track.metadata = (title, artist, art)
        track.shortDisplayName = shortDisplayName
        track.longDisplayName = longDisplayName
        
        return track
    }
    
    // (Lazily) load all the information required to play this track
    static func prepareForPlayback(track: Track) {
        
        if (!track.preparedForPlayback) {
            
            var avFile: AVAudioFile? = nil
            do {
                
                avFile = try AVAudioFile(forReading: track.file!)
                track.avFile = avFile!
                track.sampleRate = avFile!.processingFormat.sampleRate
                
                track.frames = avFile!.length
                track.preparedForPlayback = true
                
            } catch let error as NSError {
                print("Error reading track: " + track.file!.path! + ", error=" + error.description)
            }
        }
    }
    
    // (Lazily) load detailed track info, when it is requested by the UI
    static func loadDetailedTrackInfo(track: Track) {
        
        if (track.detailedInfoLoaded) {
            return
        }
        
        var fileAttrLoaded: Bool = false
        var codecDetermined: Bool = false
        var extendedMetadataLoaded: Bool = false
        
        do {
            
            // Playback info is necessary for channel count info
            if (track.avFile == nil) {
                TrackIO.prepareForPlayback(track)
            }
            track.numChannels = Int(track.avFile!.fileFormat.channelCount)
            
            // File size and bit rate
            let filePath = track.file!.path
            let attr : NSDictionary? = try NSFileManager.defaultManager().attributesOfItemAtPath(filePath!)
            
            if let _attr = attr {
                
                let size = Size(sizeBytes: UInt(_attr.fileSize()))
                let bitRate = normalizeBitRate(Double(size.sizeBytes) * 8 / (Double(track.duration!) * Double(Size.KB)))
                track.bitRate = bitRate
                track.size = size
                
                fileAttrLoaded = true
            }
            
        } catch let error as NSError {
            print("Error reading track:" + error.description)
        }
        
        let sourceAsset = track.avAsset!
        
        // Determine codec
        let assetTrack = sourceAsset.tracksWithMediaType(AVMediaTypeAudio)[0]
        
        let desc = CMFormatDescriptionGetMediaSubType(assetTrack.formatDescriptions[0] as! CMFormatDescription)
        var format = codeToString(desc)
        format = format.stringByTrimmingCharactersInSet(NSCharacterSet.init(charactersInString: "."))
        track.format = format
        
        codecDetermined = true
        
        // Retrieve extended metadata (ID3)
        let metadataList = sourceAsset.commonMetadata
        
        for item in metadataList {
            
            if item.commonKey == nil || item.value == nil {
                continue
            }
            
            if let key = item.commonKey {
                
                if (key != "title" && key != "artist" && key != "artwork") {
                    if (!Utils.isStringEmpty(item.stringValue)) {
                        track.extendedMetadata[String(key)] = item.stringValue!
                    }
                }
            }
        }
        
        extendedMetadataLoaded = true
        
        track.detailedInfoLoaded = fileAttrLoaded && codecDetermined && extendedMetadataLoaded
    }
    
    // Normalizes a bit rate by rounding it to the nearest multiple of 32. For ex, a bit rate of 251.5 kbps is rounded to 256 kbps.
    private static func normalizeBitRate(rate: Double) -> Int {
        return Int(round(rate/32)) * 32
    }
    
    // Converts a four character media type code to a readable string
    private static func codeToString(code: FourCharCode) -> String {
        let n = Int(code)
        var s: String = String (UnicodeScalar((n >> 24) & 255))
        s.append(UnicodeScalar((n >> 16) & 255))
        s.append(UnicodeScalar((n >> 8) & 255))
        s.append(UnicodeScalar(n & 255))
        return s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}