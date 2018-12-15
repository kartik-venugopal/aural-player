import Foundation

protocol TranscoderProtocol {
    
    func transcode(_ track: Track, _ trackPrepBlock: @escaping ((_ file: URL) -> Void))
    
    func cancel()
}

class Transcoder: TranscoderProtocol, PlaylistChangeListenerProtocol, PersistentModelObject {
    
    private let store: TranscoderStore
    private let daemon: TranscoderDaemon
    
    private let preferences: TranscodingPreferences
    
    private let formatsMap: [String: String] = ["flac": "aiff", "wma": "mp3", "ogg": "mp3"]
    
    private var transcodedTrack: Track!
    private var startTime: Date!
    
    private lazy var playlist: PlaylistAccessorProtocol = ObjectGraph.playlistAccessor
    
    init(_ state: TranscoderState, _ preferences: TranscodingPreferences) {
        store = TranscoderStore(state, preferences)
        daemon = TranscoderDaemon()
        self.preferences = preferences
    }
    
    func transcode(_ track: Track, _ trackPrepBlock: @escaping ((_ file: URL) -> Void)) {
    
        if let outFile = store.getForTrack(track) {
            trackPrepBlock(outFile)
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
        
        let transcodingTask = {
            
            self.transcodedTrack = track
            self.startTime = Date()
            
            let success = LibAVWrapper.transcode(inputFile, outputFile, self.transcodingProgress)
            self.store.fileAddedToStore(outputFile)
            
            if self.transcodedTrack == nil {
                // Transcoding has been canceled. Don't proceed.
                return
            }
            
            if success {
                trackPrepBlock(outputFile)
            } else {
                track.lazyLoadingInfo.preparationError = TrackNotPlayableError(track)
            }
            
            AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, success && self.transcodedTrack.lazyLoadingInfo.preparedForPlayback))
        }
        
        daemon.submitTask(transcodingTask, .immediate)
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
    
    // MARK: PlaylistChangeListenerProtocol methods
    
    func tracksAdded(_ addResults: [TrackAddResult]) {
        
    }
}
