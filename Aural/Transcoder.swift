import Foundation

class Transcoder {
    
    private static let formatsMap: [String: String] = ["flac": "aiff", "wma": "mp3", "ogg": "mp3"]
    
    private static var transcodedTrack: Track!
    private static var startTime: Date!
    
    static func transcodeAsync(_ track: Track, _ trackPrepBlock: @escaping ((_ file: URL) -> Void)) {
        
        let inputFile = track.file
        let inputFileExtension = inputFile.pathExtension.lowercased()

        let outputFileExtension = formatsMap[inputFileExtension] ?? "mp3"
        
        // File name needs to be unique. Otherwise, command execution will hang (libav will ask if you want to overwrite).
        
        let now = Date()
        let outputFilePath = String(format: "%@-transcoded-%@.%@", inputFile.path, now.serializableString_hms(), outputFileExtension)
        let outputFile = URL(fileURLWithPath: outputFilePath)
        
        AsyncMessenger.publishMessage(TranscodingStartedAsyncMessage(track))
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            transcodedTrack = track
            startTime = Date()
            
            let transcodingResult = LibAVWrapper.transcode(inputFile, outputFile, self.transcodingProgress)
            trackPrepBlock(outputFile)
            
            if !transcodingResult {
                track.lazyLoadingInfo.preparationError = TrackNotPlayableError(track)
            }
            
            AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, transcodingResult && transcodedTrack.lazyLoadingInfo.preparedForPlayback))
        }
    }
    
    private static func transcodingProgress(_ progressStr: String) {
        
        let line = progressStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if line.contains("size=") && line.contains("time=") {
            
            let timeStr = line.split(separator: "=")[2].split(separator: " ")[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if let time = Double(timeStr) {
                
                let perc = min(time * 100 / transcodedTrack.duration, 100)
                let timeElapsed = Date().timeIntervalSince(startTime)
                let totalTime = (100 * timeElapsed) / perc
                let timeRemaining = totalTime - timeElapsed
                
                let msg = TranscodingProgressAsyncMessage(transcodedTrack, time, perc, timeElapsed, timeRemaining)
                AsyncMessenger.publishMessage(msg)
            }
        }
    }
}
