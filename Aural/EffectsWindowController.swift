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
    
    @IBOutlet weak var viewMenuButton: NSPopUpButton!

    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    private let recorder: RecorderDelegateProtocol = ObjectGraph.recorderDelegate

    private lazy var layoutManager: LayoutManager = ObjectGraph.layoutManager

    private let preferences: ViewPreferences = ObjectGraph.preferencesDelegate.getPreferences().viewPreferences

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

//        EffectsViewState.initialize(ObjectGraph.appState.ui)
//        changeTextSize()
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
        
        masterTabViewButton.stateFunction = masterStateFunction
        eqTabViewButton.stateFunction = eqStateFunction
        pitchTabViewButton.stateFunction = pitchStateFunction
        timeTabViewButton.stateFunction = timeStateFunction
        reverbTabViewButton.stateFunction = reverbStateFunction
        delayTabViewButton.stateFunction = delayStateFunction
        filterTabViewButton.stateFunction = filterStateFunction
        recorderTabViewButton.stateFunction = recorderStateFunction
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

        // Select Master tab view by default
//        tabViewAction(masterTabViewButton)
        tabViewAction(eqTabViewButton)
    }

    private func initSubscriptions() {

        SyncMessenger.subscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.showEffectsUnitTab, .changeEffectsTextSize], subscriber: self)
    }

    private func removeSubscriptions() {

        SyncMessenger.unsubscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
        SyncMessenger.unsubscribe(actionTypes: [.showEffectsUnitTab, .changeEffectsTextSize], subscriber: self)
    }

    // Switches the tab group to a particular tab
    @IBAction func tabViewAction(_ sender: NSButton) {

        // Set sender button state, reset all other button states
        
        // TODO: Add a field "isSelected" to the tab button control to distinguish between "state" (on/off) and "selected"
        fxTabViewButtons!.forEach({$0.state = convertToNSControlStateValue(0)})
        sender.state = convertToNSControlStateValue(1)

        // Button tag is the tab index
        fxTabView.selectTabViewItem(at: sender.tag)
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.toggleEffects))
    }
    
    private func changeTextSize() {
        viewMenuButton.font = TextSizes.effectsMenuFont
    }

    var subscriberId: String {
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
        
        if message is TextSizeActionMessage {
            
            changeTextSize()
            return
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

// Convenient accessor for information about the current playlist view
class EffectsViewState {
    
    static var textSize: TextSizeScheme = .normal
    
    static func initialize(_ appState: PlaylistUIState) {
        textSize = appState.textSize
    }
    
    static func persistentState() -> PlaylistUIState {
        
        let state = PlaylistUIState()
        state.textSize = textSize
        
        return state
    }
}

class EffectsViewPopupMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var textSizeNormalMenuItem: NSMenuItem!
    @IBOutlet weak var textSizeLargerMenuItem: NSMenuItem!
    @IBOutlet weak var textSizeLargestMenuItem: NSMenuItem!
    
    private var textSizes: [NSMenuItem] = []
    
    override func awakeFromNib() {
        textSizes = [textSizeNormalMenuItem, textSizeLargerMenuItem, textSizeLargestMenuItem]
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        textSizes.forEach({
            $0.off()
        })
        
        switch EffectsViewState.textSize {
            
        case .normal:   textSizeNormalMenuItem.on()
            
        case .larger:   textSizeLargerMenuItem.on()
            
        case .largest:  textSizeLargestMenuItem.on()
            
        }
    }
    
    @IBAction func changeTextSizeAction(_ sender: NSMenuItem) {
        
        let senderTitle: String = sender.title.lowercased()
        let size = TextSizeScheme(rawValue: senderTitle)!
        
        if TextSizes.effectsScheme != size {
            
            TextSizes.effectsScheme = size
            EffectsViewState.textSize = size
            
             SyncMessenger.publishActionMessage(TextSizeActionMessage(.changeEffectsTextSize, size))
            
        } else {
            print("\nSAME !!!")
        }
    }
}
