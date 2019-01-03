import Foundation

class Muxer: MuxerProtocol {
    
    private let containers: [String: String] = ["aac": "m4a"]
    
    private let baseDir = AppConstants.FilesAndPaths.baseDir.appendingPathComponent("transcoderStore", isDirectory: true)
    
    func trackNeedsMuxing(_ track: Track) -> Bool {
        
        let inFileExt = track.file.pathExtension.lowercased()
        return containers[inFileExt] != nil
    }
    
    func mux(_ track: Track) -> URL? {
        
        let inFileExt = track.file.pathExtension.lowercased()
        
        if let outFileExt = containers[inFileExt] {
            
            let inputFileName = track.file.lastPathComponent
            let nowString = Date().serializableString_hms()
            let randomNum = Int.random(in: 0..<Int.max)
            let outputFileName = String(format: "%@-muxed-%@-%d.%@", inputFileName, nowString, randomNum, outFileExt)
            let outFile = baseDir.appendingPathComponent(outputFileName, isDirectory: false)
         
            let cmd = FFMpegWrapper.createMuxerCommand(track.file, outFile)
            let result = CommandExecutor.execute(cmd)
            
            if result.exitCode == 0 {
                return outFile
            }
        }

        return nil
    }
}

protocol MuxerProtocol {
    
    func trackNeedsMuxing(_ track: Track) -> Bool
    
    func mux(_ track: Track) -> URL?
}
