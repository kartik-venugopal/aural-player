import Foundation

class Transcoder: TranscoderProtocol, PlaylistChangeListenerProtocol, AsyncMessageSubscriber, PersistentModelObject {
    
    private let ffmpegBinaryPath: String = Bundle.main.url(forResource: "ffmpeg", withExtension: "")!.path
    
    private let store: TranscoderStore
    private let daemon: TranscoderDaemon
    
    private let preferences: TranscodingPreferences
    
    private let playlist: PlaylistAccessorProtocol
    private let sequencer: SequencerInfoDelegateProtocol
    
    var currentDiskSpaceUsage: UInt64 {return store.currentDiskSpaceUsage}
    
    init(_ state: TranscoderState, _ preferences: TranscodingPreferences, _ playlist: PlaylistAccessorProtocol, _ sequencer: SequencerInfoDelegateProtocol) {
        
        self.store = TranscoderStore(state, preferences)
        self.daemon = TranscoderDaemon(preferences)
        self.preferences = preferences
        
        self.playlist = playlist
        self.sequencer = sequencer
        
        AsyncMessenger.subscribe([.trackTransition, .tracksRemoved, .doneAddingTracks], subscriber: self, dispatchQueue: DispatchQueue.global(qos: .background))
    }
    
    func transcodeImmediately(_ track: Track) {
    
        if let outFile = store.getForTrack(track) {
            
            track.prepareWithAudioFile(outFile)
            return
        }
        
        doTranscode(track, false)
    }
    
    func transcodeInBackground(_ track: Track) {
        doTranscodeInBackground(track)
    }
    
    private func doTranscodeInBackground(_ track: Track, _ userAction: Bool = true) {
        
        track.validateAudio()
            
        if track.lazyLoadingInfo.preparationFailed, let preparationError = track.lazyLoadingInfo.preparationError {
            
            if userAction {
                AsyncMessenger.publishMessage(TrackNotTranscodedAsyncMessage(track, preparationError))
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
            
            track.prepareWithAudioFile(outputFile)
            
            // Only do this if task is in the foreground (i.e. monitoring enabled)
            if command.enableMonitoring {
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
        
//        NSLog("CALLBACK() %@", command.track.conciseDisplayName)
//        print("\n\n")
        
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
                    var totalTime = perc == 0 ? 0 : (100 * timeElapsed) / perc
                    
                    if totalTime == Double.infinity || totalTime == Double.nan || totalTime == Double.greatestFiniteMagnitude {totalTime = 0}
                    let timeRemaining = abs(totalTime - timeElapsed)
                    
                    let speed = String(tokens.last!).trim()
                    
                    AsyncMessenger.publishMessage(TranscodingProgressAsyncMessage(track, time, perc, timeElapsed, timeRemaining, speed))
                }
            }
        }
    }

    func moveToBackground(_ track: Track) {
        
        DispatchQueue.global(qos: .utility).async {
            self.daemon.moveTaskToBackground(track)
        }
    }
    
    func cancelTranscoding(_ track: Track) {
        daemon.cancelTask(track)
    }
    
    func trackNeedsTranscoding(_ track: Track) -> Bool {
        return !track.playbackNativelySupported && !store.hasForTrack(track) && !daemon.hasTaskForTrack(track)
    }
    
    var persistentState: PersistentState {
        
        let state = TranscoderState()
        store.files.forEach({state.entries[$0.key] = $0.value})
        
        return state
    }
    
    // MARK: Message handling
    
    private func beginEagerTranscoding() {
        
        let playingTrack = sequencer.currentTrack
        
        let subsequentTracks: Set<Track> = Set([sequencer.peekNext(), sequencer.peekPrevious(), sequencer.peekSubsequent()]
            .compactMap {$0})

        // Use a Set to avoid duplicates
        let tracksToTranscode: Set<Track> = Set(subsequentTracks.filter({$0 != playingTrack && self.trackNeedsTranscoding($0)}))
        
//        let ttt = tracksToTranscode.map {$0.conciseDisplayName}
//        print("\nCur:", playingTrack?.conciseDisplayName)
//        print("\n\tTTT:", ttt)
        
//        let transcodingTasks = daemon.tasks.keys
//        let tasksToCancel = transcodingTasks.filter({!subsequentTracks.contains($0) && $0 != playingTrack})
//        let ttc = tasksToCancel.map {$0.conciseDisplayName}
////        print("\n\tToCancel:", ttc, "\n")
//
//        for track in tasksToCancel {
//            doCancel(track, false)
//        }
        
        for track in tracksToTranscode {
            doTranscodeInBackground(track, false)
//            print("\tTranscoding in BG:", track.conciseDisplayName)
        }
    }
    
    private func tracksRemoved(_ message: TracksRemovedAsyncMessage) {
        
        let tracks = message.results.tracks
        
        for track in tracks {
            cancelTranscoding(track)
        }
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackTransition:
            
            beginEagerTranscoding()
            
        case .doneAddingTracks:
            
            beginEagerTranscoding()
            
        case .tracksRemoved:
            tracksRemoved(message as! TracksRemovedAsyncMessage)
            
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
    
    func checkDiskSpaceUsage() {
        //        store.checkDiskSpaceUsage()
    }
    
    func setMaxBackgroundTasks(_ numTasks: Int) {
        daemon.setMaxBackgroundTasks(numTasks)
    }
}

protocol TranscoderProtocol {
    
    func transcodeImmediately(_ track: Track)
    
    func transcodeInBackground(_ track: Track)
    
    func moveToBackground(_ track: Track)
    
    func cancelTranscoding(_ track: Track)
    
    // MARK: Query functions
    
    var currentDiskSpaceUsage: UInt64 {get}
    
    func trackNeedsTranscoding(_ track: Track) -> Bool
    
    func checkDiskSpaceUsage()
    
    func setMaxBackgroundTasks(_ numTasks: Int)
}
