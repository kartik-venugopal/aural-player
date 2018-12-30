import Cocoa

class FFMpegWrapper {
    
    static let ffprobeBinaryPath: String = Bundle.main.url(forResource: "ffprobe", withExtension: "")!.path
    static let ffmpegBinaryPath: String = Bundle.main.url(forResource: "ffmpeg", withExtension: "")!.path
    
    static let metadataIgnoreKeys: [String] = ["bitrate"]
    
    static let getMetadata_timeout: Double = 3
    static let getArtwork_timeout: Double = 10
    
    static let artBaseDir: URL = {
        
        let dir = AppConstants.FilesAndPaths.baseDir.appendingPathComponent("albumArt", isDirectory: true)
        FileSystemUtils.createDirectory(dir)
        return dir
        
    }()
    
    static func getMetadata(_ track: Track) -> LibAVInfo {
        
        var tags: [String: String] = [:]
        var streams: [LibAVStream] = []
        var duration: Double = 0
        
        // TODO:
        var drmProtected: Bool = false
        
        // ./ffprobe -v error -select_streams a:0 -show_entries "stream=codec_name,bit_rate,channels,sample_rate : format=duration,bit_rate : format_tags : stream_tags" -of default=noprint_wrappers=1 Song.mp3
        
        let inputFile = track.file
        let command = Command.createWithOutput(cmd: ffprobeBinaryPath, args: ["-v", "error", "-show_entries", "stream=codec_name,codec_type,bit_rate,channels,sample_rate:format=duration:stream_tags:format_tags", "-of", "json", inputFile.path], timeout: getMetadata_timeout, readOutput: true, readErr: true)
        
        let result = CommandExecutor.execute(command)
        
        if result.exitCode != 0 {
            return LibAVInfo(0, streams, [:], false)
        }
        
        if let dict = result.output {
            
            if let streamsArr = dict["streams"] as? [NSDictionary] {
                
                for streamDict in streamsArr {
                    
                    // Stream info must have type and format. Otherwise, we cannot process it
                    if let typeStr = streamDict["codec_type"] as? String, let codecName = streamDict["codec_name"] as? String {
                        
                        if typeStr == "audio" {
                            
                            // Audio track
                            
                            var bitRate: Double?
                            var channelCount: Int = 2
                            var sampleRate: Double = 44100
                            
                            if let bitRateStr = streamDict["bit_rate"] as? String, let num = Double(bitRateStr) {
                                bitRate = num / 1024
                            }
                            
                            if let channelCountStr = streamDict["channels"] as? String, let count = Int(channelCountStr) {
                                channelCount = count
                            }
                            
                            if let sampleRateStr = streamDict["sample_rate"] as? String, let rate = Double(sampleRateStr) {
                                sampleRate = rate
                            }
                            
                            if let tagsDict = streamDict["tags"] as? [String: String] {
                                
                                for (key, value) in tagsDict {
                                    tags[key.lowercased()] = value
                                }
                                
                                // DRM check
                                if inputFile.pathExtension.lowercased().hasPrefix("wma"), let value = tags["asf_protection_type"], value == "DRM" {
                                    drmProtected = true
                                }
                            }
                            
                            streams.append(LibAVStream(codecName, bitRate, channelCount, sampleRate))
                            
                        } else if typeStr == "video" {
                            
                            // Art
                            streams.append(LibAVStream(codecName))
                        }
                    }
                }
            }
            
            if let formatDict = dict["format"] as? NSDictionary {
                
                if let tagsDict = formatDict["tags"] as? [String: String] {
                    
                    for (key, value) in tagsDict {
                        tags[key.lowercased()] = value
                    }
                    
                    // DRM check
                    if inputFile.pathExtension.lowercased().hasPrefix("wma"), let value = tags["asf_protection_type"], value == "DRM" {
                        drmProtected = true
                    }
                }
                
                if let durationStr = formatDict["duration"] as? String, let num = Double(durationStr) {
                    duration = num
                }
            }
        }
        
        return LibAVInfo(duration, streams, tags, drmProtected)
    }
    
    static func getArt(_ track: Track) -> NSImage? {
        return getArt(track.file)
    }
    
    static func getArt(_ inputFile: URL) -> NSImage? {
        
        let now = Date()
        let imgPath = String(format: "%@-albumArt-%@.jpg", artBaseDir.appendingPathComponent(inputFile.lastPathComponent).path, now.serializableString_hms())
        
        let command = Command.createSimpleCommand(cmd: ffmpegBinaryPath, args: ["-v", "0", "-i", inputFile.path, "-an", "-vcodec", "copy", imgPath], timeout: getArtwork_timeout)
        
        let result = CommandExecutor.execute(command)
        
        var image: NSImage?
        if result.exitCode == 0 {
            
            print("SUCCESS art for", inputFile.lastPathComponent)
            
            image = NSImage(contentsOf: URL(fileURLWithPath: imgPath))

            DispatchQueue.global(qos: .background).async {
                FileSystemUtils.deleteFile(imgPath)
            }
        } else {
            print("FAILED art for", inputFile.lastPathComponent)
        }
        
        return image
    }
}
