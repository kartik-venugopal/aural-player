import Cocoa

/*
    Window controller for the preferences dialog
 */
class PreferencesWindowController: NSWindowController, NSWindowDelegate, ModalDialogDelegate {
    
    @IBOutlet weak var tabView: NSTabView!
    
    // Tab view buttons
    
    @IBOutlet weak var btnPlaybackPrefs: NSButton!
    @IBOutlet weak var btnPlaylistPrefs: NSButton!
    @IBOutlet weak var btnSoundPrefs: NSButton!
    @IBOutlet weak var btnViewPrefs: NSButton!
    @IBOutlet weak var btnHistoryPrefs: NSButton!
    @IBOutlet weak var btnControlsPrefs: NSButton!
    
    private var tabViewButtons: [NSButton] = []
    
    // Sub views
    
    private lazy var playlistPrefsView: PreferencesViewProtocol = ViewFactory.getPlaylistPreferencesView()
    private lazy var playbackPrefsView: PreferencesViewProtocol = ViewFactory.getPlaybackPreferencesView()
    private lazy var soundPrefsView: PreferencesViewProtocol = ViewFactory.getSoundPreferencesView()
    private lazy var viewPrefsView: PreferencesViewProtocol = ViewFactory.getViewPreferencesView()
    private lazy var historyPrefsView: PreferencesViewProtocol = ViewFactory.getHistoryPreferencesView()
    private lazy var controlsPrefsView: PreferencesViewProtocol = ViewFactory.getControlsPreferencesView()
    
    private var subViews: [PreferencesViewProtocol] = []
    
    // Delegate that performs CRUD on user preferences
    private let delegate: PreferencesDelegateProtocol = ObjectGraph.getPreferencesDelegate()
    
    // Cached preferences instance
    private var preferences: Preferences = ObjectGraph.getPreferencesDelegate().getPreferences()
    
    convenience init() {
        self.init(windowNibName: "Preferences")
    }
    
    override func windowDidLoad() {
        
        window?.titlebarAppearsTransparent = true
        window?.isMovableByWindowBackground = true
        
        tabViewButtons = [btnPlaybackPrefs, btnPlaylistPrefs, btnSoundPrefs, btnViewPrefs, btnHistoryPrefs, btnControlsPrefs]
        subViews = [playlistPrefsView, playbackPrefsView, soundPrefsView, viewPrefsView, historyPrefsView, controlsPrefsView]
        
        tabView.tabViewItem(at: 0).view?.addSubview(playlistPrefsView.getView())
        tabView.tabViewItem(at: 1).view?.addSubview(playbackPrefsView.getView())
        tabView.tabViewItem(at: 2).view?.addSubview(soundPrefsView.getView())
        tabView.tabViewItem(at: 3).view?.addSubview(viewPrefsView.getView())
        tabView.tabViewItem(at: 4).view?.addSubview(historyPrefsView.getView())
        tabView.tabViewItem(at: 5).view?.addSubview(controlsPrefsView.getView())
        
        tabView.tabViewItems.forEach({$0.view?.subviews.first?.setFrameOrigin(NSPoint.zero)})
        
        super.windowDidLoad()
    }
    
    func showDialog() {
     
        // Force loading of the window if it hasn't been loaded yet (only once)
        if (!self.isWindowLoaded) {
            _ = self.window!
        }
        
        resetPreferencesFields()
        
        // Select the playlist prefs tab
        tabViewAction(btnPlaylistPrefs)
        
        UIUtils.showModalDialog(window!)
    }
    
    private func resetPreferencesFields() {
        subViews.forEach({$0.resetFields(preferences)})
    }
    
    @IBAction func tabViewAction(_ sender: NSButton) {
        
        tabViewButtons.forEach({$0.state = 0})
        
        sender.state = 1
        tabView.selectTabViewItem(at: sender.tag)
    }
        
    @IBAction func savePreferencesAction(_ sender: Any) {
        
        subViews.forEach({$0.save(preferences)})
        delegate.savePreferences(preferences)
        
        UIUtils.dismissModalDialog()
    }
    
    @IBAction func cancelPreferencesAction(_ sender: Any) {
        UIUtils.dismissModalDialog()
    }
}

protocol PreferencesViewProtocol {
    
    func getView() -> NSView
    
    func resetFields(_ preferences: Preferences)
    
    func save(_ preferences: Preferences)
}

// Int to Bool conversion
extension Bool {
    init<T: Integer>(_ num: T) {
        self.init(num != 0)
    }
}
