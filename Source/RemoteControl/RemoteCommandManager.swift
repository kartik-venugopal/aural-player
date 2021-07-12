//
//  RemoteCommandManager.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
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
    
    var changePlaybackPositionCommand: MPChangePlaybackPositionCommand {cmdCenter.changePlaybackPositionCommand}
    
    private var activated: Bool = false
    
    private lazy var messenger = Messenger(for: self)
    
    /// Registers command handlers with the command center.
    func activate(trackChangeOrSeekingOption: TrackChangeOrSeekingOptions, seekInterval: Double) {
        
        // Previous / Next track
        
        previousTrackCommand.removeTarget(self, action: nil)
        nextTrackCommand.removeTarget(self, action: nil)
        
        [previousTrackCommand, nextTrackCommand].forEach {
            $0.isEnabled = trackChangeOrSeekingOption == .trackChange
        }
        
        // Skip backward / forward
        
        [skipBackwardCommand, skipForwardCommand].forEach {
            
            $0.isEnabled = trackChangeOrSeekingOption == .seeking
            $0.removeTarget(self, action: nil)
        }
        
        if trackChangeOrSeekingOption == .trackChange {
            
            previousTrackCommand.addTarget(self, action: #selector(self.handlePreviousTrack(_:)))
            nextTrackCommand.addTarget(self, action: #selector(self.handleNextTrack(_:)))
            
        } else {
            
            skipBackwardCommand.addTarget(self, action: #selector(self.handleSkipBackward(_:)))
            skipForwardCommand.addTarget(self, action: #selector(self.handleSkipForward(_:)))
            
            skipBackwardCommand.preferredIntervals = [NSNumber(value: seekInterval)]
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
        
        activated = true
    }
    
    /// Un-registers command handlers with the command center.
    func deactivate() {
        
        if !activated {return}
        
        [playCommand, pauseCommand, togglePlayPauseCommand, stopCommand, previousTrackCommand, nextTrackCommand,
         skipBackwardCommand, skipForwardCommand, changePlaybackPositionCommand].forEach {
            
            $0.removeTarget(self, action: nil)
            $0.isEnabled = false
         }
        
        activated = false
    }
    
    /// Updates the seek interval of the skip commands.
    func updateSeekInterval(to newInterval: Double) {
        
        skipBackwardCommand.preferredIntervals = [NSNumber(value: newInterval)]
        skipForwardCommand.preferredIntervals = skipBackwardCommand.preferredIntervals
    }
    
    ///
    /// Handles a remote command to toggle between play / pause playback states.
    ///
    /// - Parameter event: An event object containing information about the received command.
    ///
    /// - returns: Status indicating the result of executing the received command.
    ///
    @objc func handleTogglePlayPause(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        messenger.publish(.player_playOrPause)
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
        
        messenger.publish(.player_stop)
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
        
        messenger.publish(.player_previousTrack)
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
        
        messenger.publish(.player_nextTrack)
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
        
        messenger.publish(.player_seekBackward, payload: UserInputMode.discrete)
        return .success
    }
    
    ///
    /// Handles a remote command to skip forward by an interval.
    ///
    /// - Parameter event: An event object containing information about the received command.
    ///
    /// - returns: Status indicating the result of executing the received command.
    ///
    @objc func handleSkipForward(_ event: MPSkipIntervalCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        messenger.publish(.player_seekForward, payload: UserInputMode.discrete)
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
        
        messenger.publish(.player_jumpToTime, payload: event.positionTime)
        return .success
    }
}
