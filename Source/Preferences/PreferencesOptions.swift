import Foundation

enum OutputDeviceStartupOptions: String {
    
    case rememberFromLastAppLaunch
    case system
    case specific
}

// Window layout on startup preference
class OutputDeviceOnStartup {
    
    var option: OutputDeviceStartupOptions = .system
    
    // This is used only if option == .specific
    var preferredDeviceName: String? = nil
    var preferredDeviceUID: String? = nil
    
    // NOTE: This is mutable. Potentially unsafe (convert variable into factory method ???)
    static let defaultInstance: OutputDeviceOnStartup = OutputDeviceOnStartup()
}

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

// Possible options for the "autoplay afer adding tracks" user preference
enum AutoplayAfterAddingOptions: String {
    
    case ifNotPlaying
    case always
}

// All options for the view at startup
enum WindowLayoutStartupOptions: String {
    
    case specific
    case rememberFromLastAppLaunch
}

// Window layout on startup preference
class LayoutOnStartup {
    
    var option: WindowLayoutStartupOptions = .rememberFromLastAppLaunch
    
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
