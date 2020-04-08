import Cocoa

class PlaylistPreferences: PersistentPreferencesProtocol {
    
    var playlistOnStartup: PlaylistStartupOptions
    
    // This will be used only when playlistOnStartup == PlaylistStartupOptions.loadFile
    var playlistFile: URL?
    
    // This will be used only when playlistOnStartup == PlaylistStartupOptions.loadFolder
    var tracksFolder: URL?
    
    var viewOnStartup: PlaylistViewOnStartup
    
    var showNewTrackInPlaylist: Bool
    var showChaptersList: Bool
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        viewOnStartup = PreferencesDefaults.Playlist.viewOnStartup
        
        if let viewOnStartupOptionStr = defaultsDictionary["playlist.viewOnStartup.option"] as? String {
            viewOnStartup.option = PlaylistViewStartupOptions(rawValue: viewOnStartupOptionStr)!
        }
        
        if let viewStr = defaultsDictionary["playlist.viewOnStartup.view"] as? String {
            viewOnStartup.viewName = viewStr
        }
        
        if let playlistOnStartupStr = defaultsDictionary["playlist.playlistOnStartup"] as? String {
            playlistOnStartup = PlaylistStartupOptions(rawValue: playlistOnStartupStr)!
        } else {
            playlistOnStartup = PreferencesDefaults.Playlist.playlistOnStartup
        }
        
        if let playlistFileStr = defaultsDictionary["playlist.playlistOnStartup.playlistFile"] as? String {
            playlistFile = URL(fileURLWithPath: playlistFileStr)
        } else {
            playlistFile = PreferencesDefaults.Playlist.playlistFile
        }
        
        showNewTrackInPlaylist = defaultsDictionary["playlist.showNewTrackInPlaylist"] as? Bool ?? PreferencesDefaults.Playlist.showNewTrackInPlaylist
        
        showChaptersList = defaultsDictionary["playlist.showChaptersList"] as? Bool ?? PreferencesDefaults.Playlist.showChaptersList
        
        // If .loadFile selected but no file available to load from, revert back to defaults
        if (playlistOnStartup == .loadFile && playlistFile == nil) {
            
            playlistOnStartup = PreferencesDefaults.Playlist.playlistOnStartup
            playlistFile = PreferencesDefaults.Playlist.playlistFile
        }
        
        if let tracksFolderStr = defaultsDictionary["playlist.playlistOnStartup.tracksFolder"] as? String {
            tracksFolder = URL(fileURLWithPath: tracksFolderStr)
        } else {
            tracksFolder = PreferencesDefaults.Playlist.tracksFolder
        }
        
        // If .loadFolder selected but no folder available to load from, revert back to defaults
        if (playlistOnStartup == .loadFolder && tracksFolder == nil) {
            
            playlistOnStartup = PreferencesDefaults.Playlist.playlistOnStartup
            tracksFolder = PreferencesDefaults.Playlist.tracksFolder
        }
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.set(playlistOnStartup.rawValue, forKey: "playlist.playlistOnStartup")
        defaults.set(playlistFile?.path, forKey: "playlist.playlistOnStartup.playlistFile")
        defaults.set(tracksFolder?.path, forKey: "playlist.playlistOnStartup.tracksFolder")
        
        defaults.set(viewOnStartup.option.rawValue, forKey: "playlist.viewOnStartup.option")
        defaults.set(viewOnStartup.viewName, forKey: "playlist.viewOnStartup.view")
        
        defaults.set(showNewTrackInPlaylist, forKey: "playlist.showNewTrackInPlaylist")
        defaults.set(showChaptersList, forKey: "playlist.showChaptersList")
    }
}
