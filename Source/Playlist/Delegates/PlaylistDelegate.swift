import Foundation

class PlaylistDelegate: PlaylistDelegateProtocol, NotificationSubscriber {
    
    // The actual playlist
    private let playlist: PlaylistCRUDProtocol
    
    private let trackReader: TrackReader
    
    // TODO - See if change listeners can be replaced with sync messages
    // A set of all observers/listeners that are interested in changes to the playlist
    private let changeListeners: [PlaylistChangeListenerProtocol]
    
    // Persistent playlist state (used upon app startup)
    private let playlistState: PlaylistState
    
    // User preferences (used for autoplay)
    private let preferences: Preferences
    
    private let trackAddQueue: OperationQueue = OperationQueue()
    private let trackUpdateQueue: OperationQueue = OperationQueue()
    
    private var addSession: TrackAddSession!
    
    private let concurrentAddOpCount = roundedInt(Double(SystemUtils.numberOfActiveCores) * 1.5)
    
    var isBeingModified: Bool {addSession != nil}
    
    var tracks: [Track] {playlist.tracks}
    
    var size: Int {playlist.size}
    
    var duration: Double {playlist.duration}
    
    init(_ playlist: PlaylistCRUDProtocol, _ trackReader: TrackReader, _ playlistState: PlaylistState, _ preferences: Preferences, _ changeListeners: [PlaylistChangeListenerProtocol]) {
        
        self.playlist = playlist
        self.trackReader = trackReader
        
        self.playlistState = playlistState
        self.preferences = preferences
        
        self.changeListeners = changeListeners
        
        trackAddQueue.maxConcurrentOperationCount = concurrentAddOpCount
        trackAddQueue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        trackAddQueue.qualityOfService = .userInteractive
        
        trackUpdateQueue.maxConcurrentOperationCount = concurrentAddOpCount
        trackUpdateQueue.underlyingQueue = DispatchQueue.global(qos: .utility)
        trackUpdateQueue.qualityOfService = .utility
        
        // Subscribe to notifications
        Messenger.subscribe(self, .application_launched, self.appLaunched(_:))
        Messenger.subscribe(self, .application_reopened, self.appReopened(_:))
    }
    
    func indexOfTrack(_ track: Track) -> Int? {
        return playlist.indexOfTrack(track)
    }
    
    func trackAtIndex(_ index: Int) -> Track? {
        return playlist.trackAtIndex(index)
    }
    
    func summary(_ playlistType: PlaylistType) -> (size: Int, totalDuration: Double, numGroups: Int) {
        return playlist.summary(playlistType)
    }
    
    func search(_ searchQuery: SearchQuery, _ playlistType: PlaylistType) -> SearchResults {
        return playlist.search(searchQuery, playlistType)
    }
    
    func groupingInfoForTrack(_ track: Track, _ groupType: GroupType) -> GroupedTrack? {
        return playlist.groupingInfoForTrack(groupType, track)
    }
    
    func displayNameForTrack(_ playlistType: PlaylistType, _ track: Track) -> String {
        return playlist.displayNameForTrack(playlistType, track)
    }
    
    func groupAtIndex(_ type: GroupType, _ index: Int) -> Group? {
        return playlist.groupAtIndex(type, index)
    }
    
    func groupingInfoForTrack(_ type: GroupType, _ track: Track) -> GroupedTrack? {
        return playlist.groupingInfoForTrack(type, track)
    }
    
    func indexOfGroup(_ group: Group) -> Int? {
        return playlist.indexOfGroup(group)
    }
    
    func numberOfGroups(_ type: GroupType) -> Int {
        return playlist.numberOfGroups(type)
    }
    
    func allGroups(_ type: GroupType) -> [Group] {
        return playlist.allGroups(type)
    }
   
    func findFile(_ file: URL) -> Track? {
        return playlist.findTrackByFile(file)
    }
    
