import Cocoa

/*
    Window controller for the preferences dialog
 */
class PreferencesWindowController: NSWindowController, ModalDialogDelegate {
    
    @IBOutlet weak var tabView: AuralTabView!
    
    // Sub views
    
    private lazy var playlistPrefsView: PreferencesViewProtocol = ViewFactory.playlistPreferencesView
    private lazy var playbackPrefsView: PreferencesViewProtocol = ViewFactory.playbackPreferencesView
    private lazy var soundPrefsView: PreferencesViewProtocol = ViewFactory.soundPreferencesView
    private lazy var viewPrefsView: PreferencesViewProtocol = ViewFactory.viewPreferencesView
    private lazy var historyPrefsView: PreferencesViewProtocol = ViewFactory.historyPreferencesView
    private lazy var controlsPrefsView: PreferencesViewProtocol = ViewFactory.controlsPreferencesView
    
    private var subViews: [PreferencesViewProtocol] = []
    
    // Delegate that performs CRUD on user preferences
    private var delegate: PreferencesDelegateProtocol = ObjectGraph.preferencesDelegate
    
    // Cached preferences instance
    private var preferences: Preferences = ObjectGraph.preferencesDelegate.preferences
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override var windowNibName: String? {return "Preferences"}
    
    override func windowDidLoad() {
        
        window?.isMovableByWindowBackground = true
        
        subViews = [playlistPrefsView, playbackPrefsView, soundPrefsView, viewPrefsView, historyPrefsView, controlsPrefsView]
        
        tabView.addViewsForTabs([playlistPrefsView.preferencesView, playbackPrefsView.preferencesView, soundPrefsView.preferencesView, viewPrefsView.preferencesView, historyPrefsView.preferencesView, controlsPrefsView.preferencesView])
        
        WindowManager.registerModalComponent(self)
        
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
    
    @IBAction func shiftTabAction(_ sender: Any) {
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
            
            delegate.preferences = preferences
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
