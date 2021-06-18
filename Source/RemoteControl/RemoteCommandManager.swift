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
    
    override init() {
        
        super.init()
        
        // TODO: This will depend on user preferences.
        
        // Register all relevant commands and enable them.
        
        [cmdCenter.playCommand, cmdCenter.pauseCommand, cmdCenter.togglePlayPauseCommand].forEach {
            $0.addTarget(self, action: #selector(self.handleTogglePlayPause))
        }
        
        cmdCenter.previousTrackCommand.addTarget(self, action: #selector(self.handlePreviousTrack(_:)))
        cmdCenter.nextTrackCommand.addTarget(self, action: #selector(self.handleNextTrack(_:)))
        cmdCenter.stopCommand.addTarget(self, action: #selector(self.handleStop(_:)))

        [cmdCenter.playCommand, cmdCenter.pauseCommand, cmdCenter.togglePlayPauseCommand, cmdCenter.previousTrackCommand,
         cmdCenter.nextTrackCommand, cmdCenter.stopCommand].forEach {
            
            $0.isEnabled = true
        }
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
}
