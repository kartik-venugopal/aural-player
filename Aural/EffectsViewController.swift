/*
    View controller for the Effects panel containing controls that alter the sound output (i.e. controls that affect the audio graph)
 */

import Cocoa

class EffectsViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, ConstituentView {
    
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
    
    override var nibName: String? {return "Effects"}
    
    override func viewDidLoad() {

        // Initialize all sub-views
        
        initEQUnit()
        initPitchUnit()
        initTimeUnit()
        initReverbUnit()
        initDelayUnit()
        initFilterUnit()
        initRecorder()
        initTabGroup()
        
        AppModeManager.registerConstituentView(.regular, self)
    }
    
    func activate() {
        initSubscriptions()
    }
    
    func deactivate() {
        print("FX - deact")
        removeSubscriptions()
    }
    
    private func initSubscriptions() {
        
        SyncMessenger.subscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.showEffectsUnitTab], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        SyncMessenger.unsubscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
        SyncMessenger.unsubscribe(actionTypes: [.showEffectsUnitTab], subscriber: self)
    }
    
    private func initEQUnit() {
        
        fxTabView.tabViewItem(at: 0).view?.addSubview(eqView)
        eqTabViewButton.onIf(!graph.isEQBypass())
    }
    
    private func initPitchUnit() {
        
        fxTabView.tabViewItem(at: 1).view?.addSubview(pitchView)
        pitchTabViewButton.onIf(!graph.isPitchBypass())
    }
    
    private func initTimeUnit() {
        
        fxTabView.tabViewItem(at: 2).view?.addSubview(timeView)
        timeTabViewButton.onIf(!graph.isTimeBypass())
    }
    
    private func initReverbUnit() {
        
        fxTabView.tabViewItem(at: 3).view?.addSubview(reverbView)
        reverbTabViewButton.onIf(!graph.isReverbBypass())
    }
    
    private func initDelayUnit() {
        
        fxTabView.tabViewItem(at: 4).view?.addSubview(delayView)
        delayTabViewButton.onIf(!graph.isDelayBypass())
    }
    
    private func initFilterUnit() {
        
        fxTabView.tabViewItem(at: 5).view?.addSubview(filterView)
        filterTabViewButton.onIf(!graph.isFilterBypass())
    }
    
    private func initRecorder() {
        
        fxTabView.tabViewItem(at: 6).view?.addSubview(recorderView)
        recorderTabViewButton.off()
    }
    
    // Helper function that updates the look of a button in response to a unit becoming active or inactive
    private func updateButtonState(_ button: OnOffImageAndTextButton, _ active: Bool) {
        button.onIf(active)
    }
    
    private func initTabGroup() {
        
        fxTabViewButtons = [eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton, delayTabViewButton, filterTabViewButton, recorderTabViewButton]
        
        // Select EQ tab view by default
        tabViewAction(eqTabViewButton)
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
                
            case .eq:    updateButtonState(eqTabViewButton, message.active)
                
            case .pitch:    updateButtonState(pitchTabViewButton, message.active)
                
            case .time:    updateButtonState(timeTabViewButton, message.active)
                
            case .reverb:    updateButtonState(reverbTabViewButton, message.active)
                
            case .delay:    updateButtonState(delayTabViewButton, message.active)
                
            case .filter:    updateButtonState(filterTabViewButton, message.active)
                
            case .recorder:    updateButtonState(recorderTabViewButton, message.active)
                
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