    func savePlaylist(_ file: URL) {
        
        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            PlaylistIO.savePlaylist(file)
        }
    }
    
    // MARK: Playlist mutation functions --------------------------------------------------
    
    func addFiles(_ files: [URL]) {
        
        let autoplayEnabled: Bool = preferences.playbackPreferences.autoplayAfterAddingTracks
        let interruptPlayback: Bool = preferences.playbackPreferences.autoplayAfterAddingOption == .always
        
        addFiles_async(files, AutoplayOptions(autoplayEnabled, .playSpecificTrack, interruptPlayback))
    }
    
    // Adds files to the playlist asynchronously, emitting event notifications as the work progresses
    private func addFiles_async(_ files: [URL], _ autoplayOptions: AutoplayOptions, _ userAction: Bool = true) {
        
        addSession = TrackAddSession(files.count, autoplayOptions)
        
        // Move to a background thread to unblock the main thread
        DispatchQueue.global(qos: .userInteractive).async {
            
            // ------------------ ADD --------------------
            
            Messenger.publish(.playlist_startedAddingTracks)
            
            self.collectTracks(files, false)
            self.addSessionTracks()
            
            // ------------------ NOTIFY ------------------
            
            let results = self.addSession.results
            
            if userAction {
                Messenger.publish(.history_itemsAdded, payload: self.addSession.addedItems)
            }
            
            // Notify change listeners
            self.changeListeners.forEach({$0.tracksAdded(results)})
            
            Messenger.publish(.playlist_doneAddingTracks)
            
            // If errors > 0, send AsyncMessage to UI
            if self.addSession.errors.isNonEmpty {
                Messenger.publish(.playlist_tracksNotAdded, payload: self.addSession.errors)
            }
            
            self.addSession = nil
        }
    }
    
    /*
        Adds a bunch of files synchronously.
     
        The autoplayOptions argument encapsulates all autoplay options.
     
        The progress argument indicates current progress.
     */
    private func collectTracks(_ files: [URL], _ isRecursiveCall: Bool) {
        
        for file in files {
            
            // Playlists might contain broken file references
            if !FileSystemUtils.fileExists(file) {
                
                addSession.addError(FileNotFoundError(file))
                continue
            }
            
            // Always resolve sym links and aliases before reading the file
            let resolvedFileInfo = FileSystemUtils.resolveTruePath(file)
            let resolvedFile = resolvedFileInfo.resolvedURL
            
            if resolvedFileInfo.isDirectory {

                // Directory
                if !isRecursiveCall {addSession.addHistoryItem(resolvedFile)}
                expandDirectory(resolvedFile)
                
            } else {
                
                // Single file - playlist or track
                let fileExtension = resolvedFile.pathExtension.lowercased()

                if AppConstants.SupportedTypes.playlistExtensions.contains(fileExtension) {

                    // Playlist
                    if !isRecursiveCall {addSession.addHistoryItem(resolvedFile)}
                    expandPlaylist(resolvedFile)
                    
                } else if AppConstants.SupportedTypes.allAudioExtensions.contains(fileExtension),
                    !playlist.hasTrackForFile(resolvedFile) {
                    
                    // Track
                    if !isRecursiveCall {addSession.addHistoryItem(resolvedFile)}
                    addSession.tracks.append(Track(resolvedFile))
                }
            }
        }
    }
    
    // Expands a playlist into individual tracks
    private func expandPlaylist(_ playlistFile: URL) {
        
        if let loadedPlaylist = PlaylistIO.loadPlaylist(playlistFile) {
            
            addSession.totalTracks += loadedPlaylist.tracks.count - 1
            collectTracks(loadedPlaylist.tracks, true)
        }
    }
    
    // Expands a directory into individual tracks (and subdirectories)
    private func expandDirectory(_ dir: URL) {
        
        if let dirContents = FileSystemUtils.getContentsOfDirectory(dir) {
            
            addSession.totalTracks += dirContents.count - 1
            collectTracks(dirContents, true)
        }
    }
    
    private func addSessionTracks() {
        
        var firstBatchIndex: Int = 0
        while addSession.tracksProcessed < addSession.tracks.count {
            
            let remainingTracks = addSession.tracks.count - addSession.tracksProcessed
            let lastBatchIndex = firstBatchIndex + min(remainingTracks, concurrentAddOpCount) - 1
            
            let batch = firstBatchIndex...lastBatchIndex
            processBatch(batch)
            addSession.tracksProcessed += batch.count
            
            firstBatchIndex = lastBatchIndex + 1
        }
    }
    
    private func processBatch(_ batch: AddBatch) {
        
        // Process all tracks in batch concurrently and wait until the entire batch finishes.
        trackAddQueue.addOperations(batch.map {index in BlockOperation {

            self.trackReader.loadPlaylistMetadata(for: self.addSession.tracks[index])
            
        }}, waitUntilFinished: true)
        
        for (batchIndex, track) in zip(batch, batch.map {addSession.tracks[$0]}) {
            
            if let result = self.playlist.addTrack(track) {
                
                addSession.tracksAdded.increment()
                addSession.results.append(result)
                
                let progress = TrackAddOperationProgress(tracksAdded: addSession.tracksAdded, totalTracks: addSession.totalTracks)
                Messenger.publish(TrackAddedNotification(trackIndex: result.flatPlaylistResult,
                                                         groupingInfo: result.groupingPlaylistResults, addOperationProgress: progress))
                
                if batchIndex == 0 && addSession.autoplayOptions.autoplay {
                    autoplay(addSession.autoplayOptions.autoplayType, track, addSession.autoplayOptions.interruptPlayback)
                }
            }
        }
    }
    
    func findOrAddFile(_ file: URL) throws -> Track? {
        
        // If track exists, return it
        if let foundTrack = playlist.findTrackByFile(file) {
            return foundTrack
        }
        
        // Always resolve sym links and aliases before reading the file
        let resolvedFile = FileSystemUtils.resolveTruePath(file).resolvedURL
        
        // If track exists, return it
        if let foundTrack = playlist.findTrackByFile(resolvedFile) {
            return foundTrack
        }
        
        // Track doesn't exist yet, need to add it
        
        // If the file points to an invalid location, throw an error
        guard FileSystemUtils.fileExists(resolvedFile) else {throw FileNotFoundError(resolvedFile)}
        
        // Load display info
        let track = Track(resolvedFile)
        trackReader.loadPlaylistMetadata(for: track)
        
        // Non-nil result indicates success
        guard let result = self.playlist.addTrack(track) else {return nil}
            
        let trackAddedNotification = TrackAddedNotification(trackIndex: result.flatPlaylistResult, groupingInfo: result.groupingPlaylistResults, addOperationProgress: TrackAddOperationProgress(tracksAdded: 1, totalTracks: 1))
        
        Messenger.publish(trackAddedNotification)
        Messenger.publish(.history_itemsAdded, payload: [resolvedFile])
        
        self.changeListeners.forEach({$0.tracksAdded([result])})
        
        return track
    }
    
    // Performs autoplay, by delegating a playback request to the player
    private func autoplay(_ autoplayType: AutoplayCommandType, _ track: Track, _ interruptPlayback: Bool) {
        
        Messenger.publish(autoplayType == .playSpecificTrack ?
            AutoplayCommandNotification(type: .playSpecificTrack, interruptPlayback: interruptPlayback, candidateTrack: track) :
            AutoplayCommandNotification(type: .beginPlayback))
    }
    
    func removeTracks(_ indexes: IndexSet) {
        
        let results: TrackRemovalResults = playlist.removeTracks(indexes)
        Messenger.publish(.playlist_tracksRemoved, payload: results)
        changeListeners.forEach({$0.tracksRemoved(results)})
    }
    
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) {
        
        let results: TrackRemovalResults = playlist.removeTracksAndGroups(tracks, groups, groupType)
        Messenger.publish(.playlist_tracksRemoved, payload: results)
        changeListeners.forEach({$0.tracksRemoved(results)})
    }
    
    func moveTracksUp(_ indexes: IndexSet) -> ItemMoveResults {
        return doMoveTracks({playlist.moveTracksUp(indexes)})
    }
    
    func moveTracksToTop(_ indexes: IndexSet) -> ItemMoveResults {
        return doMoveTracks({playlist.moveTracksToTop(indexes)})
    }
    
    func moveTracksDown(_ indexes: IndexSet) -> ItemMoveResults {
        return doMoveTracks({playlist.moveTracksDown(indexes)})
    }
    
    func moveTracksToBottom(_ indexes: IndexSet) -> ItemMoveResults {
        return doMoveTracks({playlist.moveTracksToBottom(indexes)})
    }
    
    func moveTracksAndGroupsUp(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        return doMoveTracks({playlist.moveTracksAndGroupsUp(tracks, groups, groupType)})
    }
    
    func moveTracksAndGroupsToTop(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        return doMoveTracks({playlist.moveTracksAndGroupsToTop(tracks, groups, groupType)})
    }
    
    func moveTracksAndGroupsDown(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        return doMoveTracks({playlist.moveTracksAndGroupsDown(tracks, groups, groupType)})
    }
    
    func moveTracksAndGroupsToBottom(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) -> ItemMoveResults {
        return doMoveTracks({playlist.moveTracksAndGroupsToBottom(tracks, groups, groupType)})
    }
    
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int) -> ItemMoveResults {
        return doMoveTracks({playlist.dropTracks(sourceIndexes, dropIndex)})
    }
    
    func dropTracksAndGroups(_ tracks: [Track], _ groups: [Group],
                             _ groupType: GroupType, _ dropParent: Group?, _ dropIndex: Int) -> ItemMoveResults {
        
        return doMoveTracks({playlist.dropTracksAndGroups(tracks, groups, groupType, dropParent, dropIndex)})
    }
    
    private func doMoveTracks(_ moveOperation: () -> ItemMoveResults) -> ItemMoveResults {
        
        let results = moveOperation()
        changeListeners.forEach({$0.tracksReordered(results)})
        return results
    }
    
    func clear() {
        
        playlist.clear()
        changeListeners.forEach({$0.playlistCleared()})
    }
    
    func sort(_ sort: Sort, _ playlistType: PlaylistType) {
        
        let results = playlist.sort(sort, playlistType)
        changeListeners.forEach({$0.playlistSorted(results)})
    }
    
    // MARK: Message handling
    
    func appLaunched(_ filesToOpen: [URL]) {
        
        // Check if any launch parameters were specified
        if filesToOpen.isNonEmpty {
            
            // Launch parameters  specified, override playlist saved state and add file paths in params to playlist
            addFiles_async(filesToOpen, AutoplayOptions(true), false)
            
        } else if preferences.playlistPreferences.playlistOnStartup == .rememberFromLastAppLaunch {
            
            // No launch parameters specified, load playlist saved state if "Remember state from last launch" preference is selected
            addFiles_async(playlistState.tracks, AutoplayOptions(preferences.playbackPreferences.autoplayOnStartup), false)
            
        } else if preferences.playlistPreferences.playlistOnStartup == .loadFile, let playlistFile: URL = preferences.playlistPreferences.playlistFile {
            
            addFiles_async([playlistFile], AutoplayOptions(preferences.playbackPreferences.autoplayOnStartup), false)
            
        } else if preferences.playlistPreferences.playlistOnStartup == .loadFolder, let folder: URL = preferences.playlistPreferences.tracksFolder {
            
            addFiles_async([folder], AutoplayOptions(preferences.playbackPreferences.autoplayOnStartup), false)
        }
    }
    
    func appReopened(_ notification: AppReopenedNotification) {
        
        // When a duplicate notification is sent, don't autoplay ! Otherwise, always autoplay.
        addFiles_async(notification.filesToOpen, AutoplayOptions(!notification.isDuplicateNotification))
    }
}

