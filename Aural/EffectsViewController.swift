/*
    View controller for the Effects panel containing controls that alter the sound output (i.e. controls that affect the audio graph)
 */

import Cocoa

class EffectsViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber {
    
    // The constituent views, one for each effects unit
    
    private lazy var eqView: NSView = ViewFactory.getEQView()
    private lazy var pitchView: NSView = ViewFactory.getPitchView()
    private lazy var timeView: NSView = ViewFactory.getTimeView()
    private lazy var reverbView: NSView = ViewFactory.getReverbView()
    private lazy var delayView: NSView = ViewFactory.getDelayView()
    private lazy var filterView: NSView = ViewFactory.getFilterView()
    private lazy var recorderView: NSView = ViewFactory.getRecorderView()
    
    // Tab view and its buttons
    
    @IBOutlet weak var fxTabView: NSTabView!
    
    @IBOutlet weak var eqTabViewButton: NSButton!
    @IBOutlet weak var pitchTabViewButton: MultiImageButton!
    @IBOutlet weak var timeTabViewButton: MultiImageButton!
    @IBOutlet weak var reverbTabViewButton: MultiImageButton!
    @IBOutlet weak var delayTabViewButton: MultiImageButton!
    @IBOutlet weak var filterTabViewButton: MultiImageButton!
    @IBOutlet weak var recorderTabViewButton: MultiImageButton!
    
    private var fxTabViewButtons: [NSButton]?
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    convenience init() {
        self.init(nibName: "Effects", bundle: Bundle.main)!
    }
    
    override func viewDidLoad() {
        
        let appState = ObjectGraph.getUIAppState()

        initEQ(appState)
        initPitch(appState)
        initTime(appState)
        initReverb(appState)
        initDelay(appState)
        initFilter(appState)
        initRecorder()
        initTabGroup()
        
        SyncMessenger.subscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.showEffectsUnitTab], subscriber: self)
    }
    
    private func initEQ(_ appState: UIAppState) {
        
        fxTabView.tabViewItem(at: 0).view?.addSubview(eqView)
        (eqTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = true
    }
    
    private func initPitch(_ appState: UIAppState) {
        
        fxTabView.tabViewItem(at: 1).view?.addSubview(pitchView)
        
        pitchTabViewButton.offStateImage = Images.imgPitchOff
        pitchTabViewButton.onStateImage = Images.imgPitchOn
        
        updatePitchUnitState(!appState.pitchBypass)
    }
    
    private func updatePitchUnitState(_ active: Bool) {
        
        pitchTabViewButton.image = active ? pitchTabViewButton.onStateImage : pitchTabViewButton.offStateImage
        (pitchTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = active
    }
    
    private func initTime(_ appState: UIAppState) {
        
        fxTabView.tabViewItem(at: 2).view?.addSubview(timeView)
        
        timeTabViewButton.offStateImage = Images.imgTimeOff
        timeTabViewButton.onStateImage = Images.imgTimeOn
        
        updateTimeUnitState(!appState.timeBypass)
    }
    
    private func updateTimeUnitState(_ active: Bool) {
        
        timeTabViewButton.image = active ? timeTabViewButton.onStateImage : timeTabViewButton.offStateImage
        (timeTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = active
    }
    
    private func initReverb(_ appState: UIAppState) {
        
        fxTabView.tabViewItem(at: 3).view?.addSubview(reverbView)
        
        reverbTabViewButton.offStateImage = Images.imgReverbOff
        reverbTabViewButton.onStateImage = Images.imgReverbOn
        
        updateReverbUnitState(!appState.reverbBypass)
    }
    
    private func updateReverbUnitState(_ active: Bool) {
        
        reverbTabViewButton.image = active ? reverbTabViewButton.onStateImage : reverbTabViewButton.offStateImage
        (reverbTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = active
    }
    
    private func initDelay(_ appState: UIAppState) {
        
        fxTabView.tabViewItem(at: 4).view?.addSubview(delayView)
        
        delayTabViewButton.offStateImage = Images.imgDelayOff
        delayTabViewButton.onStateImage = Images.imgDelayOn
        
        updateDelayUnitState(!appState.delayBypass)
    }
    
    private func updateDelayUnitState(_ active: Bool) {
        
        delayTabViewButton.image = active ? delayTabViewButton.onStateImage : delayTabViewButton.offStateImage
        (delayTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = active
    }
    
    private func initFilter(_ appState: UIAppState) {
        
        fxTabView.tabViewItem(at: 5).view?.addSubview(filterView)
        
        filterTabViewButton.offStateImage = Images.imgFilterOff
        filterTabViewButton.onStateImage = Images.imgFilterOn
        
        updateFilterUnitState(!appState.filterBypass)
    }
    
    private func updateFilterUnitState(_ active: Bool) {
        
        filterTabViewButton.image = active ? filterTabViewButton.onStateImage : filterTabViewButton.offStateImage
        (filterTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = active
    }
    
    private func initRecorder() {
        
        fxTabView.tabViewItem(at: 6).view?.addSubview(recorderView)
    
        recorderTabViewButton.offStateImage = Images.imgRecorderOff
        recorderTabViewButton.onStateImage = Images.imgRecorderOn
        recorderTabViewButton.image = recorderTabViewButton.offStateImage
    }
    
    private func updateRecorderUnitState(_ active: Bool) {
        
        recorderTabViewButton.image = active ? recorderTabViewButton.onStateImage : recorderTabViewButton.offStateImage
        (recorderTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = active
    }
    
    private func initTabGroup() {
        
        fxTabViewButtons = [eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton, delayTabViewButton, filterTabViewButton, recorderTabViewButton]
        
        // Set tab view button highlight colors and refresh
        
        for btn in fxTabViewButtons! {
            
            (btn.cell as! EffectsUnitButtonCell).highlightColor = (btn === recorderTabViewButton ? Colors.tabViewRecorderButtonHighlightColor : Colors.tabViewEffectsButtonHighlightColor)
            
            btn.needsDisplay = true
        }
        
        // Select EQ tab view by default
        tabViewAction(eqTabViewButton)
    }
    
    // Helper function to switch the tab group to a particular view
    @IBAction func tabViewAction(_ sender: NSButton) {
        fxTabViewButtons!.forEach({$0.state = 0})
        sender.state = 1
        fxTabView.selectTabViewItem(at: sender.tag)
    }
    
    // MARK: Message handling
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let message = notification as? EffectsUnitStateChangedNotification {
            
            switch message.effectsUnit {
                
            case .pitch:    updatePitchUnitState(message.active)
                
            case .time:    updateTimeUnitState(message.active)
                
            case .reverb:    updateReverbUnitState(message.active)
                
            case .delay:    updateDelayUnitState(message.active)
                
            case .filter:    updateFilterUnitState(message.active)
                
            case .recorder:    updateRecorderUnitState(message.active)
                
            default: return
                
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
                
            case .showEffectsUnitTab:
                
                // If the whole effects view is hidden, no need to show the tab
                if (fxTabView.isHidden) {
                    return
                }
                
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
