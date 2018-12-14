import Foundation

class Transcoder {
    
    static let store = TranscoderStore()
    
    private static let formatsMap: [String: String] = ["flac": "aiff", "wma": "mp3", "ogg": "mp3"]
    
    private static var transcodedTrack: Track!
    private static var startTime: Date!
    
    // TODO: Move this init code to TranscoderStore.init()
    static func initializeStore(_ state: TranscoderState) {
        
        state.entries.forEach({
            store.map[$0.key] = $0.value
        })
    }
    
    static func cancel() {
        
        LibAVWrapper.cancelTask()
        
        startTime = nil
        transcodedTrack = nil
    }
    
    static func transcodeAsync(_ track: Track, _ trackPrepBlock: @escaping ((_ file: URL) -> Void)) {
        
        // TODO: This method should tell caller that it found a prepared file, no need to wait for playback
        if let outFile = store.getForTrack(track) {
            
            trackPrepBlock(outFile)
            AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, true))
            return
        }
        
        let inputFile = track.file
        let inputFileName = inputFile.lastPathComponent
        
        let inputFileExtension = inputFile.pathExtension.lowercased()

        let outputFileExtension = formatsMap[inputFileExtension] ?? "mp3"
        
        // File name needs to be unique. Otherwise, command execution will hang (libav will ask if you want to overwrite).
        
        let now = Date()
        let outputFileName = String(format: "%@-transcoded-%@.%@", inputFileName, now.serializableString_hms(), outputFileExtension)
        
        let outputFile = store.addEntry(track, outputFileName)
        
        AsyncMessenger.publishMessage(TranscodingStartedAsyncMessage(track))
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            transcodedTrack = track
            startTime = Date()
            
            let transcodingResult = LibAVWrapper.transcode(inputFile, outputFile, self.transcodingProgress)
            
            if transcodedTrack == nil {
                // Transcoding has been canceled. Don't proceed.
                return
            }
            
            trackPrepBlock(outputFile)
            
            if !transcodingResult {
                track.lazyLoadingInfo.preparationError = TrackNotPlayableError(track)
            }
            
            AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, transcodingResult && transcodedTrack.lazyLoadingInfo.preparedForPlayback))
        }
    }
    
    private static func transcodingProgress(_ progressStr: String) {
        
        // If transcoding is canceled, transcodedTrack may be nil
        if let transcodedTrack = transcodedTrack {
            
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
}
