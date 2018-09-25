import Cocoa

class MasterViewController: NSViewController {
    
    @IBOutlet weak var btnEQBypass: EffectsUnitBypassButton!
    @IBOutlet weak var btnPitchBypass: EffectsUnitBypassButton!
    @IBOutlet weak var btnTimeBypass: EffectsUnitBypassButton!
    @IBOutlet weak var btnReverbBypass: EffectsUnitBypassButton!
    @IBOutlet weak var btnDelayBypass: EffectsUnitBypassButton!
    @IBOutlet weak var btnFilterBypass: EffectsUnitBypassButton!
    
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
 
    override var nibName: String? {return "Master"}
    
    override func viewDidLoad() {
        initControls()
    }
    
    private func initControls() {
        
        btnEQBypass.onIf(!graph.isEQBypass())
        btnPitchBypass.onIf(!graph.isPitchBypass())
        btnTimeBypass.onIf(!graph.isTimeBypass())
        btnReverbBypass.onIf(!graph.isReverbBypass())
        btnDelayBypass.onIf(!graph.isDelayBypass())
        btnFilterBypass.onIf(!graph.isFilterBypass())
    }
    
    @IBAction func eqBypassAction(_ sender: AnyObject) {
        btnEQBypass.toggle()
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.eq, !graph.toggleEQBypass()))
    }
    
    // Activates/deactivates the Pitch effects unit
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        btnPitchBypass.toggle()
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.pitch, !graph.togglePitchBypass()))
    }
    
    // Activates/deactivates the Time stretch effects unit
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.toggleTimeBypass()
        
        btnTimeBypass.toggle()
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.time, !newBypassState))
        
        let newRate = newBypassState ? 1 : graph.getTimeRate().rate
        let playbackRateChangedMsg = PlaybackRateChangedNotification(newRate)
        SyncMessenger.publishNotification(playbackRateChangedMsg)
    }
    
    // Activates/deactivates the Reverb effects unit
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        btnReverbBypass.toggle()
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.reverb, !graph.toggleReverbBypass()))
    }
    
    // Activates/deactivates the Delay effects unit
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        btnDelayBypass.toggle()
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.delay, !graph.toggleDelayBypass()))
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        btnFilterBypass.toggle()
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.filter, !graph.toggleFilterBypass()))
    }
}

/*
 View controller for the Effects panel containing controls that alter the sound output (i.e. controls that affect the audio graph)
 */

