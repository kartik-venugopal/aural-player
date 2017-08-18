/*
    Initializes the app, alongside AppDelegate. Takes care of configuring logging, loading all app state from disk, and constructing the critical high level objects in the app's object tree - player, playlist, playerDelegate.
 */

import Foundation

class AppInitializer {
    
    private static var playerDelegate: PlayerDelegate?
    
    private static var appState: AppState?
    
    private static var player: Player?
    
    private static var playlist: Playlist?
    
    private static var initialized: Bool = false
    
    // Make sure all logging is done to the app's log file
    private static func configureLogging() {
        
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = allPaths.first!
        let pathForLog = documentsDirectory + ("/" + AppConstants.logFileName)
        
        freopen(pathForLog.cString(using: String.Encoding.ascii)!, "a+", stderr)
    }
    
    static func initialize() {
        
        configureLogging()
        
        // Load saved player state from app config file, and initialize the player with that state
        appState = AppStateIO.load()
        
        if (appState == nil) {
            appState = AppState.defaults
        }
        
        // Initialize the player
        let preferences = Preferences.instance()
        
        player = Player()
        player!.loadState(appState!.playerState)
        
        if (preferences.volumeOnStartup == .specific) {
            player?.setVolume(preferences.startupVolumeValue)
        }
        
        // Initialize playlist with playback sequence (repeat/shuffle) and track list
        let repeatMode = appState!.playlistState.repeatMode
        let shuffleMode = appState!.playlistState.shuffleMode
        
        playlist = Playlist(repeatMode, shuffleMode)
        
        // Initialize playerDeleage with player, playlist, and app state
        playerDelegate = PlayerDelegate(player!, appState!, playlist!)
        
        initialized = true
    }
    
    static func getPlaylist() -> Playlist {
        
        if (!initialized) {
            initialize()
        }
        
        return playlist!
    }
    
    static func getPlayer() -> Player {
        
        if (!initialized) {
            initialize()
        }
        
        return player!
    }
    
    static func getPlayerDelegate() -> PlayerDelegate {
        
        if (!initialized) {
            initialize()
        }
        
        return playerDelegate!
    }
}
