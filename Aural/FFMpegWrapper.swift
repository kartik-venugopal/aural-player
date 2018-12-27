import Cocoa

class FFMpegWrapper {
    
    static let ffprobeBinaryPath: String = Bundle.main.url(forResource: "ffprobe", withExtension: "")!.path
    static let ffmpegBinaryPath: String = Bundle.main.url(forResource: "ffmpeg", withExtension: "")!.path
    
    static let metadataIgnoreKeys: [String] = ["bitrate"]
    
    static let getMetadata_timeout: Double = 3
    static let getArtwork_timeout: Double = 10
    
    static func getMetadata(_ track: Track) -> LibAVInfo {
        
        var map: [String: String] = [:]
        var stream: LibAVStream?
        var duration: Double = 0
        
        // TODO:
        var drmProtected: Bool = false
        
        // ./ffprobe -v error -select_streams a:0 -show_entries "stream=codec_name,bit_rate,channels,sample_rate : format=duration : format_tags" -of default=noprint_wrappers=1 Song.mp3
        
        let inputFile = track.file
        let command = Command.createWithOutput(cmd: ffprobeBinaryPath, args: ["-v", "error", "-select_streams", "a:0", "-show_entries", "stream=codec_name,bit_rate,channels,sample_rate:format=duration:stream_tags:format_tags", "-of", "default=noprint_wrappers=1", inputFile.path], timeout: getMetadata_timeout, readOutput: true, readErr: true)
        
        let result = CommandExecutor.execute(command)
        
        if result.exitCode != 0 {
            return LibAVInfo(0, nil, [:], false)
        }
        
        for line in result.output {
            
            // Split the line into key and value
            
            let trimmedLine = line.trim()
            if trimmedLine.isEmpty {continue}
            
            let tokens = trimmedLine.split(separator: "=")
            if tokens.count < 2 {continue}
            
            let key = tokens[0].trim()
            let value = tokens[1].trim()
            
            // Put metadata in the map
            
            if key.hasPrefix("TAG:") {
                
                let kvTokens = key.split(separator: ":")
                if kvTokens.count >= 2 {
                    map[kvTokens[1].lowercased()] = value
                }
                
            } else {
                map[key.lowercased()] = value
            }
        }
        
        var format: String?
        var bitRate: Double?
        var channelCount: Int = 2
        var sampleRate: Double = 44100
        
        if let codecName = map.removeValue(forKey: "codec_name") {
            format = codecName
        }
        
        if let bitRateStr = map.removeValue(forKey: "bit_rate"), let num = Double(bitRateStr) {
            bitRate = num / 1024
        }
        
        if let channelCountStr = map.removeValue(forKey: "channels"), let count = Int(channelCountStr) {
            channelCount = count
        }
        
        if let sampleRateStr = map.removeValue(forKey: "sample_rate"), let rate = Double(sampleRateStr) {
            sampleRate = rate
        }
        
        if let durationStr = map.removeValue(forKey: "duration"), let num = Double(durationStr) {
            duration = num
        }
        
        if inputFile.pathExtension.lowercased().hasPrefix("wma"), let value = map["asf_protection_type"], value == "DRM" {
            drmProtected = true
        }
        
        if format != nil {
            stream = LibAVStream(format!, bitRate, channelCount, sampleRate)
        }
        
        return LibAVInfo(duration, stream, map, drmProtected)
    }
    
    static func getArt(_ track: Track) -> NSImage? {
        return getArt(track.file)
    }
    
    static func getArt(_ inputFile: URL) -> NSImage? {
        
        let now = Date()
        let imgPath = String(format: "%@-albumArt-%@.jpg", inputFile.path, now.serializableString_hms())
        
        let command = Command.createSimpleCommand(cmd: ffmpegBinaryPath, args: ["-v", "0", "-i", inputFile.path, "-an", "-vcodec", "copy", imgPath], timeout: getArtwork_timeout)
        
        let result = CommandExecutor.execute(command)
        
        var image: NSImage?
        if result.exitCode == 0 {
            
            image = NSImage(contentsOf: URL(fileURLWithPath: imgPath))

            DispatchQueue.global(qos: .background).async {
                FileSystemUtils.deleteFile(imgPath)
            }
        }
        
        return image
    }
}
