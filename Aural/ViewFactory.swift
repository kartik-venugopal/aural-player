import Cocoa

/*
    Factory for instantiating views from XIBs
 */
struct ViewFactory {
    
    // Top-level sub-views (views displayed directly on the main window)
    
    private static var nowPlayingViewController: NowPlayingViewController = NowPlayingViewController()
    
    private static var playerViewController: PlayerViewController = PlayerViewController()
    
    private static var barModeNowPlayingViewController: BarModeNowPlayingViewController = BarModeNowPlayingViewController()
    
    private static var barModePlayerViewController: BarModePlayerViewController = BarModePlayerViewController()
    
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
        
        fileprivate static var tracksViewController: TracksPlaylistViewController = TracksPlaylistViewController()
        
        fileprivate static var artistsViewController: ArtistsPlaylistViewController = ArtistsPlaylistViewController()
        
        fileprivate static var albumsViewController: AlbumsPlaylistViewController = AlbumsPlaylistViewController()
        
        fileprivate static var genresViewController: GenresPlaylistViewController = GenresPlaylistViewController()
        
        fileprivate static var contextMenuController: PlaylistContextMenuController = PlaylistContextMenuController()
    }
    
    // Sub-views for the different individual playlist views displayed in the playlist window's tab group
    fileprivate struct PreferencesViews {
        
        fileprivate static var playlistPreferencesViewController: PlaylistPreferencesViewController = PlaylistPreferencesViewController()
        
        fileprivate static var playbackPreferencesViewController: PlaybackPreferencesViewController = PlaybackPreferencesViewController()
        
        fileprivate static var soundPreferencesViewController: SoundPreferencesViewController = SoundPreferencesViewController()
        
        fileprivate static var viewPreferencesViewController: ViewPreferencesViewController = ViewPreferencesViewController()
        
        fileprivate static var historyPreferencesViewController: HistoryPreferencesViewController = HistoryPreferencesViewController()
        
        fileprivate static var controlsPreferencesViewController: ControlsPreferencesViewController = ControlsPreferencesViewController()
    }
    
    fileprivate struct PopoverViews {
        
        // The view that displays detailed track information, when requested by the user
        fileprivate static var detailedTrackInfoPopover: PopoverViewDelegate = {
            return DetailedTrackInfoViewController.create()
        }()
        
        // The view that displays a brief info message when a track is added to or removed from Favorites
        fileprivate static var favoritesPopup: FavoritesPopupViewController = {
            return FavoritesPopupViewController.create()
        }()
        
        fileprivate static var statusBarPopover: StatusBarPopoverViewController = {
            return StatusBarPopoverViewController.create()
        }()
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
    
    // Returns the "Albums" playlist view
    static func getAlbumsView() -> NSView {
        return PlaylistViews.albumsViewController.view
    }
    
    // Returns the "Genres" playlist view
    static func getGenresView() -> NSView {
        return PlaylistViews.genresViewController.view
    }
    
    static func getContextMenu() -> NSMenu {
        return PlaylistViews.contextMenuController.contextMenu
    }
    
    static func getDetailedTrackInfoPopover() -> PopoverViewDelegate {
        return PopoverViews.detailedTrackInfoPopover
    }
    
    static func getFavoritesPopup() -> FavoritesPopupProtocol {
        return PopoverViews.favoritesPopup
    }
    
    static func getPlaylistPreferencesView() -> PreferencesViewProtocol {
        return PreferencesViews.playlistPreferencesViewController
    }
    
    static func getPlaybackPreferencesView() -> PreferencesViewProtocol {
        return PreferencesViews.playbackPreferencesViewController
    }
    
    static func getSoundPreferencesView() -> PreferencesViewProtocol {
        return PreferencesViews.soundPreferencesViewController
    }
    
    static func getViewPreferencesView() -> PreferencesViewProtocol {
        return PreferencesViews.viewPreferencesViewController
    }
    
    static func getHistoryPreferencesView() -> PreferencesViewProtocol {
        return PreferencesViews.historyPreferencesViewController
    }
    
    static func getControlsPreferencesView() -> PreferencesViewProtocol {
        return PreferencesViews.controlsPreferencesViewController
    }
    
    static func getStatusBarPopover() -> StatusBarPopoverViewController {
        return PopoverViews.statusBarPopover
    }
    
    // MARK: Accessors for Bar mode
    
    static func getBarModeNowPlayingView() -> NSView {
        return barModeNowPlayingViewController.view
    }
    
    // Returns the view that displays the player
    static func getBarModePlayerView() -> NSView {
        return barModePlayerViewController.view
    }
}
