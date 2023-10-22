//
//  PlaylistDelegate.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A delegate representing the Playlist.
///
/// Acts as a middleman between the Playlist UI and the Playlist,
/// providing a simplified interface / facade for the UI layer to manipulate the Playlist.
///
/// Also initializes the playlist on app startup, based on persistent app state and user
/// preferences.
///
/// - SeeAlso: `PlaylistDelegateProtocol`
///
class PlaylistDelegate: PlaylistDelegateProtocol {
    
    // The actual playlist
//    private var playlist: PlaylistProtocol {playlistsManager.currentPlaylist}
    private let playlist: PlaylistProtocol
    
    private let player: PlaybackInfoDelegateProtocol
    
//    private let playlistsManager: PlaylistsManager
    
    private let trackReader: TrackReader
    
    // Persistent playlist state (used upon app startup)
    private let persistentState: PlaylistPersistentState?
    
    // User preferences (used for autoplay)
    private let preferences: Preferences
    
    private var playlistPreferences: PlaylistPreferences {preferences.playlistPreferences}
    private var playbackPreferences: PlaybackPreferences {preferences.playbackPreferences}
    
    private let trackAddQueue: OperationQueue
    private let trackUpdateQueue: OperationQueue
    
    private var addSession: TrackAddSession!
    
    private let concurrentAddOpCount = (Double(System.numberOfActiveCores) * 1.5).roundedInt
    
//    var name: String {playlist.name}
    
    var isBeingModified: Bool {addSession != nil}
    
    var tracks: [Track] {playlist.tracks}
    
    var size: Int {playlist.size}
    
    var duration: Double {playlist.duration}
    
    private lazy var messenger = Messenger(for: self)
    