//import Cocoa
//
//class EffectsWindowController: NSWindowController, NSWindowDelegate, MessageSubscriber, ActionMessageSubscriber, ConstituentView {
//    
//    // The constituent sub-views, one for each effects unit
//    
//    private let masterView: NSView = ViewFactory.getMasterView()
//    private let eqView: NSView = ViewFactory.getEQView()
//    private let pitchView: NSView = ViewFactory.getPitchView()
//    private let timeView: NSView = ViewFactory.getTimeView()
//    private let reverbView: NSView = ViewFactory.getReverbView()
//    private let delayView: NSView = ViewFactory.getDelayView()
//    private let filterView: NSView = ViewFactory.getFilterView()
//    private let recorderView: NSView = ViewFactory.getRecorderView()
//    
//    // Tab view and its buttons
//    
//    @IBOutlet weak var fxTabView: NSTabView!
//    
//    @IBOutlet weak var masterTabViewButton: OnOffImageAndTextButton!
//    @IBOutlet weak var eqTabViewButton: OnOffImageAndTextButton!
//    @IBOutlet weak var pitchTabViewButton: OnOffImageAndTextButton!
//    @IBOutlet weak var timeTabViewButton: OnOffImageAndTextButton!
//    @IBOutlet weak var reverbTabViewButton: OnOffImageAndTextButton!
//    @IBOutlet weak var delayTabViewButton: OnOffImageAndTextButton!
//    @IBOutlet weak var filterTabViewButton: OnOffImageAndTextButton!
//    @IBOutlet weak var recorderTabViewButton: OnOffImageAndTextButton!
//    
//    private var fxTabViewButtons: [OnOffImageAndTextButton]?
//    
//    // Delegate that alters the audio graph
//    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
//    
//    private lazy var layoutManager: LayoutManager = ObjectGraph.getLayoutManager()
//    
//    private let preferences: ViewPreferences = ObjectGraph.getPreferencesDelegate().getPreferences().viewPreferences
//    
//    private var theWindow: SnappingWindow {
//        return self.window! as! SnappingWindow
//    }
//    
//    private lazy var mainWindow: NSWindow = WindowFactory.getMainWindow()
//    
//    private lazy var playlistWindow: NSWindow = WindowFactory.getPlaylistWindow()
//    
//    private var snapBottomLocation: NSPoint {
//        return mainWindow.origin.applying(CGAffineTransform.init(translationX: 0, y: -theWindow.height))
//    }
//    
//    private var snapRightLocation: NSPoint {
//        return mainWindow.origin.applying(CGAffineTransform.init(translationX: mainWindow.width, y: mainWindow.height - theWindow.height))
//    }
//    
//    private var snapLeftLocation: NSPoint {
//        return mainWindow.origin.applying(CGAffineTransform.init(translationX: -theWindow.width, y: mainWindow.height - theWindow.height))
//    }
//    
//    override var windowNibName: String? {return "Effects"}
//    
//    override func windowDidLoad() {
//        
//        // Initialize all sub-views
//        addSubViews()
//        
//        AppModeManager.registerConstituentView(.regular, self)
//        theWindow.isMovableByWindowBackground = true
//    }
//    
//    private func addSubViews() {
//        
//        fxTabView.tabViewItem(at: 0).view?.addSubview(masterView)
//        fxTabView.tabViewItem(at: 1).view?.addSubview(eqView)
//        fxTabView.tabViewItem(at: 2).view?.addSubview(pitchView)
//        fxTabView.tabViewItem(at: 3).view?.addSubview(timeView)
//        fxTabView.tabViewItem(at: 4).view?.addSubview(reverbView)
//        fxTabView.tabViewItem(at: 5).view?.addSubview(delayView)
//        fxTabView.tabViewItem(at: 6).view?.addSubview(filterView)
//        fxTabView.tabViewItem(at: 7).view?.addSubview(recorderView)
//        
//        fxTabViewButtons = [masterTabViewButton, eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton, delayTabViewButton, filterTabViewButton, recorderTabViewButton]
//    }
//    
//    func activate() {
//        
//        initUnits()
//        initTabGroup()
//        initSubscriptions()
//    }
//    
//    func deactivate() {
//        
//        removeSubscriptions()
//    }
//    
//    private func initUnits() {
//        
//        eqTabViewButton.onIf(!graph.isEQBypass())
//        pitchTabViewButton.onIf(!graph.isPitchBypass())
//        timeTabViewButton.onIf(!graph.isTimeBypass())
//        reverbTabViewButton.onIf(!graph.isReverbBypass())
//        delayTabViewButton.onIf(!graph.isDelayBypass())
//        filterTabViewButton.onIf(!graph.isFilterBypass())
//        
//        // TODO: This will not always be off (only on app startup)
//        recorderTabViewButton.off()
//    }
//    
//    private func initTabGroup() {
//        
//        // Select EQ tab view by default
//        tabViewAction(masterTabViewButton)
//    }
//    
//    private func initSubscriptions() {
//        
//        SyncMessenger.subscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
//        SyncMessenger.subscribe(actionTypes: [.showEffectsUnitTab], subscriber: self)
//    }
//    
//    private func removeSubscriptions() {
//        
//        SyncMessenger.unsubscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
//        SyncMessenger.unsubscribe(actionTypes: [.showEffectsUnitTab], subscriber: self)
//    }
//    
//    // Switches the tab group to a particular tab
//    @IBAction func tabViewAction(_ sender: NSButton) {
//        
//        // Set sender button state, reset all other button states
//        fxTabViewButtons!.forEach({$0.state = 0})
//        sender.state = 1
//        
//        // Button tag is the tab index
//        fxTabView.selectTabViewItem(at: sender.tag)
//    }
//    
//    func getID() -> String {
//        return self.className
//    }
//    
//    // MARK: Message handling
//    
//    func consumeNotification(_ notification: NotificationMessage) {
//        
//        // Notification that an effect unit's state has changed (active/inactive)
//        if let message = notification as? EffectsUnitStateChangedNotification {
//            
//            // Update the corresponding tab button's state
//            switch message.effectsUnit {
//                
//            case .eq:
//                
//                eqTabViewButton.onIf(message.active)
//                
//            case .pitch:
//                
//                pitchTabViewButton.onIf(message.active)
//                
//            case .time:
//                
//                timeTabViewButton.onIf(message.active)
//                
//            case .reverb:
//                
//                reverbTabViewButton.onIf(message.active)
//                
//            case .delay:
//                
//                delayTabViewButton.onIf(message.active)
//                
//            case .filter:
//                
//                filterTabViewButton.onIf(message.active)
//                
//            case .recorder:
//                
//                recorderTabViewButton.onIf(message.active)
//            }
//        }
//    }
//    
//    // Dummy implementation
//    func processRequest(_ request: RequestMessage) -> ResponseMessage {
//        return EmptyResponse.instance
//    }
//    
//    func consumeMessage(_ message: ActionMessage) {
//        
//        if let message = message as? EffectsViewActionMessage {
//            
//            switch message.actionType {
//                
//            // Action message to switch tabs
//            case .showEffectsUnitTab:
//                
//                switch message.effectsUnit {
//                    
//                case .eq: tabViewAction(eqTabViewButton)
//                    
//                case .pitch: tabViewAction(pitchTabViewButton)
//                    
//                case .time: tabViewAction(timeTabViewButton)
//                    
//                case .reverb: tabViewAction(reverbTabViewButton)
//                    
//                case .delay: tabViewAction(delayTabViewButton)
//                    
//                case .filter: tabViewAction(filterTabViewButton)
//                    
//                case .recorder: tabViewAction(recorderTabViewButton)
//                    
//                }
//                
//            default: return
//                
//            }
//        }
//    }
//    
//    // MARK - Window delegate functions
//    
//    func windowDidMove(_ notification: Notification) {
//        
//        // Check if movement was user-initiated (flag on window)
//        if !theWindow.userMovingWindow {
//            return
//        }
//        
//        var snapped = false
//        
//        if preferences.snapToWindows {
//            
//            // First check if window can be snapped to another app window
//            snapped = UIUtils.checkForSnapToWindow(theWindow, mainWindow)
//            
//            if (!snapped) && layoutManager.isShowingPlaylist() {
//                snapped = UIUtils.checkForSnapToWindow(theWindow, playlistWindow)
//            }
//        }
//        
//        if preferences.snapToScreen && !snapped {
//            
//            // If window doesn't need to be snapped to another window, check if it needs to be snapped to the visible frame
//            UIUtils.checkForSnapToVisibleFrame(theWindow)
//        }
//    }
//}
//
//// Enumeration of all the effects units
//enum EffectsUnit {
//    
//    case eq
//    case pitch
//    case time
//    case reverb
//    case delay
//    case filter
//    case recorder
//}
