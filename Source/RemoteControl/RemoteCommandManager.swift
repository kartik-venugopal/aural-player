import Foundation
import MediaPlayer

///
/// Manages remote command registration and handling to respond to playback commands from the macOS Control Center or
/// accessories capable of sending remote commands.
///
@available(OSX 10.12.2, *)
class RemoteCommandManager: NSObject {
    
    /// The underlying command center.
    fileprivate let cmdCenter = MPRemoteCommandCenter.shared()
    
    var playCommand: MPRemoteCommand {cmdCenter.playCommand}
    var pauseCommand: MPRemoteCommand {cmdCenter.pauseCommand}
    var togglePlayPauseCommand: MPRemoteCommand {cmdCenter.togglePlayPauseCommand}
    var stopCommand: MPRemoteCommand {cmdCenter.stopCommand}
    
    var previousTrackCommand: MPRemoteCommand {cmdCenter.previousTrackCommand}
    var nextTrackCommand: MPRemoteCommand {cmdCenter.nextTrackCommand}
    
    var skipBackwardCommand: MPSkipIntervalCommand {cmdCenter.skipBackwardCommand}
    var skipForwardCommand: MPSkipIntervalCommand {cmdCenter.skipForwardCommand}
    
    var seekBackwardCommand: MPRemoteCommand {cmdCenter.seekBackwardCommand}
    var seekForwardCommand: MPRemoteCommand {cmdCenter.seekForwardCommand}
    
    var changeRepeatModeCommand: MPChangeRepeatModeCommand {cmdCenter.changeRepeatModeCommand}
    var changeShuffleModeCommand: MPChangeShuffleModeCommand {cmdCenter.changeShuffleModeCommand}
    
    var likeCommand: MPFeedbackCommand {cmdCenter.likeCommand}
    var dislikeCommand: MPFeedbackCommand {cmdCenter.dislikeCommand}
    var bookmarkCommand: MPFeedbackCommand {cmdCenter.bookmarkCommand}
    
    var changePlaybackPositionCommand: MPChangePlaybackPositionCommand {cmdCenter.changePlaybackPositionCommand}
    
    private let preferences: Preferences
    
    private var activated: Bool = false
    
    init(preferences: Preferences) {
        
        self.preferences = preferences
        super.init()
        
        if preferences.controlsPreferences.remoteControl.enabled {
            activateCommandHandlers()
        }
    }
    
