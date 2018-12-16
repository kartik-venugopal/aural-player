import Foundation

protocol TranscoderProtocol {
    
    func transcode(_ track: Track, _ trackPrepBlock: @escaping ((_ file: URL) -> Void))
    
    func cancel(_ track: Track)
}

class Transcoder: TranscoderProtocol, PlaylistChangeListenerProtocol, PersistentModelObject {
    
    private let avConvBinaryPath: String = Bundle.main.url(forResource: "avconv", withExtension: "")!.path
    
    private let store: TranscoderStore
    private let daemon: TranscoderDaemon
    
    private let preferences: TranscodingPreferences
    
    private let formatsMap: [String: String] = ["flac": "aiff", "wma": "mp3", "ogg": "mp3"]
    private let defaultOutputFileExtension: String = "mp3"
    
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
        let outputFile = outputFileForTrack(track)
        
        AsyncMessenger.publishMessage(TranscodingStartedAsyncMessage(track))
        
        let command = createCommand(track, inputFile, outputFile, self.transcodingProgress, .userInteractive, true)
        
        let successHandler = {
            
            self.store.addFileMapping(track, outputFile)
            trackPrepBlock(outputFile)
            AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, track.lazyLoadingInfo.preparedForPlayback))
        }
        
        let failureHandler = {
            
            track.lazyLoadingInfo.preparationError = TrackNotPlayableError(track)
            AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, false))
        }
        
        daemon.submitTask(track, command, successHandler, failureHandler, .immediate)
    }
    
    private func createCommand(_ track: Track, _ inputFile: URL, _ outputFile: URL, _ progressCallback: @escaping ((_ command: Command, _ output: String) -> Void), _ qualityOfService: QualityOfService, _ enableMonitoring: Bool) -> Command {
        
        // -vn: Ignore video stream (including album art)
        // -sn: Ignore subtitles
        // -ac 2: Convert to stereo audio
        return Command.createMonitoredCommand(track: track, cmd: avConvBinaryPath, args: ["-i", inputFile.path, "-vn", "-sn", "-ac", "2", outputFile.path], qualityOfService: qualityOfService, timeout: nil, callback: progressCallback, enableMonitoring: enableMonitoring)
    }
    
    private func outputFileForTrack(_ track: Track) -> URL {
        
        let inputFile = track.file
        let inputFileName = inputFile.lastPathComponent
        let inputFileExtension = inputFile.pathExtension.lowercased()
        let outputFileExtension = formatsMap[inputFileExtension] ?? defaultOutputFileExtension
        
        // File name needs to be unique. Otherwise, command execution will hang (libav will ask if you want to overwrite).
        
        let now = Date()
        let outputFileName = String(format: "%@-transcoded-%@.%@", inputFileName, now.serializableString_hms(), outputFileExtension)
        
        return store.createOutputFile(track, outputFileName)
    }
    
    private func transcodingProgress(_ command: Command, _ progressStr: String) {
        
        if command.cancelled {return}

        let line = progressStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if line.contains("size=") && line.contains("time=") {
            
            let timeStr = line.split(separator: "=")[2].split(separator: " ")[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if let time = Double(timeStr) {
                
                let track = command.track
                
                let perc = min(time * 100 / track.duration, 100)
                let timeElapsed = Date().timeIntervalSince(command.startTime)
                let totalTime = (100 * timeElapsed) / perc
                let timeRemaining = totalTime - timeElapsed
                
                let msg = TranscodingProgressAsyncMessage(track, time, perc, timeElapsed, timeRemaining)
                AsyncMessenger.publishMessage(msg)
            }
        }
    }

    func cancel(_ track: Track) {

        daemon.cancelTask(track)
        store.deleteEntry(track)
    }
    
    // Returns all state for this playlist that needs to be persisted to disk
    func persistentState() -> PersistentState {
        
        let state = TranscoderState()
        store.map.forEach({state.entries[$0.key] = $0.value})
        
        return state
    }
    
    // MARK: PlaylistChangeListenerProtocol methods
    
    func tracksAdded(_ addResults: [TrackAddResult]) {
        
        if preferences.eagerTranscodingEnabled {
            
            if preferences.eagerTranscodingOption == .allFiles {
                
//                let task = {
//
//                    let tracks = self.playlist.tracks
//                    for track in tracks {
//
//                        if !track.nativelySupported && self.store.getForTrack(track) == nil {
//
//                            let outputFile = self.outputFileForTrack(track)
//
//                            if LibAVWrapper.transcode(track.file, outputFile, self.transcodingProgress) {
//                                self.store.fileAddedToStore(outputFile)
//                            }
//
//                            // TODO: How to continue transcoding more tracks ???
//                            return
//                        }
//                    }
//                }
//
//                daemon.submitTask(task, .background)
            }
        }
    }
}


