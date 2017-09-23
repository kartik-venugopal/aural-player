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
    
    // NOTE: This is mutable. Potentially unsafe
    static let defaultInstance: ViewOnStartup = ViewOnStartup()
}

// Window location on startup preference
class WindowLocationOnStartup {
    
    var option: WindowLocationOptions = .rememberFromLastAppLaunch
    
    // This is used only if option == .specific
    var windowLocation: WindowLocations = .center
    
    // NOTE: This is mutable. Potentially unsafe
    static let defaultInstance: WindowLocationOnStartup = WindowLocationOnStartup()
}

// All options for the window location at startup
enum WindowLocationOptions: String {
    
    case rememberFromLastAppLaunch
    case specific
}

// Enumeration of possible startup window locations
enum WindowLocations: String {
    
    case center
    case topLeft
    case topCenter
    case topRight
    case leftCenter
    case rightCenter
    case bottomLeft
    case bottomCenter
    case bottomRight
    
    static let allValues: [WindowLocations] = [center, topLeft, topCenter, topRight, leftCenter, rightCenter, bottomLeft, bottomCenter, bottomRight]
    
    var description: String {
        return StringUtils.splitCamelCaseWord(rawValue, false)
    }
    
    static func fromDescription(_ description: String) -> WindowLocations {
        return WindowLocations(rawValue: StringUtils.camelCase(description)) ?? .center
    }
}
