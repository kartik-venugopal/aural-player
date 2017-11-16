import Cocoa

/*
    Factory for instantiating views from XIBs
 */
struct ViewFactory {
    
    // Top-level sub-views (views displayed directly on the main window)
    
    private static var nowPlayingViewController: NowPlayingViewController = NowPlayingViewController()
    
    private static var playerViewController: PlayerViewController = PlayerViewController()
    
    private static var effectsViewController: EffectsViewController = EffectsViewController()
    
    // Sub-views for the different individual effects units displayed on the Effects panel
    fileprivate struct EffectsViews {
        
        fileprivate static var eqViewController: EQViewController = EQViewController()
        
        fileprivate static var pitchViewController: PitchViewController = PitchViewController()
        
        fileprivate static var timeViewController: TimeViewController = TimeViewController()
        
        fileprivate static var reverbViewController: ReverbViewController = ReverbViewController()
        
        fileprivate static var delayViewController: DelayViewController = DelayViewController()
        
        fileprivate static var filterViewController: FilterViewController = FilterViewController()
        
        fileprivate static var recorderViewController: RecorderViewController = RecorderViewController()
    }
    
    // Sub-views for the different individual playlist views displayed in the playlist window's tab group
    fileprivate struct PlaylistViews {
        
        fileprivate static var tracksViewController: PlaylistTracksViewController = PlaylistTracksViewController()
        
        fileprivate static var artistsViewController: ArtistsPlaylistViewController = ArtistsPlaylistViewController()
    }
    
    // MARK: Accessor functions for the different views
    
    // Returns the view that displays the Now Playing information section
    static func getNowPlayingView() -> NSView {
        return nowPlayingViewController.view
    }
    
    // Returns the view that displays the player
    static func getPlayerView() -> NSView {
        return playerViewController.view
    }
    
    // Returns the view that displays the Effects panel
    static func getEffectsView() -> NSView {
        return effectsViewController.view
    }
    
    // Returns the view that displays the Equalizer effects unit
    static func getEQView() -> NSView {
        return EffectsViews.eqViewController.view
    }
    
    // Returns the view that displays the Pitch effects unit
    static func getPitchView() -> NSView {
        return EffectsViews.pitchViewController.view
    }
    
    // Returns the view that displays the Time effects unit
    static func getTimeView() -> NSView {
        return EffectsViews.timeViewController.view
    }
    
    // Returns the view that displays the Reverb effects unit
    static func getReverbView() -> NSView {
        return EffectsViews.reverbViewController.view
    }
    
    // Returns the view that displays the Delay effects unit
    static func getDelayView() -> NSView {
        return EffectsViews.delayViewController.view
    }
    
    // Returns the view that displays the Filter effects unit
    static func getFilterView() -> NSView {
        return EffectsViews.filterViewController.view
    }
    
    // Returns the view that displays the Recorder unit
    static func getRecorderView() -> NSView {
        return EffectsViews.recorderViewController.view
    }
    
    // Returns the "Tracks" playlist view
    static func getTracksView() -> NSView {
        return PlaylistViews.tracksViewController.view
    }
    
    // Returns the "Artists" playlist view
    static func getArtistsView() -> NSView {
        return PlaylistViews.artistsViewController.view
    }
}
