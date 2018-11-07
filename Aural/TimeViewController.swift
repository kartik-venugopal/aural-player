import Cocoa

/*
    View controller for the Time effects unit
 */
class TimeViewController: NSViewController, NSMenuDelegate, MessageSubscriber, ActionMessageSubscriber, StringInputClient {
    
    // Time controls
    @IBOutlet weak var btnTimeBypass: EffectsUnitTriStateBypassButton!
    
    @IBOutlet weak var timeSlider: EffectsUnitSlider!
    @IBOutlet weak var timeOverlapSlider: EffectsUnitSlider!
    
    @IBOutlet weak var btnShiftPitch: NSButton!
    
    @IBOutlet weak var lblTimeStretchRateValue: NSTextField!
    @IBOutlet weak var lblPitchShiftValue: NSTextField!
    @IBOutlet weak var lblTimeOverlapValue: NSTextField!
    
    // Presets menu
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    
    private lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    private var timePresets: TimePresets = ObjectGraph.getAudioGraphDelegate().timePresets
    
    override var nibName: String? {return "Time"}
    
    override func viewDidLoad() {
        
        oneTimeSetup()
        initControls()
        
        SyncMessenger.subscribe(messageTypes: [.saveTimeUserPresetRequest, .effectsUnitStateChangedNotification], subscriber: self)
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(actionTypes: [.increaseRate, .decreaseRate, .setRate, .updateEffectsView], subscriber: self)
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all custom presets
        while !presetsMenu.item(at: 0)!.isSeparatorItem {
            presetsMenu.removeItem(at: 0)
        }
        
        // Re-initialize the menu with user-defined presets
        timePresets.userDefinedPresets.forEach({presetsMenu.insertItem(withTitle: $0.name, at: 0)})
        
        // Don't select any items from the EQ presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    private func oneTimeSetup() {
        
        let stateFunction = {
            () -> EffectsUnitState in
            return self.graph.getTimeState()
        }
        
        btnTimeBypass.stateFunction = stateFunction
        [timeSlider, timeOverlapSlider].forEach({$0?.stateFunction = stateFunction})
    }
    
    private func initControls() {
        
        btnTimeBypass.updateState()
        [timeSlider, timeOverlapSlider].forEach({$0?.updateState()})
        
        btnShiftPitch.onIf(graph.isTimePitchShift())
        updatePitchShift()
        
        let rate = graph.getTimeRate()
        timeSlider.floatValue = rate.rate
        lblTimeStretchRateValue.stringValue = rate.rateString
        
        let overlap = graph.getTimeOverlap()
        timeOverlapSlider.floatValue = overlap.overlap
        lblTimeOverlapValue.stringValue = overlap.overlapString
        
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    // Activates/deactivates the Time stretch effects unit
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.toggleTimeState() != .active
        btnTimeBypass.updateState()
        [timeSlider, timeOverlapSlider].forEach({$0?.updateState()})
        
        let newRate = newBypassState ? 1 : timeSlider.floatValue
        let playbackRateChangedMsg = PlaybackRateChangedNotification(newRate)
        SyncMessenger.publishNotification(playbackRateChangedMsg)
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
    }
    
    // Toggles the "pitch shift" option of the Time stretch effects unit
    @IBAction func shiftPitchAction(_ sender: AnyObject) {
        
        _ = graph.toggleTimePitchShift()
        updatePitchShift()
    }
    
    // Updates the playback rate value
    @IBAction func timeStretchAction(_ sender: AnyObject) {
        
        lblTimeStretchRateValue.stringValue = graph.setTimeStretchRate(timeSlider.floatValue)
        updatePitchShift()
        
        // If the unit is active, publish a notification that the playback rate has changed. Other UI elements may need to be updated as a result.
        if (graph.getTimeState() == .active) {
            SyncMessenger.publishNotification(PlaybackRateChangedNotification(timeSlider.floatValue))
        }
    }
    
    // Applies a preset to the effects unit
    @IBAction func timePresetsAction(_ sender: AnyObject) {
        graph.applyTimePreset(presetsMenu.titleOfSelectedItem!)
        initControls()
    }
    
    // Displays a popover to allow the user to name the new custom preset
    @IBAction func savePresetAction(_ sender: AnyObject) {
        
        userPresetsPopover.show(btnSavePreset, NSRectEdge.minY)
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        WindowState.mainWindow.orderFront(self)
    }
    
    private func showTimeTab() {
        SyncMessenger.publishActionMessage(EffectsViewActionMessage(.showEffectsUnitTab, .time))
    }
    
    // Sets the playback rate to a specific value
    private func setRate(_ rate: Float) {
        
        // Ensure unit is activated
        // TODO: Move this to AudioGraph ???
        if graph.getTimeState() != .active {
            
            _ = graph.toggleTimeState()
            btnTimeBypass.updateState()
            [timeSlider, timeOverlapSlider].forEach({$0?.updateState()})
            
            SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
        }
        
        lblTimeStretchRateValue.stringValue = graph.setTimeStretchRate(rate)
        timeSlider.floatValue = rate
        updatePitchShift()
        
        showTimeTab()
        
        SyncMessenger.publishNotification(PlaybackRateChangedNotification(rate))
    }
    
    // Increases the playback rate by a certain preset increment
    private func increaseRate() {
        rateChange(graph.increaseRate())
    }
    
    // Decreases the playback rate by a certain preset decrement
    private func decreaseRate() {
        rateChange(graph.decreaseRate())
    }
    
    // Changes the playback rate to a specific value
    private func rateChange(_ rateInfo: (rate: Float, rateString: String)) {
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
        
        timeSlider.floatValue = rateInfo.rate
        lblTimeStretchRateValue.stringValue = rateInfo.rateString
        
        updatePitchShift()
        btnTimeBypass.on()
        [timeSlider, timeOverlapSlider].forEach({$0?.updateState()})
        
        showTimeTab()
        
        SyncMessenger.publishNotification(PlaybackRateChangedNotification(rateInfo.rate))
    }
    
    // Updates the Overlap parameter of the Time stretch effects unit
    @IBAction func timeOverlapAction(_ sender: Any) {
        lblTimeOverlapValue.stringValue = graph.setTimeOverlap(timeOverlapSlider.floatValue)
    }
    
    // Updates the label that displays the pitch shift value
    private func updatePitchShift() {
        lblPitchShiftValue.stringValue = graph.getTimePitchShift()
    }
    
    func getID() -> String {
        return self.className
    }

    // MARK: Message handling
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if notification is EffectsUnitStateChangedNotification {
            btnTimeBypass.updateState()
            [timeSlider, timeOverlapSlider].forEach({$0?.updateState()})
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let message = message as? AudioGraphActionMessage {
        
            switch message.actionType {
                
            case .increaseRate: increaseRate()
                
            case .decreaseRate: decreaseRate()
                
            case .setRate: setRate(message.value!)
                
            default: return
                
            }
            
        } else if message.actionType == .updateEffectsView {
            
            let msg = message as! EffectsViewActionMessage
            if msg.effectsUnit == .master || msg.effectsUnit == .time {
                initControls()
            }
        }
    }
    
    // MARK - StringInputClient functions
    
    func getInputPrompt() -> String {
        return "Enter a new preset name:"
    }
    
    func getDefaultValue() -> String? {
        return "<New Time preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let valid = !timePresets.presetWithNameExists(string)
        
        if (!valid) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        
        graph.saveTimePreset(string)
        
        // Add a menu item for the new preset, at the top of the menu
        presetsMenu.insertItem(withTitle: string, at: 0)
    }
}