    func activateCommandHandlers() {
        
        let remoteControlPrefs = self.preferences.controlsPreferences.remoteControl
        
        // Previous / Next track
        
        previousTrackCommand.removeTarget(self, action: nil)
        nextTrackCommand.removeTarget(self, action: nil)
        
        [previousTrackCommand, nextTrackCommand].forEach {
            $0.isEnabled = remoteControlPrefs.trackChangeOrSeekingOption == .trackChange
        }
        
        // Skip backward / forward
        
        [skipBackwardCommand, skipForwardCommand, seekBackwardCommand, seekForwardCommand].forEach {
            
            $0.isEnabled = remoteControlPrefs.trackChangeOrSeekingOption == .seeking
            $0.removeTarget(self, action: nil)
        }
        
        if remoteControlPrefs.trackChangeOrSeekingOption == .trackChange {
            
            previousTrackCommand.addTarget(self, action: #selector(self.handlePreviousTrack(_:)))
            nextTrackCommand.addTarget(self, action: #selector(self.handleNextTrack(_:)))
            
        } else {
            
            skipBackwardCommand.addTarget(self, action: #selector(self.handleSkipBackward(_:)))
            skipForwardCommand.addTarget(self, action: #selector(self.handleSkipForward(_:)))
            
            seekBackwardCommand.addTarget(self, action: #selector(self.handleSeekBackward(_:)))
            seekForwardCommand.addTarget(self, action: #selector(self.handleSeekForward(_:)))
            
            skipBackwardCommand.preferredIntervals = [NSNumber(value: preferences.playbackPreferences.primarySeekLengthConstant)]
            skipForwardCommand.preferredIntervals = skipBackwardCommand.preferredIntervals
        }
        
        if activated {return}
        
        // Play / Pause
        
        [playCommand, pauseCommand, togglePlayPauseCommand].forEach {
            
            $0.addTarget(self, action: #selector(self.handleTogglePlayPause(_:)))
            $0.isEnabled = true
        }
        
        // Stop
        
        stopCommand.addTarget(self, action: #selector(self.handleStop(_:)))
        stopCommand.isEnabled = true
        
        // Playback position control
        
        changePlaybackPositionCommand.addTarget(self, action: #selector(self.handleChangePlaybackPosition(_:)))
        changePlaybackPositionCommand.isEnabled = true
        
        // Repeat mode control
        
        changeRepeatModeCommand.addTarget(self, action: #selector(self.handleChangeRepeatMode(_:)))
        changeRepeatModeCommand.isEnabled = true
        changeRepeatModeCommand.currentRepeatType = .all
        
        // Shuffle mode control
        
        changeShuffleModeCommand.addTarget(self, action: #selector(self.handleChangeShuffleMode(_:)))
        changeShuffleModeCommand.isEnabled = true
        changeShuffleModeCommand.currentShuffleType = .off
        
        // Feedback commands
        
        likeCommand.addTarget(self, action: #selector(self.handleLike(_:)))
        likeCommand.localizedTitle = "Like"
        likeCommand.localizedShortTitle = "Like"
        likeCommand.isActive = true
        likeCommand.isEnabled = true
        
        dislikeCommand.addTarget(self, action: #selector(self.handleDislike(_:)))
        dislikeCommand.localizedTitle = "Dislike"
        dislikeCommand.localizedShortTitle = "Dislike"
        dislikeCommand.isActive = true
        dislikeCommand.isEnabled = true
        
        bookmarkCommand.addTarget(self, action: #selector(self.handleBookmark(_:)))
        bookmarkCommand.localizedTitle = "Bookmark"
        bookmarkCommand.localizedShortTitle = "Bookmark"
        bookmarkCommand.isActive = true
        bookmarkCommand.isEnabled = true
        
        activated = true
    }
    
    func deactivateCommandHandlers() {
        
        if !activated {return}
        
        [playCommand, pauseCommand, togglePlayPauseCommand, stopCommand, previousTrackCommand, nextTrackCommand,
        skipBackwardCommand, skipForwardCommand, seekBackwardCommand, seekBackwardCommand, changePlaybackPositionCommand,
        changeRepeatModeCommand, changeShuffleModeCommand, likeCommand, dislikeCommand, bookmarkCommand].forEach {
            
            $0.removeTarget(self, action: nil)
            $0.isEnabled = false
        }
        
        activated = false
    }
    
    ///
    /// Handles a remote command to toggle between play / pause playback states.
    ///
    /// - Parameter event: An event object containing information about the received command.
    ///
    /// - returns: Status indicating the result of executing the received command.
    ///
    @objc func handleTogglePlayPause(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        Messenger.publish(.player_playOrPause)
        return .success
    }
    
    ///
    /// Handles a remote command to play the previous track in the current playback sequence.
    ///
    /// - Parameter event: An event object containing information about the received command.
    ///
    /// - returns: Status indicating the result of executing the received command.
    ///
    @objc func handlePreviousTrack(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        Messenger.publish(.player_previousTrack)
        return .success
    }
    
    ///
    /// Handles a remote command to stop playback.
    ///
    /// - Parameter event: An event object containing information about the received command.
    ///
    /// - returns: Status indicating the result of executing the received command.
    ///
    @objc func handleStop(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        Messenger.publish(.player_stop)
        return .success
    }
    
    ///
    /// Handles a remote command to play the next track in the current playback sequence.
    ///
    /// - Parameter event: An event object containing information about the received command.
    ///
    /// - returns: Status indicating the result of executing the received command.
    ///
    @objc func handleNextTrack(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        Messenger.publish(.player_nextTrack)
        return .success
    }
    
    ///
    /// Handles a remote command to skip backward by an interval.
    ///
    /// - Parameter event: An event object containing information about the received command.
    ///
    /// - returns: Status indicating the result of executing the received command.
    ///
    @objc func handleSkipBackward(_ event: MPSkipIntervalCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        Messenger.publish(.player_seekBackward, payload: UserInputMode.discrete)
        return .success
    }
    
    ///
    /// Handles a remote command to skip backward by an interval.
    ///
    /// - Parameter event: An event object containing information about the received command.
    ///
    /// - returns: Status indicating the result of executing the received command.
    ///
    @objc func handleSkipForward(_ event: MPSkipIntervalCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        Messenger.publish(.player_seekForward, payload: UserInputMode.discrete)
        return .success
    }
    
    ///
    /// Handles a remote command to seek backward.
    ///
    /// - Parameter event: An event object containing information about the received command.
    ///
    /// - returns: Status indicating the result of executing the received command.
    ///
    @objc func handleSeekBackward(_ event: MPSeekCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        Messenger.publish(.player_seekBackward, payload: UserInputMode.discrete)
        return .success
    }

    ///
    /// Handles a remote command to seek forward.
    ///
    /// - Parameter event: An event object containing information about the received command.
    ///
    /// - returns: Status indicating the result of executing the received command.
    ///
    @objc func handleSeekForward(_ event: MPSeekCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        Messenger.publish(.player_seekForward, payload: UserInputMode.discrete)
        return .success
    }
    
    ///
    /// Handles a remote command to jump to a specific playback position.
    ///
    /// - Parameter event: An event object containing information about the received command.
    ///
    /// - returns: Status indicating the result of executing the received command.
    ///
    @objc func handleChangePlaybackPosition(_ event: MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        Messenger.publish(.player_jumpToTime, payload: event.positionTime)
        return .success
    }
    
    @objc func handleChangeRepeatMode(_ event: MPChangeRepeatModeCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        Messenger.publish(.player_setRepeatMode, payload: event.repeatType.toRepeatMode())
        return .success
    }
    
    @objc func handleChangeShuffleMode(_ event: MPChangeShuffleModeCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        Messenger.publish(.player_setShuffleMode, payload: event.shuffleType.toShuffleMode())
        return .success
    }
    
    ///
    /// Handles a remote command to "like" the currently playing track.
    ///
    /// - Parameter event: An event object containing information about the received command.
    ///
    /// - returns: Status indicating the result of executing the received command.
    ///
    @objc func handleLike(_ event: MPFeedbackCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        print("\nLike")
        Messenger.publish(.favoritesList_addOrRemove)
        return .success
    }
    
    @objc func handleDislike(_ event: MPFeedbackCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        print("\nDislike")
        Messenger.publish(.favoritesList_addOrRemove)
        return .success
    }
    
    @objc func handleBookmark(_ event: MPFeedbackCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        print("\nBookmark")
        
        // TODO: This needs to be done without a prompt for bookmark name.
        Messenger.publish(.player_bookmarkPosition)
        return .success
    }
}

@available(OSX 10.12.2, *)
extension MPRepeatType {
    
    func toRepeatMode() -> RepeatMode {
        
        switch self {
        
        case .off:  return .off
            
        case .one:  return .one
            
        case .all:  return .all
            
        @unknown default:   return .off
            
        }
    }
}

@available(OSX 10.12.2, *)
extension MPShuffleType {
    
    func toShuffleMode() -> ShuffleMode {
        
        switch self {
        
        case .off:  return .off
            
        case .collections, .items:  return .on
            
        @unknown default:   return .off
            
        }
    }
}