// Encapsulates all autoplay options
class AutoplayOptions {
    
    // Whether or not autoplay is requested
    var autoplay: Bool
    
    // Whether or not existing track playback should be interrupted, to perform autoplay
    var interruptPlayback: Bool
    
    // Whether or not the first added track should be selected for playback.
    // If false, the first track in the playlist will play.
    var autoplayType: AutoplayCommandType
    
    init(_ autoplay: Bool,
         _ autoplayType: AutoplayCommandType = .beginPlayback,
         _ interruptPlayback: Bool = true) {
        
        self.autoplay = autoplay
        self.autoplayType = autoplayType
        self.interruptPlayback = interruptPlayback
    }
}

fileprivate class TrackAddSession {
    
    var tracks: [Track] = []
    
    // For history
    var addedItems: [URL] = []
    
    var autoplayOptions: AutoplayOptions
    
    // Progress
    var tracksProcessed: Int = 0
    var tracksAdded: Int = 0
    var totalTracks: Int = 0
    var results: [TrackAddResult] = []
    var errors: [DisplayableError] = []
    
    init(_ numTracks: Int, _ autoplayOptions: AutoplayOptions) {
        
        self.totalTracks = numTracks
        self.autoplayOptions = autoplayOptions
    }
    
    func addHistoryItem(_ item: URL) {
        addedItems.append(item)
    }
    
    func addError(_ error: DisplayableError) {
        errors.append(error)
    }
}

typealias AddBatch = ClosedRange<Int>
