import Cocoa

/*
    Window controller for the preferences dialog
 */
class PreferencesWindowController: NSWindowController, ModalDialogDelegate, Destroyable {
    
    @IBOutlet weak var tabView: AuralTabView!
    
    // Sub views
    
    private let playlistPrefsView: PreferencesViewProtocol = PlaylistPreferencesViewController()
    private let playbackPrefsView: PreferencesViewProtocol = PlaybackPreferencesViewController()
    private let soundPrefsView: PreferencesViewProtocol = SoundPreferencesViewController()
    private let viewPrefsView: PreferencesViewProtocol = ViewPreferencesViewController()
    private let historyPrefsView: PreferencesViewProtocol = HistoryPreferencesViewController()
    private let controlsPrefsView: PreferencesViewProtocol = ControlsPreferencesViewController()
    private let metadataPrefsView: PreferencesViewProtocol = MetadataPreferencesViewController()
    
    private var subViews: [PreferencesViewProtocol] = []
    
    private lazy var preferences: Preferences = ObjectGraph.preferences
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override var windowNibName: String? {"Preferences"}
    
    override func windowDidLoad() {
        
        window?.isMovableByWindowBackground = true
        
        subViews = [playlistPrefsView, playbackPrefsView, soundPrefsView, viewPrefsView, historyPrefsView, controlsPrefsView, metadataPrefsView]
        
        tabView.addViewsForTabs(subViews.map {$0.preferencesView})
        
        WindowManager.instance.registerModalComponent(self)
        
        super.windowDidLoad()
    }
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    func showDialog() -> ModalDialogResponse {
     
        // Force loading of the window if it hasn't been loaded yet (only once)
        if (!self.isWindowLoaded) {
            _ = self.window!
        }
        
        resetPreferencesFields()
        
        // Select the playlist prefs tab
        tabView.selectTabViewItem(at: 0)
        
        UIUtils.showDialog(window!)
        
        return modalDialogResponse
    }
    
    private func resetPreferencesFields() {
        subViews.forEach({$0.resetFields(preferences)})
    }
    
    @IBAction func previousTabAction(_ sender: Any) {
        tabView.previousTab()
    }
    
    @IBAction func nextTabAction(_ sender: Any) {
        tabView.nextTab()
    }
    
    @IBAction func savePreferencesAction(_ sender: Any) {
        
        var saveFailed: Bool = false
        
        subViews.forEach({
            
            do {
                
                try $0.save(preferences)
                
            } catch {
                
                saveFailed = true
                
                // Switch to the tab with the offending view
                tabView.showView($0.preferencesView)
                
                return
            }
        })
        
        if !saveFailed {
            
            preferences.persist()
            modalDialogResponse = .ok
            UIUtils.dismissDialog(self.window!)
        }
    }
    
    @IBAction func cancelPreferencesAction(_ sender: Any) {
        
        modalDialogResponse = .cancel
        UIUtils.dismissDialog(self.window!)
    }
}

protocol PreferencesViewProtocol {
    
    var preferencesView: NSView {get}
    
    func resetFields(_ preferences: Preferences)
    
    // Throws an exception if the input provided is invalid
    func save(_ preferences: Preferences) throws
}
