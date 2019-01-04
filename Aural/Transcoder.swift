import Foundation

class Transcoder: TranscoderProtocol, PlaylistChangeListenerProtocol, AsyncMessageSubscriber, PersistentModelObject {
    
    private let ffmpegBinaryPath: String = Bundle.main.url(forResource: "ffmpeg", withExtension: "")!.path
    
    private let store: TranscoderStore
    private let daemon: TranscoderDaemon
    
    private let preferences: TranscodingPreferences
    
    private lazy var playlist: PlaylistAccessorProtocol = ObjectGraph.playlistAccessor
    private lazy var sequencer: PlaybackSequencerInfoDelegateProtocol = ObjectGraph.playbackSequencerInfoDelegate
    private lazy var player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    let subscriberId: String = "Transcoder"
    
    var currentDiskSpaceUsage: UInt64 {return store.currentDiskSpaceUsage}
    
    init(_ state: TranscoderState, _ preferences: TranscodingPreferences) {
        
        store = TranscoderStore(state, preferences)
        daemon = TranscoderDaemon(preferences)
        self.preferences = preferences
        
        AsyncMessenger.subscribe([.trackChanged, .tracksRemoved, .doneAddingTracks], subscriber: self, dispatchQueue: DispatchQueue.global(qos: .background))
    }
    
    func transcodeImmediately(_ track: Track) {
    
        if let outFile = store.getForTrack(track) {
            
            AudioUtils.prepareTrackWithFile(track, outFile)
            return
        }
        
        AsyncMessenger.publishMessage(TranscodingStartedAsyncMessage(track))
        doTranscode(track, false)
    }
    
    func transcodeInBackground(_ track: Track) {
        doTranscodeInBackground(track)
    }
    
    private func doTranscodeInBackground(_ track: Track, _ userAction: Bool = true) {
        
        if let prepError = AudioUtils.validateTrack(track) {
            
            // Note any error encountered
            track.lazyLoadingInfo.preparationFailed(prepError)
            
            if userAction {
                AsyncMessenger.publishMessage(TrackNotTranscodedAsyncMessage(track, prepError))
            }
            return
        }
        
        doTranscode(track, true)
    }
    
