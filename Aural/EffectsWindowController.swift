/*
    View controller for the Effects panel containing controls that alter the sound output (i.e. controls that affect the audio graph)
 */

import Cocoa

class EffectsWindowController: NSWindowController, NSWindowDelegate, MessageSubscriber, ActionMessageSubscriber, ConstituentView {
    
    // The constituent sub-views, one for each effects unit
    
    private lazy var eqView: NSView = ViewFactory.getEQView()
    private lazy var pitchView: NSView = ViewFactory.getPitchView()
    private lazy var timeView: NSView = ViewFactory.getTimeView()
    private lazy var reverbView: NSView = ViewFactory.getReverbView()
    private lazy var delayView: NSView = ViewFactory.getDelayView()
    private lazy var filterView: NSView = ViewFactory.getFilterView()
    private lazy var recorderView: NSView = ViewFactory.getRecorderView()
    
    // Tab view and its buttons
    
    @IBOutlet weak var fxTabView: NSTabView!
    
    @IBOutlet weak var eqTabViewButton: OnOffImageAndTextButton!
    @IBOutlet weak var pitchTabViewButton: OnOffImageAndTextButton!
    @IBOutlet weak var timeTabViewButton: OnOffImageAndTextButton!
    @IBOutlet weak var reverbTabViewButton: OnOffImageAndTextButton!
    @IBOutlet weak var delayTabViewButton: OnOffImageAndTextButton!
    @IBOutlet weak var filterTabViewButton: OnOffImageAndTextButton!
    @IBOutlet weak var recorderTabViewButton: OnOffImageAndTextButton!
    
    private var fxTabViewButtons: [OnOffImageAndTextButton]?
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    private var theWindow: SnappingWindow {
        return self.window! as! SnappingWindow
    }
    
    private lazy var mainWindow: NSWindow = WindowFactory.getMainWindow()
    
    private lazy var playlistWindow: NSWindow = WindowFactory.getPlaylistWindow()
    
    private var snapBottomLocation: NSPoint {
        return mainWindow.origin.applying(CGAffineTransform.init(translationX: 0, y: -theWindow.height))
    }
    
    private var snapRightLocation: NSPoint {
        return mainWindow.origin.applying(CGAffineTransform.init(translationX: mainWindow.width, y: mainWindow.height - theWindow.height))
    }
    
    private var snapLeftLocation: NSPoint {
        return mainWindow.origin.applying(CGAffineTransform.init(translationX: -theWindow.width, y: mainWindow.height - theWindow.height))
    }
    
    override var windowNibName: String? {return "Effects"}
    
    override func windowDidLoad() {

        // Initialize all sub-views
        addSubViews()
        
        AppModeManager.registerConstituentView(.regular, self)
        theWindow.isMovableByWindowBackground = true
    }
    
    private func addSubViews() {
        
        fxTabView.tabViewItem(at: 0).view?.addSubview(eqView)
        fxTabView.tabViewItem(at: 1).view?.addSubview(pitchView)
        fxTabView.tabViewItem(at: 2).view?.addSubview(timeView)
        fxTabView.tabViewItem(at: 3).view?.addSubview(reverbView)
        fxTabView.tabViewItem(at: 4).view?.addSubview(delayView)
        fxTabView.tabViewItem(at: 5).view?.addSubview(filterView)
        fxTabView.tabViewItem(at: 6).view?.addSubview(recorderView)
        
        fxTabViewButtons = [eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton, delayTabViewButton, filterTabViewButton, recorderTabViewButton]
    }
    
    func activate() {
        
        initUnits()
        initTabGroup()
        initSubscriptions()
    }
    
    func deactivate() {
        
        removeSubscriptions()
    }
    
    private func initUnits() {
        
        eqTabViewButton.onIf(!graph.isEQBypass())
        pitchTabViewButton.onIf(!graph.isPitchBypass())
        timeTabViewButton.onIf(!graph.isTimeBypass())
        reverbTabViewButton.onIf(!graph.isReverbBypass())
        delayTabViewButton.onIf(!graph.isDelayBypass())
        filterTabViewButton.onIf(!graph.isFilterBypass())
        
        // TODO: This will not always be off (only on app startup)
        recorderTabViewButton.off()
    }
    
    private func initTabGroup() {
        
        // Select EQ tab view by default
//        tabViewAction(eqTabViewButton)
        tabViewAction(reverbTabViewButton)
    }
    
    private func initSubscriptions() {
        
        SyncMessenger.subscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.showEffectsUnitTab], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        SyncMessenger.unsubscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
        SyncMessenger.unsubscribe(actionTypes: [.showEffectsUnitTab], subscriber: self)
    }
    
    // Switches the tab group to a particular tab
    @IBAction func tabViewAction(_ sender: NSButton) {
        
        // Set sender button state, reset all other button states
        fxTabViewButtons!.forEach({$0.state = 0})
        sender.state = 1
        
        // Button tag is the tab index
        fxTabView.selectTabViewItem(at: sender.tag)
    }
    
    func getID() -> String {
        return self.className
    }
    
    // MARK: Message handling
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        // Notification that an effect unit's state has changed (active/inactive)
        if let message = notification as? EffectsUnitStateChangedNotification {
            
            // Update the corresponding tab button's state
            switch message.effectsUnit {
                
            case .eq:
                
                eqTabViewButton.onIf(message.active)
                
            case .pitch:
                
                pitchTabViewButton.onIf(message.active)
                
            case .time:
                
                timeTabViewButton.onIf(message.active)
                
            case .reverb:
                
                reverbTabViewButton.onIf(message.active)
                
            case .delay:
                
                delayTabViewButton.onIf(message.active)
                
            case .filter:
                
                filterTabViewButton.onIf(message.active)
                
            case .recorder:
                
                recorderTabViewButton.onIf(message.active)
            }
        }
    }
    
    // Dummy implementation
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return EmptyResponse.instance
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let message = message as? EffectsViewActionMessage {
            
            switch message.actionType {
        
            // Action message to switch tabs
            case .showEffectsUnitTab:
                
                switch message.effectsUnit {
                    
                case .eq: tabViewAction(eqTabViewButton)
                    
                case .pitch: tabViewAction(pitchTabViewButton)
                    
                case .time: tabViewAction(timeTabViewButton)
                    
                case .reverb: tabViewAction(reverbTabViewButton)
                    
                case .delay: tabViewAction(delayTabViewButton)
                    
                case .filter: tabViewAction(filterTabViewButton)
                    
                case .recorder: tabViewAction(recorderTabViewButton)
                    
                }
                
            default: return
                
            }
        }
    }
    
    // MARK - Window delegate functions
    
    func windowDidMove(_ notification: Notification) {
        
        // Check if movement was user-initiated (flag on window)
        if !theWindow.userMovingWindow {
            return
        }
        
        let snapped = UIUtils.checkForSnap(theWindow, mainWindow)
        
        if (!snapped) && WindowState.showingPlaylist {
            _ = UIUtils.checkForSnap(theWindow, playlistWindow)
        }
    }
}

// Enumeration of all the effects units
enum EffectsUnit {
    
    case eq
    case pitch
    case time
    case reverb
    case delay
    case filter
    case recorder
}
