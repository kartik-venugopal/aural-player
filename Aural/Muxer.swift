import Foundation

class Muxer: MuxerProtocol {
    
    private let containers: [String: String] = ["aac": "m4a", "dts": "mka"]
    
    private let baseDir = AppConstants.FilesAndPaths.baseDir.appendingPathComponent("transcoderStore", isDirectory: true)
    
    func trackNeedsMuxing(_ track: Track) -> Bool {
        
        let inFileExt = track.file.pathExtension.lowercased()
        return containers[inFileExt] != nil
    }
    
    func muxForDuration(_ track: Track) -> Double? {
        
        let inFileExt = track.file.pathExtension.lowercased()
        
        var duration: Double? = nil
        
        if let outFileExt = containers[inFileExt] {
            
            let inputFileName = track.file.lastPathComponent
            let nowString = Date().serializableString_hms()
            let randomNum = Int.random(in: 0..<Int.max)
            let outputFileName = String(format: "%@-muxed-%@-%d.%@", inputFileName, nowString, randomNum, outFileExt)
            let outFile = baseDir.appendingPathComponent(outputFileName, isDirectory: false)
         
            let cmd = FFMpegWrapper.createMuxerCommand(track.file, outFile)
            let result = CommandExecutor.execute(cmd)
            
            if result.exitCode == 0 {
                
                if let line = result.error.last, line.contains("time=") {
                    
                    let tokens = line.split(separator: "=")
                    
                    if tokens.count >= 3 {
                        
                        let timeStr = tokens[2].split(separator: " ")[0].trim()
                        let timeTokens = timeStr.split(separator: ":")
                        
                        if let hrs = Double(timeTokens[0]), let mins = Double(timeTokens[1]), let secs = Double(timeTokens[2]) {
                            duration = hrs * 3600 + mins * 60 + secs
                        }
                    }
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                FileSystemUtils.deleteFile(outFile.path)
            }
        }

        return duration
    }
}

protocol MuxerProtocol {
    
    func trackNeedsMuxing(_ track: Track) -> Bool
    
    func muxForDuration(_ track: Track) -> Double?
}
