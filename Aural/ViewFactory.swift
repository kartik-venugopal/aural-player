import Cocoa

/*
    Factory for instantiating views from XIBs
 */
struct ViewFactory {
    
    // Top-level sub-views (views displayed directly on the main window)
    
    private static let playerViewController: PlayerViewController = PlayerViewController()
    
    private static let barModeNowPlayingViewController: BarModeNowPlayingViewController = BarModeNowPlayingViewController()
    
    private static let barModePlayerViewController: BarModePlayerViewController = BarModePlayerViewController()
    
    // Sub-views for the different individual effects units displayed on the Effects panel
    fileprivate struct EffectsViews {
        
        fileprivate static let masterViewController: MasterViewController = MasterViewController()
        
        fileprivate static let eqViewController: EQViewController = EQViewController()
        
        fileprivate static let pitchViewController: PitchViewController = PitchViewController()
        
        fileprivate static let timeViewController: TimeViewController = TimeViewController()
        
        fileprivate static let reverbViewController: ReverbViewController = ReverbViewController()
        
        fileprivate static let delayViewController: DelayViewController = DelayViewController()
        
        fileprivate static let filterViewController: FilterViewController = FilterViewController()
        
        fileprivate static let recorderViewController: RecorderViewController = RecorderViewController()
    }
    
    // Sub-views for the different individual playlist views displayed in the playlist window's tab group
    fileprivate struct PlaylistViews {
        
        fileprivate static let tracksViewController: TracksPlaylistViewController = TracksPlaylistViewController()
        
        fileprivate static let artistsViewController: ArtistsPlaylistViewController = ArtistsPlaylistViewController()
        
        fileprivate static let albumsViewController: AlbumsPlaylistViewController = AlbumsPlaylistViewController()
        
        fileprivate static let genresViewController: GenresPlaylistViewController = GenresPlaylistViewController()
        
        fileprivate static let contextMenuController: PlaylistContextMenuController = PlaylistContextMenuController()
    }
    
    // Sub-views for the different individual playlist views displayed in the playlist window's tab group
    fileprivate struct PreferencesViews {
        
        fileprivate static let playlistPreferencesViewController: PlaylistPreferencesViewController = PlaylistPreferencesViewController()
        
        fileprivate static let playbackPreferencesViewController: PlaybackPreferencesViewController = PlaybackPreferencesViewController()
        
        fileprivate static let soundPreferencesViewController: SoundPreferencesViewController = SoundPreferencesViewController()
        
        fileprivate static let viewPreferencesViewController: ViewPreferencesViewController = ViewPreferencesViewController()
        
        fileprivate static let historyPreferencesViewController: HistoryPreferencesViewController = HistoryPreferencesViewController()
        
        fileprivate static let controlsPreferencesViewController: ControlsPreferencesViewController = ControlsPreferencesViewController()
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
    
    // Sub-views for the different individual editor views
    fileprivate struct EditorViews {
        
        fileprivate static let bookmarksEditorViewController: BookmarksEditorViewController = BookmarksEditorViewController()
        
        fileprivate static let favoritesEditorViewController: FavoritesEditorViewController = FavoritesEditorViewController()
        
        fileprivate static let layoutsEditorViewController: LayoutsEditorViewController = LayoutsEditorViewController()
        
        fileprivate static let effectsPresetsEditorViewController: EffectsPresetsEditorViewController = EffectsPresetsEditorViewController()
        
        fileprivate static let masterPresetsEditorViewController: MasterPresetsEditorViewController = MasterPresetsEditorViewController()
        
        fileprivate static let eqPresetsEditorViewController: EQPresetsEditorViewController = EQPresetsEditorViewController()
        
        fileprivate static let pitchPresetsEditorViewController: PitchPresetsEditorViewController = PitchPresetsEditorViewController()
        
        fileprivate static let timePresetsEditorViewController: TimePresetsEditorViewController = TimePresetsEditorViewController()
        
        fileprivate static let reverbPresetsEditorViewController: ReverbPresetsEditorViewController = ReverbPresetsEditorViewController()
        
        fileprivate static let delayPresetsEditorViewController: DelayPresetsEditorViewController = DelayPresetsEditorViewController()
        
        fileprivate static let filterPresetsEditorViewController: FilterPresetsEditorViewController = FilterPresetsEditorViewController()
    }
    
    // Returns the view that displays the player
    static func getPlayerView() -> NSView {
        return playerViewController.view
    }
    
    static func getMainWindowMouseTrackingView() -> MouseTrackingView {
        return WindowFactory.getMainWindow().contentView as! MouseTrackingView
    }
    
    // Returns the view that displays the Equalizer effects unit
    static func getMasterView() -> NSView {
        return EffectsViews.masterViewController.view
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
    
    static func getBookmarksEditorView() -> NSView {
        return EditorViews.bookmarksEditorViewController.view
    }
    
    static func getFavoritesEditorView() -> NSView {
        return EditorViews.favoritesEditorViewController.view
    }
    
    static func getLayoutsEditorView() -> NSView {
        return EditorViews.layoutsEditorViewController.view
    }
    
    static func getEffectsPresetsEditorView() -> NSView {
        return EditorViews.effectsPresetsEditorViewController.view
    }
    
    static func getMasterPresetsEditorView() -> NSView {
        return EditorViews.masterPresetsEditorViewController.view
    }
    
    static func getEQPresetsEditorView() -> NSView {
        return EditorViews.eqPresetsEditorViewController.view
    }
    
    static func getPitchPresetsEditorView() -> NSView {
        return EditorViews.pitchPresetsEditorViewController.view
    }
    
    static func getTimePresetsEditorView() -> NSView {
        return EditorViews.timePresetsEditorViewController.view
    }
    
    static func getReverbPresetsEditorView() -> NSView {
        return EditorViews.reverbPresetsEditorViewController.view
    }
    
    static func getDelayPresetsEditorView() -> NSView {
        return EditorViews.delayPresetsEditorViewController.view
    }
    
    static func getFilterPresetsEditorView() -> NSView {
        return EditorViews.filterPresetsEditorViewController.view
    }
}
