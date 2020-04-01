import Cocoa

/*
    Window controller for the preferences dialog
 */
class PreferencesWindowController: NSWindowController, NSWindowDelegate, ModalDialogDelegate {
    
    @IBOutlet weak var tabView: AuralTabView!
    
    // Sub views
    
    private lazy var playlistPrefsView: PreferencesViewProtocol = ViewFactory.getPlaylistPreferencesView()
    private lazy var playbackPrefsView: PreferencesViewProtocol = ViewFactory.getPlaybackPreferencesView()
    private lazy var soundPrefsView: PreferencesViewProtocol = ViewFactory.getSoundPreferencesView()
    private lazy var viewPrefsView: PreferencesViewProtocol = ViewFactory.getViewPreferencesView()
    private lazy var historyPrefsView: PreferencesViewProtocol = ViewFactory.getHistoryPreferencesView()
    private lazy var controlsPrefsView: PreferencesViewProtocol = ViewFactory.getControlsPreferencesView()
    
    private var subViews: [PreferencesViewProtocol] = []
    
    // Delegate that performs CRUD on user preferences
    private let delegate: PreferencesDelegateProtocol = ObjectGraph.preferencesDelegate
    
    // Cached preferences instance
    private var preferences: Preferences = ObjectGraph.preferencesDelegate.getPreferences()
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override var windowNibName: String? {return "Preferences"}
    
    override func windowDidLoad() {
        
        window?.isMovableByWindowBackground = true
        
        subViews = [playlistPrefsView, playbackPrefsView, soundPrefsView, viewPrefsView, historyPrefsView, controlsPrefsView]
        
        tabView.addViewsForTabs([playlistPrefsView.getView(), playbackPrefsView.getView(), soundPrefsView.getView(), viewPrefsView.getView(), historyPrefsView.getView(), controlsPrefsView.getView()])
        
        super.windowDidLoad()
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
                tabView.showView($0.getView())
                
                return
            }
        })
        
        if (!saveFailed) {
            
            delegate.savePreferences(preferences)
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
    
    func getView() -> NSView
    
    func resetFields(_ preferences: Preferences)
    
    // Throws an exception if the input provided is invalid
    func save(_ preferences: Preferences) throws
}
