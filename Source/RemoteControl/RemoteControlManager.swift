//
//  RemoteControlManager.swift
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
/// Facade for managing everything related to RemoteControl.
///
/// Consists of 2 components:
/// 1 - Remote command manager
/// 2 - Now Playing Info manager
///
@available(OSX 10.12.2, *)
class RemoteControlManager {

    /// Handles registration and handling of remote commands with **MPRemoteCommandCenter**.
    private var remoteCommandManager: RemoteCommandManager
    
    /// Handles updates of currently playing track information with **MPNowPlayingInfoCenter**.
    private var nowPlayingInfoManager: NowPlayingInfoManager
    
    private let preferences: Preferences
    
    var remoteControlPreferences: RemoteControlPreferences {preferences.controlsPreferences.remoteControl}
    var playbackPreferences: PlaybackPreferences {preferences.playbackPreferences}
    
    var isEnabled: Bool {remoteControlPreferences.enabled}
    var trackChangeOrSeekingOption: TrackChangeOrSeekingOptions {remoteControlPreferences.trackChangeOrSeekingOption}
    var seekInterval: Double {Double(playbackPreferences.primarySeekLengthConstant)}
    
    init(playbackInfo: PlaybackInfoDelegateProtocol, audioGraph: AudioGraphDelegateProtocol, sequencer: SequencerInfoDelegateProtocol,
         preferences: Preferences) {
        
        self.remoteCommandManager = RemoteCommandManager()
        
        self.nowPlayingInfoManager = NowPlayingInfoManager(playbackInfo: playbackInfo, audioGraph: audioGraph,
                                                      sequencer: sequencer)
        
        self.preferences = preferences
        
        if isEnabled {
            activate()
        }
    }
    
    /// Activates Remote Control.
    func activate() {
        
        remoteCommandManager.activate(trackChangeOrSeekingOption: trackChangeOrSeekingOption,
                                      seekInterval: seekInterval)
        
        nowPlayingInfoManager.activate()
    }
    
    /// Deactivates Remote Control.
    func deactivate() {
        
        remoteCommandManager.deactivate()
        nowPlayingInfoManager.deactivate()
    }
    
    /// Called in response to Remote Control preferences being updated.
    func preferencesUpdated() {
        
        // Reset the managers by deactivating and then activating them (if enabled). This will
        // force the Control Center UI to refresh properly and reflect the changes.
        
        deactivate()
        
        if isEnabled {
            activate()
        }
    }
    
    /// Updates the seek interval of the skip commands. Called in response to the "Primary Seek Length" playback preference being updated.
    func updateSeekInterval(to newInterval: Double) {
        
        remoteCommandManager.updateSeekInterval(to: newInterval)
        
        if isEnabled && trackChangeOrSeekingOption == .seeking {
            
            // Reset the managers by deactivating and then activating them. This will
            // force the Control Center UI to refresh properly and reflect the changes.
            deactivate()
            activate()
        }
    }
}
