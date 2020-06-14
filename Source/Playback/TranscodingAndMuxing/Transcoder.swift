import Foundation

class Transcoder: TranscoderProtocol, MessageSubscriber, AsyncMessageSubscriber, PersistentModelObject {
    
    // TODO: On appExit(), cancel all tasks and delete in-progress output files.
    
    private let store: TranscoderStore
    private let daemon: TranscoderDaemon
    
    private let preferences: TranscodingPreferences
    
    private let playlist: PlaylistAccessorProtocol
    private let sequencer: SequencerInfoDelegateProtocol
    
    var currentDiskSpaceUsage: UInt64 {return store.currentDiskSpaceUsage}
    
    private let backgroundQueue: DispatchQueue = DispatchQueue.global(qos: .background)
    
    let subscriberId: String = "Transcoder"
    
    init(_ state: TranscoderState, _ preferences: TranscodingPreferences, _ playlist: PlaylistAccessorProtocol, _ sequencer: SequencerInfoDelegateProtocol) {
        
        self.store = TranscoderStore(state, preferences)
        self.daemon = TranscoderDaemon(preferences)
        self.preferences = preferences
        
        self.playlist = playlist
        self.sequencer = sequencer
        
        Messenger.subscribeAsync(self, .doneAddingTracks, self.doneAddingTracks, queue: backgroundQueue)
        Messenger.subscribeAsync(self, .tracksRemoved, self.tracksRemoved(_:), queue: backgroundQueue)
        
        AsyncMessenger.subscribe([.trackTransition], subscriber: self, dispatchQueue: backgroundQueue)
    }
    
    func transcodeImmediately(_ track: Track) -> (readyForPlayback: Bool, transcodingFailed: Bool) {
    
        if let outFile = store.getForTrack(track) {
            
            track.prepareWithAudioFile(outFile)
            
            // TODO: If preparation ^ fails, should we delete the output file to retry and prevent recurring errors ???
            
            return (track.lazyLoadingInfo.preparedForPlayback, track.lazyLoadingInfo.preparationFailed)
        }
        
        doTranscode(track, false)
        return (false, false)
    }
    
    func transcodeInBackground(_ track: Track) {
        doTranscodeInBackground(track)
    }
    
    private func doTranscodeInBackground(_ track: Track, _ userAction: Bool = true) {
        
        track.validateAudio()
            
        if track.lazyLoadingInfo.preparationFailed, let preparationError = track.lazyLoadingInfo.preparationError {
            
            if userAction {
                Messenger.publish(TrackNotTranscodedNotification(track: track, error: preparationError))
            }
            
            return
        }
        
        doTranscode(track, true)
    }
    
    private func doTranscode(_ track: Track, _ inBackground: Bool) {
        
        // If this track is already being transcoded, just adjust the
        // task priority (i.e. background/foreground) as required.
        if daemon.hasTaskForTrack(track) {
            
            daemon.rePrioritize(track, inBackground)
            return
        }
        
        let formatMapping = FormatMapper.outputFormatForTranscoding(track)
        let outputFile = outputFileForTrack(track, formatMapping.outputExtension)
        let command = FFMpegWrapper.createTranscoderCommand(track, outputFile, formatMapping, self.transcodingProgress, inBackground ? .background : .userInteractive , !inBackground)
        
        let successHandler = { (command: MonitoredCommand) -> Void in
            
            self.store.transcodingFinished(track)
            
            track.prepareWithAudioFile(outputFile)
            
            // Only do this if task is in the foreground (i.e. monitoring enabled)
            if command.enableMonitoring {
                Messenger.publish(TranscodingFinishedNotification(track: track, success: track.lazyLoadingInfo.preparedForPlayback))
            }
        }
        
        let failureHandler = { (command: MonitoredCommand) -> Void in
            
            // Only do this if task is in the foreground (i.e. monitoring enabled)
            if command.enableMonitoring {
                
                track.lazyLoadingInfo.preparationError = TranscodingFailedError(track)
                Messenger.publish(TranscodingFinishedNotification(track: track, success: false))
            }
            
            self.store.transcodingCancelledOrFailed(outputFile)
        }
        
        let cancellationHandler = {
            self.store.transcodingCancelledOrFailed(outputFile)
        }
        
        daemon.submitTask(track, command, successHandler, failureHandler, cancellationHandler, inBackground)
    }
    
    private func outputFileForTrack(_ track: Track, _ outputFileExtension: String) -> URL {
        
        // File name needs to be unique. Otherwise, command execution will hang (ffmpeg will ask if you want to overwrite).
        // TODO: To make this foolproof, add a loop: while(fileNameExists()) {generate a unique name}

        let inputFileName = track.file.lastPathComponent
        let nowString = Date().serializableString_hms()
        let randomNum = Int.random(in: 0..<10000)
        
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
                    var totalTime = perc == 0 ? 0 : (100 * timeElapsed) / perc
                    
                    if totalTime == Double.infinity || totalTime == Double.nan || totalTime == Double.greatestFiniteMagnitude {totalTime = 0}
                    let timeRemaining = abs(totalTime - timeElapsed)
                    
                    Messenger.publish(TranscodingProgressNotification(track: track, percentageTranscoded: perc,
                                                                      timeElapsed: timeElapsed, timeRemaining: timeRemaining))
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
        state.entries = store.files.kvPairs
        return state
    }
    
    // MARK: Message handling
    
    private func beginEagerTranscoding(_ dontTranscodeTrack: Track? = nil) {
        
        let playingTrack = sequencer.currentTrack
        let subsequentTracks: Set<Track> = Set([sequencer.peekNext(), sequencer.peekPrevious(), sequencer.peekSubsequent()]
        .compactMap {$0})
        
        let transcodingTracks = daemon.transcodingTracks
        let tasksToCancel = transcodingTracks.filter({(!subsequentTracks.contains($0)) && $0 != playingTrack})
        
        for track in tasksToCancel {
            cancelTranscoding(track)
        }
        
        let tracksToTranscode: Set<Track> = subsequentTracks.filter({$0 != playingTrack && $0 != dontTranscodeTrack && self.trackNeedsTranscoding($0)})
        
        for track in tracksToTranscode {
            doTranscodeInBackground(track, false)
        }
    }
    
    private func tracksRemoved(_ message: TracksRemovedNotification) {
        
        for track in message.results.tracks {
            cancelTranscoding(track)
        }
    }
    
    func doneAddingTracks() {
        beginEagerTranscoding()
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackTransition:
            
            beginEagerTranscoding((message as? TrackTransitionAsyncMessage)?.beginTrack)
            
        default: return
            
        }
    }
    
    func checkDiskSpaceUsage() {
        //        store.checkDiskSpaceUsage()
    }
    
    func setMaxBackgroundTasks(_ numTasks: Int) {
        daemon.setMaxBackgroundTasks(numTasks)
    }
}

protocol TranscoderProtocol {
    
    func transcodeImmediately(_ track: Track) -> (readyForPlayback: Bool, transcodingFailed: Bool)
    
    func transcodeInBackground(_ track: Track)
    
    func moveToBackground(_ track: Track)
    
    func cancelTranscoding(_ track: Track)
    
    // MARK: Query functions
    
    var currentDiskSpaceUsage: UInt64 {get}
    
    func trackNeedsTranscoding(_ track: Track) -> Bool
    
    func checkDiskSpaceUsage()
    
    func setMaxBackgroundTasks(_ numTasks: Int)
}

