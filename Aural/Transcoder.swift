import Foundation

protocol TranscoderProtocol {
    
    func transcodeTrack(_ track: Track, _ trackPrepBlock: @escaping ((_ file: URL) -> Void)) -> URL?
    
    func cancel()
}

class Transcoder: TranscoderProtocol, PersistentModelObject {
    
    let store: TranscoderStore
    
    private let formatsMap: [String: String] = ["flac": "aiff", "wma": "mp3", "ogg": "mp3"]
    
    private var transcodedTrack: Track!
    private var startTime: Date!
    
    init(_ state: TranscoderState, _ preferences: TranscodingPreferences) {
        store = TranscoderStore(state, preferences)
    }
    
    func transcodeTrack(_ track: Track, _ trackPrepBlock: @escaping ((_ file: URL) -> Void)) -> URL? {
    
        if let outFile = store.getForTrack(track) {
            return outFile
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
            
            self.transcodedTrack = track
            self.startTime = Date()
            
            let transcodingResult = LibAVWrapper.transcode(inputFile, outputFile, self.transcodingProgress)
            self.store.fileAddedToStore(outputFile)
            
            if self.transcodedTrack == nil {
                // Transcoding has been canceled. Don't proceed.
                return
            }
            
            trackPrepBlock(outputFile)
            
            if !transcodingResult {
                track.lazyLoadingInfo.preparationError = TrackNotPlayableError(track)
            }
            
            AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, transcodingResult && self.transcodedTrack.lazyLoadingInfo.preparedForPlayback))
        }
        
        return nil
    }
    
    private func transcodingProgress(_ progressStr: String) {
        
        // If transcoding is canceled, transcodedTrack may be nil
        if let transcodedTrack = self.transcodedTrack {
            
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
    
    func cancel() {
        
        LibAVWrapper.cancelTask()
        
        startTime = nil
        
        store.deleteEntry(transcodedTrack)
        transcodedTrack = nil
    }
    
    // Returns all state for this playlist that needs to be persisted to disk
    func persistentState() -> PersistentState {
        
        let state = TranscoderState()
        store.map.forEach({state.entries[$0.key] = $0.value})
        
        return state
    }
}
