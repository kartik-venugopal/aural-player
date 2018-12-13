import Cocoa

class LibAVWrapper {
    
    static let avConvBinaryPath: String? = Bundle.main.url(forResource: "avconv", withExtension: "")?.path
    
    static let metadataIgnoreKeys: [String] = ["Stream #0.0", "Stream #0.1", "Stream #0.2", "bitrate"]
    
    static func transcode(_ inputFile: URL) -> URL? {
        
        if let binaryPath = avConvBinaryPath {
            
            let outputFile = URL(fileURLWithPath: inputFile.path + "-transcoded.mp3")
            _ = runCommand(cmd: binaryPath, args: "-i", inputFile.path, outputFile.path)
            
            return outputFile
        }
        
        return nil
    }
    
    static func getMetadata(_ inputFile: URL) -> [String: String] {
        
        var map: [String: String] = [:]
        
        if let binaryPath = avConvBinaryPath {
            
            let cmdOutput = runCommand(cmd: binaryPath, args: "-i", inputFile.path)
            
            var foundMetadata: Bool = false
            for line in cmdOutput.error {
                
                if foundMetadata {
                    
                    // Split line using comma as a delim
                    let commaSepTokens = line.split(separator: ",")
                    for token in commaSepTokens {
                        
                        // Split KV entry into key/value
                        if let firstColon = token.firstIndex(of: ":") {
                            
                            let key = token[..<firstColon].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                            
                            let colonPlus1 = token.index(after: firstColon)
                            let value = token[colonPlus1...].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                            
                            // Avoid any subsequent Metadata fields
                            if key == "Metadata" {
                                return map
                            } else if !metadataIgnoreKeys.contains(key) {
                                map[key.lowercased()] = value
                            }
                        }
                    }
                    
                } else if line.contains("Metadata:") {foundMetadata = true}
            }
        }
        
        return map
    }
    
    static func getArtwork(_ inputFile: URL) -> NSImage? {
        
        if let binaryPath = avConvBinaryPath {
            
            let imgPath = inputFile.path + "-albumArt.jpg"
            let cmdOutput = runCommand(cmd: binaryPath, args: "-i", inputFile.path, "-an", "-vcodec", "copy", imgPath)
            if cmdOutput.exitCode == 0 {
                return NSImage(contentsOf: URL(fileURLWithPath: imgPath))
            }
        }
        
        return nil
    }
    
    private static func runCommand(cmd : String, args : String...) -> (output: [String], error: [String], exitCode: Int32) {
        
        var output : [String] = []
        var error : [String] = []
        
        let task = Process()
        task.launchPath = cmd
        task.arguments = args
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launch()
        
        task.waitUntilExit()
        let status = task.terminationStatus
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            error = string.components(separatedBy: "\n")
        }
        
        return (output, error, status)
    }
    
}
