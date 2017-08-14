import Foundation

// All options for the volume at startup
enum VolumeStartupOptions: String {
    
    case rememberFromLastAppLaunch
    case specific
}

// All options for the playlist at startup
enum PlaylistStartupOptions: String {
    
    case empty
    case rememberFromLastAppLaunch
}

// All options for the view at startup
enum ViewStartupOptions: String {
    
    case specific
    case rememberFromLastAppLaunch
}

// All types of views
enum ViewTypes: String {
    
    case defaultView
    case playlistOnly
    case effectsOnly
    case compact
    
    var description: String {
        
        switch self {
        case .defaultView: return "Default (playlist and effects)"
        case .playlistOnly: return "Playlist only"
        case .effectsOnly: return "Effects only"
        case .compact: return "Compact"
        }
    }
    
    static let allValues: [ViewTypes] = [defaultView, playlistOnly, effectsOnly, compact]
}

// View on startup preference
class ViewOnStartup {
    
    var option: ViewStartupOptions = .rememberFromLastAppLaunch
    
    // This is used only if option == .specific
    var viewType: ViewTypes = .defaultView
    
    // TODO: This is mutable. Potentially unsafe
    static let defaultInstance: ViewOnStartup = ViewOnStartup()
}