    private func doTranscode(_ track: Track, _ inBackground: Bool) {
        
        let formatMapping = FormatMapper.outputFormatForTranscoding(track)
        let outputFile = outputFileForTrack(track, formatMapping.outputExtension)
        let command = FFMpegWrapper.createTranscoderCommand(track, outputFile, formatMapping, self.transcodingProgress, inBackground ? .background : .userInteractive , !inBackground)
        
        let successHandler = { (command: MonitoredCommand) -> Void in
            
            self.store.transcodingFinished(track)
            
            // Only do this if task is in the foreground (i.e. monitoring enabled)
            if command.enableMonitoring {
                
                AudioUtils.prepareTrackWithFile(track, outputFile)
                AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, track.lazyLoadingInfo.preparedForPlayback))
            }
        }
        
        let failureHandler = { (command: MonitoredCommand) -> Void in
            
            // Only do this if task is in the foreground (i.e. monitoring enabled)
            if command.enableMonitoring {
                
                track.lazyLoadingInfo.preparationError = TranscodingFailedError(track)
                AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, false))
            }
            
            self.store.transcodingCancelledOrFailed(track)
        }
        
        let cancellationHandler = {
            self.store.transcodingCancelledOrFailed(track)
        }
        
        inBackground ? daemon.submitBackgroundTask(track, command, successHandler, failureHandler, cancellationHandler) : daemon.submitImmediateTask(track, command, successHandler, failureHandler, cancellationHandler)
    }
    
    private func outputFileForTrack(_ track: Track, _ outputFileExtension: String) -> URL {
        
        // File name needs to be unique. Otherwise, command execution will hang (ffmpeg will ask if you want to overwrite).
        // TODO: To make this foolproof, add a loop: while(fileNameExists()) {generate a unique name}

        let inputFileName = track.file.lastPathComponent
        let nowString = Date().serializableString_hms()
        let randomNum = Int.random(in: 0..<Int.max)
        let outputFileName = String(format: "%@-transcoded-%@-%d.%@", inputFileName, nowString, randomNum, outputFileExtension)
        
        return store.createOutputFile(track, outputFileName)
    }
    
    private func transcodingProgress(_ command: MonitoredCommand, _ progressStr: String) {
        
        if command.cancelled {return}

        let line = progressStr.trim()
        if line.contains("time=") {
            
            let tokens = line.split(separator: "=")
            
            if tokens.count == 5 {
                
                let timeStr = tokens[2].split(separator: " ")[0].trim()
                let timeTokens = timeStr.split(separator: ":")
                
                if let hrs = Double(timeTokens[0]), let mins = Double(timeTokens[1]), let secs = Double(timeTokens[2]) {
                
                    let time = hrs * 3600 + mins * 60 + secs
                    let track = command.track
                    
                    let perc = min(time * 100 / track.duration, 100)
                    let timeElapsed = Date().timeIntervalSince(command.startTime)
                    let totalTime = (100 * timeElapsed) / perc
                    let timeRemaining = totalTime - timeElapsed
                    
                    let speed = String(tokens.last!).trim()
                    
                    AsyncMessenger.publishMessage(TranscodingProgressAsyncMessage(track, time, perc, timeElapsed, timeRemaining, speed))
                }
            }
        }
    }

    func cancel(_ track: Track) {
        doCancel(track)
    }
    
    private func doCancel(_ track: Track, _ notifyFrontEnd: Bool = true) {
        
        if daemon.hasTaskForTrack(track) {
            
            daemon.cancelTask(track)
            
            if notifyFrontEnd {
                AsyncMessenger.publishMessage(TranscodingCancelledAsyncMessage(track))
            }
        }
    }
    
    func trackNeedsTranscoding(_ track: Track) -> Bool {
        return !track.playbackNativelySupported && !store.hasForTrack(track) && !daemon.hasTaskForTrack(track)
    }
    
    func checkDiskSpaceUsage() {
//        store.checkDiskSpaceUsage()
    }
    
    func setMaxBackgroundTasks(_ numTasks: Int) {
        daemon.setMaxBackgroundTasks(numTasks)
    }
    
    func persistentState() -> PersistentState {
        
        let state = TranscoderState()
        store.files.forEach({state.entries[$0.key] = $0.value})
        
        return state
    }
    
    // MARK: Message handling
    
    private func trackChanged() {
        
        // TODO: Check preference "eagerTranscodingEnabled" first
        
        // Use a Set to avoid duplicates
        var tracksToTranscode: Set<IndexedTrack> = Set<IndexedTrack>()
        
        let playingTrack = player.playingTrack
        
        if let next = sequencer.peekNext() {tracksToTranscode.insert(next)}
        if let prev = sequencer.peekPrevious() {tracksToTranscode.insert(prev)}
        if let subsequent = sequencer.peekSubsequent() {tracksToTranscode.insert(subsequent)}
        
        for track in tracksToTranscode {
            
            if !track.equals(playingTrack) && trackNeedsTranscoding(track.track) {
                doTranscodeInBackground(track.track, false)
            }
        }
    }
    
    private func tracksRemoved(_ message: TracksRemovedAsyncMessage) {
        
        let tracks = message.results.tracks
        
        for track in tracks {
            doCancel(track, false)
        }
    }
    
    private func doneAddingTracks() {
        trackChanged()
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackChanged:
            trackChanged()
            
        case .tracksRemoved:
            tracksRemoved(message as! TracksRemovedAsyncMessage)
            
        case .doneAddingTracks:
            doneAddingTracks()
            
        default: return
            
        }
    }
    
    //    func tracksAdded(_ addResults: [TrackAddResult]) {
    //
    //        if preferences.eagerTranscodingEnabled {
    //
    //            if preferences.eagerTranscodingOption == .allFiles {
    //
    //                let task = {
    //
    //                    let tracks = self.playlist.tracks
    //                    for track in tracks {
    //
    //                        if !track.playbackNativelySupported && self.store.getForTrack(track) == nil {
    //
    //                            let outputFile = self.outputFileForTrack(track)
    //
    //                            if FFMpegWrapper.transcode(track.file, outputFile, self.transcodingProgress) {
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
    //            }
    //        }
    //    }
}

protocol TranscoderProtocol {
    
    func transcodeImmediately(_ track: Track)
    
    func transcodeInBackground(_ track: Track)
    
    func cancel(_ track: Track)
    
    // MARK: Query functions
    
    var currentDiskSpaceUsage: UInt64 {get}
    
    func trackNeedsTranscoding(_ track: Track) -> Bool
    
    func checkDiskSpaceUsage()
    
    func setMaxBackgroundTasks(_ numTasks: Int)
}

extension String {
    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

extension Substring.SubSequence {
    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
