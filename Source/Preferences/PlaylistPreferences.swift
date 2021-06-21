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
    
    private static let key_viewOnStartupOption: String = "\(keyPrefix).viewOnStartup.option"
    private static let key_viewOnStartupViewName: String = "\(keyPrefix).viewOnStartup.view"
    
    private static let key_playlistOnStartup: String = "\(keyPrefix).playlistOnStartup"
    private static let key_playlistFile: String = "\(keyPrefix).playlistOnStartup.playlistFile"
    private static let key_tracksFolder: String = "\(keyPrefix).playlistOnStartup.tracksFolder"
    
    private static let key_showNewTrackInPlaylist: String = "\(keyPrefix).showNewTrackInPlaylist"
    private static let key_showChaptersList: String = "\(keyPrefix).showChaptersList"
    
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
        
        defaults[Self.key_playlistOnStartup] = playlistOnStartup.rawValue 
        defaults[Self.key_playlistFile] = playlistFile?.path 
        defaults[Self.key_tracksFolder] = tracksFolder?.path 
        
        defaults[Self.key_viewOnStartupOption] = viewOnStartup.option.rawValue 
        defaults[Self.key_viewOnStartupViewName] = viewOnStartup.viewName 
        
        defaults[Self.key_showNewTrackInPlaylist] = showNewTrackInPlaylist 
        defaults[Self.key_showChaptersList] = showChaptersList 
    }
}

// All options for the playlist at startup
enum PlaylistStartupOptions: String {
    
    case empty
    case rememberFromLastAppLaunch
    case loadFile
    case loadFolder
}

// Playlist view on startup preference
class PlaylistViewOnStartup {
    
    var option: PlaylistViewStartupOptions = .rememberFromLastAppLaunch
    
    // This is used only if option == .specific
    var viewName: String = "Tracks"
    
    var viewIndex: Int {
        
        switch viewName {
            
        case "Artists":  return 1;
            
        case "Albums":  return 2;
            
        case "Genres": return 3;
            
        default:    return 0;
            
        }
    }
    
    // NOTE: This is mutable. Potentially unsafe
    static let defaultInstance: PlaylistViewOnStartup = PlaylistViewOnStartup()
}

enum PlaylistViewStartupOptions: String {
    
    case specific
    case rememberFromLastAppLaunch
}