    init(persistentState: PlaylistPersistentState?, _ playlist: PlaylistProtocol,
         _ player: PlaybackInfoDelegateProtocol, _ trackReader: TrackReader, _ preferences: Preferences) {
        
        self.playlist = playlist
//        self.playlistsManager = playlistsManager
        self.player = player
        self.trackReader = trackReader
        
        self.persistentState = persistentState
        self.preferences = preferences
        
        trackAddQueue = OperationQueue(opCount: concurrentAddOpCount, qos: .userInteractive)
        trackUpdateQueue = OperationQueue(opCount: concurrentAddOpCount, qos: .utility)
        
        // Subscribe to notifications
        messenger.subscribe(to: .application_launched, handler: appLaunched(_:))
        messenger.subscribe(to: .application_reopened, handler: appReopened(_:))
//        messenger.subscribe(to: .playlist_currentPlaylistChanged, handler: currentPlaylistChanged)
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
            PlaylistIO.savePlaylist(tracks: self.tracks, toFile: file)
        }
    }
    
    // MARK: Playlist mutation functions --------------------------------------------------
    
    func addFiles(_ files: [URL], clearBeforeAdding: Bool = false, beginPlayback: Bool? = false) {
        
        if clearBeforeAdding {
            clear()
        }
        
        let autoplayEnabled: Bool = beginPlayback ?? playbackPreferences.autoplayAfterAddingTracks
        let interruptPlayback: Bool = beginPlayback ?? (playbackPreferences.autoplayAfterAddingOption == .always)
        
        addFiles_async(files, AutoplayOptions(autoplay: autoplayEnabled, autoplayType: .playFirstAddedTrack, interruptPlayback: interruptPlayback))
    }
    
    // Adds files to the playlist asynchronously, emitting event notifications as the work progresses
    private func addFiles_async(_ files: [URL], filesToIgnoreForHistory: Set<URL> = Set(), _ autoplayOptions: AutoplayOptions, userAction: Bool = true, reorderGroupingPlaylists: Bool = false) {
        
        addSession = TrackAddSession(files.count, autoplayOptions)
        
        // Move to a background thread to unblock the main thread
        DispatchQueue.global(qos: .userInteractive).async {
            
            // ------------------ ADD --------------------
            
            self.messenger.publish(.playlist_startedAddingTracks)
            
            // Don't sort when tracks are remembered
            if userAction && filesToIgnoreForHistory.isEmpty {
                self.collectTracks(files.sorted(by: URL.ascendingPathComparator), false)
            } else {
                self.collectTracks(files, false)
            }
            
            self.addSessionTracks()
            
            if reorderGroupingPlaylists, let persistentState = self.persistentState {
                self.playlist.reOrder(accordingTo: persistentState)
            }
            
            // ------------------ NOTIFY ------------------
            
            let results = self.addSession.results
            
            if userAction {
                self.messenger.publish(.history_itemsAdded, payload: self.addSession.addedItems)
            }
            
            // WARNING: Reordering will mean that results will not be in the correct order when this notification
            // is sent out. But currently, it has no impact (Sequencer does not care about results order).
            // Notify observers.
            self.messenger.publish(.playlist_tracksAdded, payload: results)
            
            self.messenger.publish(.playlist_doneAddingTracks, payload: reorderGroupingPlaylists)
            
            // If errors > 0, send a message to UI
            if self.addSession.errors.isNonEmpty {
                self.messenger.publish(.playlist_tracksNotAdded, payload: self.addSession.errors)
            }
            
            self.addSession = nil
        }
    }
    
    /*
        Adds a bunch of files synchronously.
     
        The autoplayOptions argument encapsulates all autoplay options.
     
        The progress argument indicates current progress.
     */
    private func collectTracks(_ files: [URL], filesToIgnoreForHistory: Set<URL> = Set(), _ isRecursiveCall: Bool) {
        
        for file in files {
            
            // Playlists might contain broken file references
            if !file.exists {
                
                addSession.addError(FileNotFoundError(file))
                continue
            }
            
            // Always resolve sym links and aliases before reading the file
            let resolvedFile = file.resolvedURL
            
            if resolvedFile.isDirectory {

                // Directory
                if !isRecursiveCall, !filesToIgnoreForHistory.contains(file) {addSession.addHistoryItem(resolvedFile)}
                expandDirectory(resolvedFile)
                
            } else {
                
                // Single file - playlist or track
                let fileExtension = resolvedFile.lowerCasedExtension

                if SupportedTypes.playlistExtensions.contains(fileExtension) {
                    
                    // Playlist
                    if !isRecursiveCall, !filesToIgnoreForHistory.contains(file) {addSession.addHistoryItem(resolvedFile)}
                    expandPlaylist(resolvedFile)
                    
                } else if SupportedTypes.allAudioExtensions.contains(fileExtension) {
                    
                    // Track
                    if !isRecursiveCall, !filesToIgnoreForHistory.contains(file), !playlist.hasTrackForFile(resolvedFile) {
                        addSession.addHistoryItem(resolvedFile)
                    }
                    
                    addSession.tracks.append(Track(resolvedFile))
                }
            }
        }
    }
    
    private func collectPlaylistTracks(_ tracks: [ImportedPlaylistTrack]) {
        
        for track in tracks {
            
            let file = track.file
            let chapters = track.chapters
            
            // Playlists might contain broken file references
            if !file.exists {
                
                addSession.addError(FileNotFoundError(file))
                continue
            }
            
            // Always resolve sym links and aliases before reading the file
            let resolvedFile = file.resolvedURL
            
            // Single file - playlist or track
            let fileExtension = resolvedFile.lowerCasedExtension
            
            if SupportedTypes.allAudioExtensions.contains(fileExtension) {
                addSession.tracks.append(Track(resolvedFile, chapters: chapters))
            }
        }
    }

    // Expands a playlist into individual tracks
    private func expandPlaylist(_ playlistFile: URL) {
        
        if let loadedPlaylist = PlaylistIO.loadPlaylist(fromFile: playlistFile) {
            
            addSession.totalTracks += loadedPlaylist.tracks.count - 1
            collectPlaylistTracks(loadedPlaylist.tracks)
        }
    }
    
    // Expands a directory into individual tracks (and subdirectories)
    private func expandDirectory(_ dir: URL) {
        
        if let dirContents = dir.children {
            
            addSession.totalTracks += dirContents.count - 1
            collectTracks(dirContents.sorted(by: URL.ascendingPathComparator), true)
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
                messenger.publish(TrackAddedNotification(trackIndex: result.flatPlaylistResult,
                                                         groupingInfo: result.groupingPlaylistResults, addOperationProgress: progress))
            }
            
            if addSession.autoplayOptions.autoplay {
                
                if addSession.autoplayOptions.autoplayType.equalsOneOf(.beginPlayback, .playFirstAddedTrack) && batchIndex == 0 {
                    autoplay(addSession.autoplayOptions.autoplayType, track, addSession.autoplayOptions.interruptPlayback)
                    
                } else if addSession.autoplayOptions.autoplayType == .playSpecificTrack, track.file == addSession.autoplayOptions.fileToPlay {
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
        let resolvedFile = file.resolvedURL
        
        // If track exists, return it
        if let foundTrack = playlist.findTrackByFile(resolvedFile) {
            return foundTrack
        }
        
        // Track doesn't exist yet, need to add it
        
        // If the file points to an invalid location, throw an error
        guard resolvedFile.exists else {throw FileNotFoundError(resolvedFile)}
        
        // Load display info
        let track = Track(resolvedFile)
        trackReader.loadPlaylistMetadata(for: track)
        
        // Non-nil result indicates success
        guard let result = self.playlist.addTrack(track) else {return nil}
            
        let trackAddedNotification = TrackAddedNotification(trackIndex: result.flatPlaylistResult, groupingInfo: result.groupingPlaylistResults, addOperationProgress: TrackAddOperationProgress(tracksAdded: 1, totalTracks: 1))
        
        messenger.publish(trackAddedNotification)
        messenger.publish(.history_itemsAdded, payload: [resolvedFile])
        
        self.messenger.publish(.playlist_tracksAdded, payload: [result])
        
        return track
    }
    
    // Performs autoplay, by delegating a playback request to the player
    private func autoplay(_ autoplayType: AutoplayCommandType, _ track: Track, _ interruptPlayback: Bool) {
        
        switch autoplayType {
            
        case .beginPlayback:
            
            messenger.publish(AutoplayCommandNotification(type: .beginPlayback))
            
        case .playFirstAddedTrack:
            
            messenger.publish(AutoplayCommandNotification(type: .playFirstAddedTrack, interruptPlayback: interruptPlayback, candidateTrack: track))
                              
        case .playSpecificTrack:
            
            messenger.publish(AutoplayCommandNotification(type: .playSpecificTrack, interruptPlayback: interruptPlayback, candidateTrack: track))
        }
    }
    
    func removeTracks(_ indexes: IndexSet) {
        
        let results: TrackRemovalResults = playlist.removeTracks(indexes)
        messenger.publish(.playlist_tracksRemoved, payload: results)
    }
    
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ groupType: GroupType) {
        
        let results: TrackRemovalResults = playlist.removeTracksAndGroups(tracks, groups, groupType)
        messenger.publish(.playlist_tracksRemoved, payload: results)
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
        messenger.publish(.playlist_tracksReordered, payload: results)
        return results
    }
    
    func clear() {
        
        playlist.clear()
        messenger.publish(.playlist_cleared)
    }
    
    func sort(_ sort: Sort, _ playlistType: PlaylistType) {
        
        let results = playlist.sort(sort, playlistType)
        messenger.publish(.playlist_sorted, payload: results)
    }
    
    // MARK: Message handling
    
    func appLaunched(_ filesToOpen: [URL]) {
        
        // Check if any launch parameters were specified
        if filesToOpen.isNonEmpty {
            
            // Launch parameters specified, override playlist saved state and add file paths in params to playlist
            if playlistPreferences.openWithAddMode == .replace {
                
                clear()
                addFiles_async(filesToOpen, 
                               AutoplayOptions(autoplay: playbackPreferences.autoplayAfterOpeningTracks),
                               userAction: true)
                
            } else {
                
                let filesToAdd: [URL]
                var rememberedFiles: [URL] = []
                var reorderGroupingPlaylists: Bool = false
                var autoplayOptions: AutoplayOptions = AutoplayOptions(autoplay: playbackPreferences.autoplayAfterOpeningTracks, autoplayType: .playSpecificTrack, fileToPlay: filesToOpen[0])
                
                switch playlistPreferences.playlistOnStartup {
                    
                case .rememberFromLastAppLaunch:
                    
                    rememberedFiles = persistentState?.tracks?.map {URL(fileURLWithPath: $0)} ?? []
                    reorderGroupingPlaylists = true
                    
                case .loadFile:
                    
                    if let playlistFile: URL = playlistPreferences.playlistFile {
                        rememberedFiles = [playlistFile]
                    }
                    
                case .loadFolder:
                    
                    if let folder: URL = playlistPreferences.tracksFolder {
                        rememberedFiles = [folder]
                    }
                    
                case .empty:
                    
                    autoplayOptions = AutoplayOptions(autoplay: playbackPreferences.autoplayAfterOpeningTracks)
                }
                
                filesToAdd = rememberedFiles + filesToOpen
                
                // Ignore remembered tracks for history, but do consider the new ones for history.
                addFiles_async(filesToAdd, 
                               filesToIgnoreForHistory: Set(rememberedFiles),
                               autoplayOptions,
                               userAction: true,
                               reorderGroupingPlaylists: reorderGroupingPlaylists)
            }

        } else if playlistPreferences.playlistOnStartup == .rememberFromLastAppLaunch,
                  let tracks = self.persistentState?.tracks?.map({URL(fileURLWithPath: $0)}) {

            // No launch parameters specified, load playlist saved state if "Remember state from last launch" preference is selected
            addFiles_async(tracks, 
                           AutoplayOptions(autoplay: playbackPreferences.autoplayOnStartup),
                           userAction: false,
                           reorderGroupingPlaylists: true)
            
        } else if playlistPreferences.playlistOnStartup == .loadFile,
                  let playlistFile: URL = playlistPreferences.playlistFile {
            
            addFiles_async([playlistFile], 
                           AutoplayOptions(autoplay: playbackPreferences.autoplayOnStartup),
                           userAction: false)
            
        } else if playlistPreferences.playlistOnStartup == .loadFolder,
                  let folder: URL = playlistPreferences.tracksFolder {
            
            addFiles_async([folder], 
                           AutoplayOptions(autoplay: playbackPreferences.autoplayOnStartup),
                           userAction: false)
        }
    }
    
    func appReopened(_ notification: AppReopenedNotification) {
        
        if !notification.isDuplicateNotification, playlistPreferences.openWithAddMode == .replace {
            clear()
        }
        
        let autoplayEnabled = (!notification.isDuplicateNotification) && playbackPreferences.autoplayAfterOpeningTracks
        let interruptPlayback = playbackPreferences.autoplayAfterOpeningOption == .always
        
        // When a duplicate notification is sent, don't autoplay ! Otherwise, always autoplay.
        addFiles_async(notification.filesToOpen, AutoplayOptions(autoplay: autoplayEnabled, autoplayType: .playFirstAddedTrack,
                                                                 interruptPlayback: interruptPlayback))
    }
}

///
/// Encapsulates all autoplay options.
///
fileprivate class AutoplayOptions {
    
    // Whether or not autoplay is requested
    var autoplay: Bool
    
    // Whether or not existing track playback should be interrupted, to perform autoplay
    var interruptPlayback: Bool
    
    // Whether or not the first added track should be selected for playback.
    // If false, the first track in the playlist will play.
    var autoplayType: AutoplayCommandType
    
    var fileToPlay: URL?
    
    init(autoplay: Bool,
         autoplayType: AutoplayCommandType = .beginPlayback,
         fileToPlay: URL? = nil,
         interruptPlayback: Bool = true) {
        
        self.autoplay = autoplay
        self.autoplayType = autoplayType
        self.fileToPlay = fileToPlay
        self.interruptPlayback = interruptPlayback
    }
}

///
/// Keeps track of the incremental progress of a single operation of adding
/// tracks to the playlist.
///
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

///
/// A batch of tracks (indexes) to add to the playlist.
///
typealias AddBatch = ClosedRange<Int>
