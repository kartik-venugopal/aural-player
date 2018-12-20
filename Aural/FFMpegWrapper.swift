import Cocoa

class FFMpegWrapper {
    
    static let ffprobeBinaryPath: String = Bundle.main.url(forResource: "ffprobe", withExtension: "")!.path
    static let ffmpegBinaryPath: String = Bundle.main.url(forResource: "ffmpeg", withExtension: "")!.path
    
    static let metadataIgnoreKeys: [String] = ["bitrate"]
    
    static let getMetadata_timeout: Double = 1
    static let getArtwork_timeout: Double = 2
    
    private static var imgCache: [URL: NSImage] = [:]
    
    static func getMetadata(_ track: Track) -> LibAVInfo {
        
        var map: [String: String] = [:]
        var streams: [LibAVStream] = []
        var duration: Double = 0
        var drmProtected: Bool = false
        
        let inputFile = track.file
        let command = Command.createWithOutput(cmd: ffprobeBinaryPath, args: ["-hide_banner", inputFile.path], timeout: getMetadata_timeout, readOutput: false, readErr: true)
        
        let result = CommandExecutor.execute(command)
        
        var foundMetadata: Bool = false
        outerLoop: for line in result.error {
            
            let trimmedLine = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            // Stream
            
            if trimmedLine.hasPrefix("Stream #") {
                
                let tokens = trimmedLine.split(separator: ":")
                
                if tokens.count >= 4 {
                    
                    let streamTypeStr = tokens[2].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let type: LibAVStreamType = streamTypeStr == "Audio" ? .audio : .video
                    
                    let commaSepTokens = tokens[3].split(separator: ",")
                    
                    if commaSepTokens.count > 0 {
                        
                        let format = commaSepTokens[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).split(separator: " ")[0]
                        streams.append(LibAVStream(type, String(format)))
                    }
                }
                
                continue
                
            } else if trimmedLine.hasPrefix("Duration:") {
                
                let commaSepTokens = line.split(separator: ",")
                
                let durKV = commaSepTokens[0]
                let tokens = durKV.split(separator: ":")
                
                if tokens.count >= 4 {
                    
                    let hrsS = tokens[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let minsS = tokens[2]
                    let secsS = tokens[3]
                    
                    let hrs = Double(hrsS) ?? 0, mins = Double(minsS) ?? 0, secs = Double(secsS) ?? 0
                    duration = hrs * 3600 + mins * 60 + secs
                }
                
                continue
                
            } else if trimmedLine.contains("DRM protected stream detected") {
                
                drmProtected = true
                continue
            }
            
            if foundMetadata {
                
                // Split KV entry into key/value
                if let firstColon = trimmedLine.firstIndex(of: ":") {
                    
                    let key = trimmedLine[..<firstColon].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    let colonPlus1 = trimmedLine.index(after: firstColon)
                    let value = trimmedLine[colonPlus1...].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    // Avoid any subsequent Metadata fields
                    if key == "Metadata" {
                        break outerLoop
                    } else if !metadataIgnoreKeys.contains(String(key)) {
                        map[key.lowercased()] = value
                    }
                }
                
            } else if line.contains("Metadata:") {foundMetadata = true}
        }
        
        return LibAVInfo(duration, streams, map, drmProtected)
    }
    
    static func getArtwork(_ track: Track) -> NSImage? {
        return getArtwork(track.file)
    }
    
    static func getArtwork(_ inputFile: URL) -> NSImage? {
        
        if let img = imgCache[inputFile] {
            return img.copy() as! NSImage
        }
        
        let now = Date()
        let imgPath = String(format: "%@-albumArt-%@.jpg", inputFile.path, now.serializableString_hms())
        
        let command = Command.createSimpleCommand(cmd: ffmpegBinaryPath, args: ["-v", "0", "-i", inputFile.path, "-an", "-vcodec", "copy", imgPath], timeout: getArtwork_timeout)
        
        let result = CommandExecutor.execute(command)
        
        var image: NSImage?
        if result.exitCode == 0 {
            
            image = NSImage(contentsOf: URL(fileURLWithPath: imgPath))
            imgCache[inputFile] = image!.copy() as! NSImage
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5, execute: {
                FileSystemUtils.deleteFile(imgPath)
            })
        }
        
        return image
    }
}
