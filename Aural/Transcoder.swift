import Foundation

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

class Transcoder: TranscoderProtocol, PlaylistChangeListenerProtocol, AsyncMessageSubscriber, PersistentModelObject {
    
    private let ffmpegBinaryPath: String = Bundle.main.url(forResource: "ffmpeg", withExtension: "")!.path
    
    private let store: TranscoderStore
    private let daemon: TranscoderDaemon
    
    private let preferences: TranscodingPreferences
    
    private let formatsMap: [String: String] = ["flac": "aiff",
                                                "dsf": "aiff",
                                                "wma": "m4a",
                                                "ogg": "m4a",
                                                "opus": "m4a",
                                                "mpc": "m4a"]
    
    private let defaultOutputFileExtension: String = "m4a"
    
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
        
        let inputFile = track.file
        let outputFile = outputFileForTrack(track)
        
        let command = createCommand(track, inputFile, outputFile, self.transcodingProgress, inBackground ? .background : .userInteractive , !inBackground)
        
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
                
                track.lazyLoadingInfo.preparationError = TrackNotPlayableError(track)
                AsyncMessenger.publishMessage(TranscodingFinishedAsyncMessage(track, false))
            }
            
            self.store.transcodingCancelledOrFailed(track)
        }
        
        let cancellationHandler = {
            self.store.transcodingCancelledOrFailed(track)
        }
        
        inBackground ? daemon.submitBackgroundTask(track, command, successHandler, failureHandler, cancellationHandler) : daemon.submitImmediateTask(track, command, successHandler, failureHandler, cancellationHandler)
    }
    
    private func createCommand(_ track: Track, _ inputFile: URL, _ outputFile: URL, _ progressCallback: @escaping ((_ command: MonitoredCommand, _ output: String) -> Void), _ qualityOfService: QualityOfService, _ enableMonitoring: Bool) -> MonitoredCommand {
        
        let outputFileExtension = outputFile.pathExtension.lowercased()
        var args = ["-v", "quiet", "-stats", "-i", inputFile.path]
        
        if outputFileExtension == "m4a" {
            args.append(contentsOf: ["-acodec", "aac"])
        }
        
        args.append(contentsOf: ["-vn", "-sn", "-ac", "2", outputFile.path])
        
        // -vn: Ignore video stream (including album art)
        // -sn: Ignore subtitles
        // -ac 2: Convert to stereo audio
        return MonitoredCommand.create(track: track, cmd: ffmpegBinaryPath, args: args, qualityOfService: qualityOfService, timeout: nil, callback: progressCallback, enableMonitoring: enableMonitoring)
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
                    
                    let msg = TranscodingProgressAsyncMessage(track, time, perc, timeElapsed, timeRemaining, speed)
                    AsyncMessenger.publishMessage(msg)
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
