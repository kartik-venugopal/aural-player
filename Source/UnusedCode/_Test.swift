//import Cocoa
//
//class FFMpeg {
//
//    static let ffprobeBinaryPath: String = Bundle.main.url(forResource: "ffprobe", withExtension: "")!.path
//    static let ffmpegBinaryPath: String = Bundle.main.url(forResource: "ffmpeg", withExtension: "")!.path
//
//    static let metadataIgnoreKeys: [String] = ["bitrate"]
//
//    static let getMetadata_timeout: Double = 3
//    static let getArtwork_timeout: Double = 10
//    static let muxer_timeout: Double = 3
//
//    static func getMetadata(_ track: Track) -> LibAVInfo {
//        return getMetadata(track.file)
//    }
//
//    static func getMetadata(_ inputFile: URL) -> LibAVInfo {
//
//        var tags: [String: String] = [:]
//        var streams: [LibAVStream] = []
//        var duration: Double = 0
//        var fileFormatDescription: String?
//
//        // TODO:
//        var drmProtected: Bool = false
//
//        // ffprobe -v error -show_entries "stream=codec_name,codec_type,bit_rate,channels,sample_rate : format=duration :  stream_tags : format_tags" -of json Song.mp3
//
//        let command = Command.createWithOutput(cmd: ffprobeBinaryPath, args: ["-v", "error", "-show_entries", "stream=codec_name,codec_long_name,codec_type,bit_rate,channels,channel_layout,sample_rate:format=duration,format_long_name:stream_tags:format_tags", "-of", "json", inputFile.path], timeout: getMetadata_timeout, readOutput: true, readErr: true, .json)
//
//        let result = CommandExecutor.execute(command)
//
//        if result.exitCode != 0 {
//            return LibAVInfo(0, "", streams, [:], false)
//        }
//
//        if let dict = result.outputAsObject {
//
//            if let streamsArr = dict["streams"] as? [NSDictionary] {
//
//                for streamDict in streamsArr {
//
//                    // Stream info must have type and format. Otherwise, we cannot process it
//                    if var codecType = streamDict["codec_type"] as? String, let codecName = streamDict["codec_name"] as? String {
//
//                        codecType = codecType.lowercased()
//
//                        if codecType == "audio" {
//
//                            // Audio track
//
//                            let codecDescription: String? = streamDict["codec_long_name"] as? String
//
//                            var bitRate: Double?
//                            var channelCount: Int = 0
//                            let channelLayout: String? = streamDict["channel_layout"] as? String
//                            var sampleRate: Double = 0
//
//                            if let bitRateStr = streamDict["bit_rate"] as? String, let num = Double(bitRateStr) {
//                                bitRate = num / 1024
//                            }
//
//                            if let channelCountInt = streamDict["channels"] as? Int {
//                                channelCount = channelCountInt
//                            }
//
//                            if let sampleRateStr = streamDict["sample_rate"] as? String, let rate = Double(sampleRateStr) {
//                                sampleRate = rate
//                            }
//
//                            if let tagsDict = streamDict["tags"] as? [String: String] {
//
//                                for (key, value) in tagsDict {
//                                    tags[key.lowercased()] = value
//                                }
//
//                                // DRM check
//                                if inputFile.lowerCasedExtension.hasPrefix("wma"), let value = tags["asf_protection_type"], value == "DRM" {
//                                    drmProtected = true
//                                }
//                            }
//
//                            streams.append(LibAVStream(codecName.lowercased(), codecDescription, bitRate, channelCount, channelLayout, sampleRate))
//
//                        } else if codecType == "video" {
//
//                            // Art
//                            streams.append(LibAVStream(codecName.lowercased()))
//                        }
//                    }
//                }
//            }
//
//            if let formatDict = dict["format"] as? NSDictionary {
//
//                if let tagsDict = formatDict["tags"] as? [String: String] {
//
//                    for (key, value) in tagsDict {
//                        tags[key.lowercased()] = value
//                    }
//
//                    // DRM check
//                    if inputFile.lowerCasedExtension.hasPrefix("wma"), let value = tags["asf_protection_type"], value == "DRM" {
//                        drmProtected = true
//                    }
//                }
//
//                if let durationStr = formatDict["duration"] as? String, let num = Double(durationStr) {
//                    duration = num
//                }
//
//                fileFormatDescription = formatDict["format_long_name"] as? String
//            }
//        }
//
//        return LibAVInfo(duration, fileFormatDescription, streams, tags, drmProtected)
//    }
//
//    static func transmux(_ inFile: URL, _ outputFile: URL) {
//
//        // -vn: Ignore video stream (including album art)
//        // -sn: Ignore subtitles
//        // -ac 2: Convert to stereo audio (i.e. "downmix")
//        let args = ["-v", "quiet", "-stats", "-i", inFile.path, "-sn", "-acodec", "copy", outputFile.path]
//
//        CommandExecutor.execute(Command.createWithOutput(cmd: ffmpegBinaryPath, args: args, timeout: 1000, readOutput: false, readErr: true, nil))
//    }
//}
//
//let oq = OperationQueue()
//oq.maxConcurrentOperationCount = 12
//
//let dir = URL(fileURLWithPath: "/Users/kven/Test")
//
//ObjectGraph.initialize()
//let muxer = ObjectGraph.muxer
//
//class Recurser {
//
//    static func recurse(_ dir: URL) {
//
//        let files = FileSystemUtils.getContentsOfDirectory(dir)!
//
//        for f in files {
//
//            if FileSystemUtils.isDirectory(f) {
//                recurse(f)
//            } else {
//
//                oq.addOperation {
//
//                    let info = FFMpegWrapper.getMetadata(f)
//
//                    if let stream = info.audioStream {
//
//                        let of = URL(fileURLWithPath: f.path + "-transmuxed.mka")
//                        FFMpeg.transmux(f, of)
//
//                        var path = of.lastPathComponent
//                        var newPath = "/Users/kven/Test/MKA/" + path
//                        FileSystemUtils.renameFile(of, URL(fileURLWithPath: newPath))
//                    }
//                }
//            }
//        }
//    }
//}
//
//Recurser.recurse(dir)
//oq.waitUntilAllOperationsAreFinished()
//
//print("Done !")
//
////
////
////let date = Date()
////let calendar = Calendar.current
////
////let hour = calendar.component(.year, from: date)
////let minutes = calendar.component(.minute, from: date)
////let seconds = calendar.component(.second, from: date)
////print("hours = \(hour):\(minutes):\(seconds)")
////
//
//// ------------- Context-sensitive information tool tip -----------------
//
////let mgr = NSHelpManager.shared()
////mgr.setContextHelp(NSAttributedString.init(string: self.toolTip ?? "ToolTip"), for: self)
////
////let win = self.window!
////let winLoc = event.locationInWindow.applying(CGAffineTransform.init(translationX: win.x, y: win.y))
////
////mgr.showContextHelp(for: self, locationHint: winLoc)
////mgr.removeContextHelp(for: self)
//
//// --------------- Force tool tip to show --------
//
//
////invalidateOldToolTip()
////
////let win = self.window!
//////        let winLoc = event.locationInWindow
////let winLoc = self.convert(event.locationInWindow, from: nil)
//////        let winLoc = event.locationInWindow.applying(CGAffineTransform.init(translationX: win.x, y: win.y))
////self.addToolTip(NSRect(x: winLoc.x, y: winLoc.y, width: 100, height: 30), owner: self.toolTip!, userData: nil)
////}
////
////private func invalidateOldToolTip() {
////
////    // self.removeAllToolTips()
////}
