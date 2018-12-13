import Foundation

protocol TranscoderProtocol {
    
    func transcode(_ track: Track) -> URL
}

class Transcoder {
    
    static func transcode(_ track: Track) -> URL? {
        
        if let filePath = Bundle.main.url(forResource: "avconv", withExtension: "")?.path {
            
            print("LibAV Binary:", filePath)
            
            let srcFile = track.file
            let origName = srcFile.lastPathComponent
            let destFile = srcFile.deletingLastPathComponent().appendingPathComponent(origName + "-transcoded.mp3")
            
            print(srcFile.path, "->", destFile.path)
            
            let start = Date()
            let result = executeCommand(command: filePath, args: ["-i", srcFile.path, destFile.path])
            let end = Date()
            let time = end.timeIntervalSince(start)
            
            print("\n\n--------- RESULT --------------\n")
            print(result, result.isEmpty)
            print("\n\n--------- END RESULT --------------\n")
            
            print("\nTranscoding Time:", time)
            
            return destFile
        }
        
        return nil
    }
    
    static func executeCommand(command: String, args: [String]) -> String {
        
        let task = Process()
        
        task.launchPath = command
        task.arguments = args
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        
        return output
    }
}
