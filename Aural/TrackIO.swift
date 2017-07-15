/*
Reads track info from the filesystem
*/

import Cocoa
import AVFoundation

class TrackIO {
    
    // Load track info from specified file
    static func loadTrack(_ file: URL) -> Track? {
        
        let track: Track = Track()
        track.file = file
        
        let sourceAsset = AVURLAsset(url: file, options: nil)
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
                    if let artwork = NSImage(data: value as! Data) {
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
            shortDisplayName = (file.deletingPathExtension().lastPathComponent)
            longDisplayName = nil
        }
        
        track.metadata = (title, artist, art)
        track.shortDisplayName = shortDisplayName
        track.longDisplayName = longDisplayName
        
        return track
    }
    
    // (Lazily) load all the information required to play this track
    static func prepareForPlayback(_ track: Track) {
        
        if (!track.preparedForPlayback) {
            
            var avFile: AVAudioFile? = nil
            do {
                
                avFile = try AVAudioFile(forReading: track.file! as URL)
                track.avFile = avFile!
                track.sampleRate = avFile!.processingFormat.sampleRate
                
                track.frames = avFile!.length
                track.preparedForPlayback = true
                
            } catch let error as NSError {
                NSLog("Error reading track '%@': %@", track.file!.path, error.description)
            }
        }
    }
    
    // (Lazily) load detailed track info, when it is requested by the UI
    static func loadDetailedTrackInfo(_ track: Track) {
        
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
            let attr : NSDictionary? = try FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary
            
            if let _attr = attr {
                
                let size = Size(sizeBytes: UInt(_attr.fileSize()))
                let bitRate = normalizeBitRate(Double(size.sizeBytes) * 8 / (Double(track.duration!) * Double(Size.KB)))
                track.bitRate = bitRate
                track.size = size
                
                fileAttrLoaded = true
            }
            
        } catch let error as NSError {
            NSLog("Error reading track '%@': %@", track.file!.path, error.description)
        }
        
        let sourceAsset = track.avAsset!
        
        // Determine codec
        let assetTrack = sourceAsset.tracks(withMediaType: AVMediaTypeAudio)[0]
        
        let desc = CMFormatDescriptionGetMediaSubType(assetTrack.formatDescriptions[0] as! CMFormatDescription)
        var format = codeToString(desc)
        format = format.trimmingCharacters(in: CharacterSet.init(charactersIn: "."))
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
    fileprivate static func normalizeBitRate(_ rate: Double) -> Int {
        return Int(round(rate/32)) * 32
    }
    
    // Converts a four character media type code to a readable string
    fileprivate static func codeToString(_ code: FourCharCode) -> String {
        let n = Int(code)
        var s: String = String (describing: UnicodeScalar((n >> 24) & 255))
        s.append(String(describing: UnicodeScalar((n >> 16) & 255)))
        s.append(String(describing: UnicodeScalar((n >> 8) & 255)))
        s.append(String(describing: UnicodeScalar(n & 255)))
        return s.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
