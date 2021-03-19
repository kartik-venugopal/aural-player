import Foundation

// All options for the volume at startup
enum VolumeStartupOptions: String {
    
    case rememberFromLastAppLaunch
    case specific
}

enum EffectsSettingsStartupOptions: String {
    
    case rememberFromLastAppLaunch
    case applyMasterPreset
}

// All options for the playlist at startup
enum PlaylistStartupOptions: String {
    
    case empty
    case rememberFromLastAppLaunch
    case loadFile
    case loadFolder
}

<<<<<<< HEAD:Aural/PreferencesOptions.swift
=======
enum PlaylistViewStartupOptions: String {
    
    case specific
    case rememberFromLastAppLaunch
}

// Playlist view on startup preference
class PlaylistViewOnStartup {
    
    var option: PlaylistViewStartupOptions = .rememberFromLastAppLaunch
    
    // This is used only if option == .specific
    var viewName: String = "Tracks"
    
    var viewIndex: Int {
        
        switch(viewName) {
            
        case "Artists":  return 1;
            
        case "Albums":  return 2;
            
        case "Genres": return 3;
            
        default:    return 0;
            
        }
    }
    
    // NOTE: This is mutable. Potentially unsafe
    static let defaultInstance: PlaylistViewOnStartup = PlaylistViewOnStartup()
}

>>>>>>> upstream/master:Source/Preferences/PreferencesOptions.swift
// Possible options for the "autoplay afer adding tracks" user preference
enum AutoplayAfterAddingOptions: String {
    
    case ifNotPlaying
    case always
}

// All options for the view at startup
enum ViewStartupOptions: String {
    
    case specific
    case rememberFromLastAppLaunch
}

// View on startup preference
class LayoutOnStartup {
    
<<<<<<< HEAD:Aural/PreferencesOptions.swift
    var option: ViewStartupOptions = .specific
=======
    var option: WindowLayoutStartupOptions = .rememberFromLastAppLaunch
>>>>>>> upstream/master:Source/Preferences/PreferencesOptions.swift
    
    // This is used only if option == .specific
    var layoutName: String = ""
    
    // NOTE: This is mutable. Potentially unsafe
    static let defaultInstance: LayoutOnStartup = LayoutOnStartup()
}

enum ScrollSensitivity: String, CaseIterable {
    
    case low
    case medium
    case high
}

enum SkipKeyBehavior: String {
    
    case hybrid
    case trackChangesOnly
    case seekingOnly
}

enum SkipKeyRepeatSpeed: String {
    
    case slow
    case medium
    case fast
}

enum RememberSettingsForTrackOptions: String {
    
    case allTracks
    case individualTracks
}

enum SeekLengthOptions: String {
    
    case constant
    case percentage
}
