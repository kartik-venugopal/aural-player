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
    
    private static let keyPrefix: String = "playlist"
    
    private static let key_viewOnStartupOption: String = "\(PlaylistPreferences.keyPrefix).viewOnStartup.option"
    private static let key_viewOnStartupViewName: String = "\(PlaylistPreferences.keyPrefix).viewOnStartup.view"
    
    private static let key_playlistOnStartup: String = "\(PlaylistPreferences.keyPrefix).playlistOnStartup"
    private static let key_playlistFile: String = "\(PlaylistPreferences.keyPrefix).playlistOnStartup.playlistFile"
    private static let key_tracksFolder: String = "\(PlaylistPreferences.keyPrefix).playlistOnStartup.tracksFolder"
    
    private static let key_showNewTrackInPlaylist: String = "\(PlaylistPreferences.keyPrefix).showNewTrackInPlaylist"
    private static let key_showChaptersList: String = "\(PlaylistPreferences.keyPrefix).showChaptersList"
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        viewOnStartup = PreferencesDefaults.Playlist.viewOnStartup
        
        if let viewOnStartupOption = defaultsDictionary.enumValue(forKey: Self.key_viewOnStartupOption, ofType: PlaylistViewStartupOptions.self) {
            viewOnStartup.option = viewOnStartupOption
        }
        
        if let viewName = defaultsDictionary[Self.key_viewOnStartupViewName, String.self] {
            viewOnStartup.viewName = viewName
        }
        
        playlistOnStartup = defaultsDictionary.enumValue(forKey: Self.key_playlistOnStartup, ofType: PlaylistStartupOptions.self) ?? PreferencesDefaults.Playlist.playlistOnStartup
        
        playlistFile = defaultsDictionary.urlValue(forKey: Self.key_playlistFile) ?? PreferencesDefaults.Playlist.playlistFile
        
        showNewTrackInPlaylist = defaultsDictionary[Self.key_showNewTrackInPlaylist, Bool.self] ?? PreferencesDefaults.Playlist.showNewTrackInPlaylist
        
        showChaptersList = defaultsDictionary[Self.key_showChaptersList, Bool.self] ?? PreferencesDefaults.Playlist.showChaptersList
        
        // If .loadFile selected but no file available to load from, revert back to defaults
        if playlistOnStartup == .loadFile && playlistFile == nil {
            
            playlistOnStartup = PreferencesDefaults.Playlist.playlistOnStartup
            playlistFile = PreferencesDefaults.Playlist.playlistFile
        }
        
        tracksFolder = defaultsDictionary.urlValue(forKey: Self.key_tracksFolder) ?? PreferencesDefaults.Playlist.tracksFolder
        
        // If .loadFolder selected but no folder available to load from, revert back to defaults
        if playlistOnStartup == .loadFolder && tracksFolder == nil {
            
            playlistOnStartup = PreferencesDefaults.Playlist.playlistOnStartup
            tracksFolder = PreferencesDefaults.Playlist.tracksFolder
        }
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.set(playlistOnStartup.rawValue, forKey: Self.key_playlistOnStartup)
        defaults.set(playlistFile?.path, forKey: Self.key_playlistFile)
        defaults.set(tracksFolder?.path, forKey: Self.key_tracksFolder)
        
        defaults.set(viewOnStartup.option.rawValue, forKey: Self.key_viewOnStartupOption)
        defaults.set(viewOnStartup.viewName, forKey: Self.key_viewOnStartupViewName)
        
        defaults.set(showNewTrackInPlaylist, forKey: Self.key_showNewTrackInPlaylist)
        defaults.set(showChaptersList, forKey: Self.key_showChaptersList)
    }
}
