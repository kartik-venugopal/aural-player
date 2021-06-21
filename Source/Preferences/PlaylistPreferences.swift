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
    
    private typealias Defaults = PreferencesDefaults.Playlist
    
    internal required init(_ dict: [String: Any]) {
        
        viewOnStartup = Defaults.viewOnStartup
        
        if let viewOnStartupOption = dict.enumValue(forKey: Self.key_viewOnStartupOption, ofType: PlaylistViewStartupOptions.self) {
            viewOnStartup.option = viewOnStartupOption
        }
        
        if let viewName = dict[Self.key_viewOnStartupViewName, String.self] {
            viewOnStartup.viewName = viewName
        }
        
        playlistOnStartup = dict.enumValue(forKey: Self.key_playlistOnStartup, ofType: PlaylistStartupOptions.self) ?? Defaults.playlistOnStartup
        
        playlistFile = dict.urlValue(forKey: Self.key_playlistFile) ?? Defaults.playlistFile
        
        showNewTrackInPlaylist = dict[Self.key_showNewTrackInPlaylist, Bool.self] ?? Defaults.showNewTrackInPlaylist
        
        showChaptersList = dict[Self.key_showChaptersList, Bool.self] ?? Defaults.showChaptersList
        
        // If .loadFile selected but no file available to load from, revert back to dict
        if playlistOnStartup == .loadFile && playlistFile == nil {
            
            playlistOnStartup = Defaults.playlistOnStartup
            playlistFile = Defaults.playlistFile
        }
        
        tracksFolder = dict.urlValue(forKey: Self.key_tracksFolder) ?? Defaults.tracksFolder
        
        // If .loadFolder selected but no folder available to load from, revert back to dict
        if playlistOnStartup == .loadFolder && tracksFolder == nil {
            
            playlistOnStartup = Defaults.playlistOnStartup
            tracksFolder = Defaults.tracksFolder
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
