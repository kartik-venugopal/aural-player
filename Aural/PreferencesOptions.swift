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
    
    var option: ViewStartupOptions = .specific
    
    // This is used only if option == .specific
    var layoutName: String = "Vertical full stack"
    // Can I do this with WindowLayoutPresets.verticalFullStack.rawValue ? Dependency problem ?
    
    // NOTE: This is mutable. Potentially unsafe
    static let defaultInstance: LayoutOnStartup = LayoutOnStartup()
}

enum ScrollSensitivity: String {
    
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

enum TranscoderPersistenceOptions: String {
    
    case save
    case delete
}

enum EagerTranscodingOptions: String {
    
    case allFiles
    case predictive
}
