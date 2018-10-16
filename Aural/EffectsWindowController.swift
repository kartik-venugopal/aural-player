/*
 View controller for the Effects panel containing controls that alter the sound output (i.e. controls that affect the audio graph)
 */

import Cocoa

class EffectsWindowController: NSWindowController, NSWindowDelegate, MessageSubscriber, ActionMessageSubscriber, ConstituentView {

    // The constituent sub-views, one for each effects unit

    private let masterView: NSView = ViewFactory.getMasterView()
    private let eqView: NSView = ViewFactory.getEQView()
    private let pitchView: NSView = ViewFactory.getPitchView()
    private let timeView: NSView = ViewFactory.getTimeView()
    private let reverbView: NSView = ViewFactory.getReverbView()
    private let delayView: NSView = ViewFactory.getDelayView()
    private let filterView: NSView = ViewFactory.getFilterView()
    private let recorderView: NSView = ViewFactory.getRecorderView()

    // Tab view and its buttons

    @IBOutlet weak var fxTabView: NSTabView!

    @IBOutlet weak var masterTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var eqTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var pitchTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var timeTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var reverbTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var delayTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var filterTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var recorderTabViewButton: EffectsUnitTabButton!

    private var fxTabViewButtons: [EffectsUnitTabButton]?

    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    private let recorder: RecorderDelegateProtocol = ObjectGraph.getRecorderDelegate()

    private lazy var layoutManager: LayoutManager = ObjectGraph.getLayoutManager()

    private let preferences: ViewPreferences = ObjectGraph.getPreferencesDelegate().getPreferences().viewPreferences

    private var theWindow: SnappingWindow {
        return self.window! as! SnappingWindow
    }

    private lazy var mainWindow: NSWindow = WindowFactory.getMainWindow()

    private lazy var playlistWindow: NSWindow = WindowFactory.getPlaylistWindow()

    override var windowNibName: String? {return "Effects"}

    override func windowDidLoad() {

        // Initialize all sub-views
        addSubViews()

        AppModeManager.registerConstituentView(.regular, self)
        theWindow.isMovableByWindowBackground = true
    }

    private func addSubViews() {

        fxTabView.tabViewItem(at: 0).view?.addSubview(masterView)
        fxTabView.tabViewItem(at: 1).view?.addSubview(eqView)
        fxTabView.tabViewItem(at: 2).view?.addSubview(pitchView)
        fxTabView.tabViewItem(at: 3).view?.addSubview(timeView)
        fxTabView.tabViewItem(at: 4).view?.addSubview(reverbView)
        fxTabView.tabViewItem(at: 5).view?.addSubview(delayView)
        fxTabView.tabViewItem(at: 6).view?.addSubview(filterView)
        fxTabView.tabViewItem(at: 7).view?.addSubview(recorderView)

        fxTabViewButtons = [masterTabViewButton, eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton, delayTabViewButton, filterTabViewButton, recorderTabViewButton]
        
        masterTabViewButton.stateFunction = {
            () -> EffectsUnitState in
            
            return self.graph.isMasterBypass() ? .bypassed : .active
        }
        
        eqTabViewButton.stateFunction = {
            () -> EffectsUnitState in
            
            return self.graph.getEQState()
        }
        
        pitchTabViewButton.stateFunction = {
            () -> EffectsUnitState in
            
            return self.graph.getPitchState()
        }
        
        timeTabViewButton.stateFunction = {
            () -> EffectsUnitState in
            
            return self.graph.getTimeState()
        }
        
        reverbTabViewButton.stateFunction = {
            () -> EffectsUnitState in
            
            return self.graph.getReverbState()
        }
        
        delayTabViewButton.stateFunction = {
            () -> EffectsUnitState in
            
            return self.graph.getDelayState()
        }
        
        filterTabViewButton.stateFunction = {
            () -> EffectsUnitState in
            
            return self.graph.getFilterState()
        }
        
        recorderTabViewButton.stateFunction = {
            () -> EffectsUnitState in
            
            return self.recorder.isRecording() ? .active : .bypassed
        }
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

        [masterTabViewButton, eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton, delayTabViewButton, filterTabViewButton, recorderTabViewButton].forEach({$0?.updateState()})
    }

    private func initTabGroup() {

        // Select EQ tab view by default
        tabViewAction(masterTabViewButton)
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
        fxTabViewButtons!.forEach({$0.state = convertToNSControlStateValue(0)})
        sender.state = convertToNSControlStateValue(1)

        // Button tag is the tab index
        fxTabView.selectTabViewItem(at: sender.tag)
    }

    func getID() -> String {
        return self.className
    }

    // MARK: Message handling

    func consumeNotification(_ notification: NotificationMessage) {

        // Notification that an effect unit's state has changed (active/inactive)
        if notification is EffectsUnitStateChangedNotification {

            // Update the corresponding tab button's state
            [masterTabViewButton, eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton, delayTabViewButton, filterTabViewButton, recorderTabViewButton].forEach({$0?.updateState()})
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
                    
                case .master: tabViewAction(masterTabViewButton)
                    
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

        var snapped = false

        if preferences.snapToWindows {

            // First check if window can be snapped to another app window
            snapped = UIUtils.checkForSnapToWindow(theWindow, mainWindow)

            if (!snapped) && layoutManager.isShowingPlaylist() {
                snapped = UIUtils.checkForSnapToWindow(theWindow, playlistWindow)
            }
        }

        if preferences.snapToScreen && !snapped {

            // If window doesn't need to be snapped to another window, check if it needs to be snapped to the visible frame
            UIUtils.checkForSnapToVisibleFrame(theWindow)
        }
    }
}

// Enumeration of all the effects units
enum EffectsUnit {

    case master
    case eq
    case pitch
    case time
    case reverb
    case delay
    case filter
    case recorder
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSControlStateValue(_ input: Int) -> NSControl.StateValue {
	return NSControl.StateValue(rawValue: input)
}
