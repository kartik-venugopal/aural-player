import Cocoa

class LibAVWrapper {
    
    static let avConvBinaryPath: String? = Bundle.main.url(forResource: "avconv", withExtension: "")?.path
    
    static let metadataIgnoreKeys: [String] = ["bitrate"]
    
    static let getMetadata_timeout: Double = 1
    static let getArtwork_timeout: Double = 2
    
    private static var runningTask: Process?
    
    static func cancelTask() {
        
        runningTask?.terminate()
        runningTask = nil
    }
    
    static func transcode(_ inputFile: URL, _ outputFile: URL, _ progressCallback: @escaping ((_ output: String) -> Void)) -> Bool {
        
        if let binaryPath = avConvBinaryPath {
            
            // -vn: Ignore video stream (including album art)
            // -sn: Ignore subtitles
            // -ac 2: Convert to stereo audio
            let result = runCommand(cmd: binaryPath, timeout: nil, callback: progressCallback, readOutput: false, readErr: false, args: "-i", inputFile.path, "-vn", "-sn", "-ac", "2" , outputFile.path)
            return result.exitCode == 0
        }
        
        return false
    }
    
    static func getMetadata(_ inputFile: URL) -> LibAVInfo {
        
        var map: [String: String] = [:]
        var streams: [LibAVStream] = []
        var duration: Double = 0
        
        if let binaryPath = avConvBinaryPath {

            let tim = TimerUtils.start("getMetadata")
            let cmdOutput = runCommand(cmd: binaryPath, timeout: getMetadata_timeout, callback: nil, readOutput: false, readErr: true, args: "-i", inputFile.path)
            tim.end()
            
            var foundMetadata: Bool = false
            outerLoop: for line in cmdOutput.error {
                
                let trimmedLine = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                // Stream
                
                if trimmedLine.hasPrefix("Stream #") {
                    
                    let tokens = trimmedLine.split(separator: ":")
                    
                    if tokens.count >= 3 {
                        
                        let streamTypeStr = tokens[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        let type: LibAVStreamType = streamTypeStr == "Audio" ? .audio : .video
                        
                        let commaSepTokens = tokens[2].split(separator: ",")
                        
                        if commaSepTokens.count > 0 {
                            let format = commaSepTokens[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                            streams.append(LibAVStream(type, format))
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
        }
        
        return LibAVInfo(duration, streams, map)
    }
    
    static func getArtwork(_ inputFile: URL) -> NSImage? {
        
        if let binaryPath = avConvBinaryPath {
            
            let now = Date()
            let imgPath = String(format: "%@-albumArt-%@.jpg", inputFile.path, now.serializableString_hms())
            
            let tim = TimerUtils.start("getArtwork")
            let cmdOutput = runCommand(cmd: binaryPath, timeout: getArtwork_timeout, callback: nil, readOutput: false, readErr: false, args: "-i", inputFile.path, "-an", "-vcodec", "copy", imgPath)
            tim.end()
            
            if cmdOutput.exitCode == 0 {
                return NSImage(contentsOf: URL(fileURLWithPath: imgPath))
            }
        }
        
        return nil
    }
    
    private static func runCommand(cmd : String, timeout: Double?, callback: ((_ output: String) -> Void)?, readOutput: Bool, readErr: Bool, args : String...) -> (output: [String], error: [String], exitCode: Int32) {
        
        var output : [String] = []
        var error : [String] = []
        
        let task = Process()
        task.launchPath = cmd
        task.arguments = args
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        
        let errpipe = Pipe()
        task.standardError = errpipe
        
        if let callback = callback {
            registerCallbackForPipe(outpipe, callback, task)
            registerCallbackForPipe(errpipe, callback, task)
        }

        runningTask = task
        task.launch()

        // End task after timeout interval
        if let timeout = timeout {
            
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + timeout, execute: {
                task.terminate()
            })
        }
        
        task.waitUntilExit()
        
        if runningTask == nil {
            // Task may have been canceled
            return (output, error, -1)
        }
        
        let status = task.terminationStatus
        
        // TODO: Don't always read this stuff
        
        if readOutput {
            
            let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
            if var string = String(data: outdata, encoding: .utf8) {
                string = string.trimmingCharacters(in: .newlines)
                output = string.components(separatedBy: "\n")
            }
        }
        
        if readErr {
            
            let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
            if var string = String(data: errdata, encoding: .utf8) {
                string = string.trimmingCharacters(in: .newlines)
                error = string.components(separatedBy: "\n")
            }
        }
        
        return (output, error, status)
    }
    
    private static func registerCallbackForPipe(_ pipe: Pipe, _ callback: @escaping ((_ output: String) -> Void), _ task: Process) {
        
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: pipe.fileHandleForReading , queue: nil) {
            notification in
            
            let output = pipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            callback(outputString)
            
            if task.isRunning {
                pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            }
        }
    }
}
