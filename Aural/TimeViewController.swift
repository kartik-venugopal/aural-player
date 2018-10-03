import Cocoa

/*
    View controller for the Time effects unit
 */
class TimeViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, StringInputClient {
    
    // Time controls
    @IBOutlet weak var btnTimeBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnShiftPitch: NSButton!
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var timeOverlapSlider: NSSlider!
    
    @IBOutlet weak var lblTimeStretchRateValue: NSTextField!
    @IBOutlet weak var lblPitchShiftValue: NSTextField!
    @IBOutlet weak var lblTimeOverlapValue: NSTextField!
    
    // Presets menu
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    
    private lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    override var nibName: String? {return "Time"}
    
    override func viewDidLoad() {
        
        initControls()
        
        SyncMessenger.subscribe(messageTypes: [.saveTimeUserPresetRequest, .effectsUnitStateChangedNotification, .applyTimePreset], subscriber: self)
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(actionTypes: [.increaseRate, .decreaseRate, .setRate], subscriber: self)
    }
    
    private func initControls() {
        
        btnTimeBypass.stateFunction = {
            () -> EffectsUnitState in
            
            return self.graph.getTimeState()
        }
        btnTimeBypass.updateState()
        
        btnShiftPitch.state = graph.isTimePitchShift() ? 1 : 0
        updatePitchShift()
        
        let rate = graph.getTimeRate()
        timeSlider.floatValue = rate.rate
        lblTimeStretchRateValue.stringValue = rate.rateString
        
        let overlap = graph.getTimeOverlap()
        timeOverlapSlider.floatValue = overlap.overlap
        lblTimeOverlapValue.stringValue = overlap.overlapString
        
        // Initialize the menu with user-defined presets
        TimePresets.userDefinedPresets.forEach({presetsMenu.insertItem(withTitle: $0.name, at: 0)})
        
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    // Activates/deactivates the Time stretch effects unit
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.toggleTimeState() != .active
        btnTimeBypass.updateState()
        
        let newRate = newBypassState ? 1 : timeSlider.floatValue
        let playbackRateChangedMsg = PlaybackRateChangedNotification(newRate)
        SyncMessenger.publishNotification(playbackRateChangedMsg)
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.master))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.eq))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.pitch))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.time))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.reverb))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.delay))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.filter))
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
        
        // Get preset definition
        let preset = TimePresets.presetByName(presetsMenu.titleOfSelectedItem!)
        applyPreset(preset)
    }
    
    private func applyPreset(_ preset: TimePreset) {
        
        lblTimeStretchRateValue.stringValue = graph.setTimeStretchRate(preset.rate)
        timeSlider.floatValue = preset.rate
        
        lblTimeOverlapValue.stringValue = graph.setTimeOverlap(preset.overlap)
        timeOverlapSlider.floatValue = preset.overlap
        
        btnShiftPitch.state = preset.pitchShift ? 1 : 0
        if (preset.pitchShift != graph.isTimePitchShift()) {
            _ = graph.toggleTimePitchShift()
        }
        updatePitchShift()
        
        // TODO: Revisit this
        if (preset.state != graph.getTimeState()) {
            timeBypassAction(self)
        }
        
        // Don't select any of the items
        presetsMenu.selectItem(at: -1)
    }
    
    // Displays a popover to allow the user to name the new custom preset
    @IBAction func savePresetAction(_ sender: AnyObject) {
        
        userPresetsPopover.show(btnSavePreset, NSRectEdge.minY)
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        WindowState.mainWindow.orderFront(self)
    }
    
    // Actually saves the new user-defined preset
    private func saveUserPreset(_ request: SaveUserPresetRequest) {
        
        TimePresets.addUserDefinedPreset(request.presetName, graph.getTimeState(), timeSlider.floatValue, timeOverlapSlider.floatValue, btnShiftPitch.state == 1)
        
        // Add a menu item for the new preset, at the top of the menu
        presetsMenu.insertItem(withTitle: request.presetName, at: 0)
    }
    
    private func showTimeTab() {
        SyncMessenger.publishActionMessage(EffectsViewActionMessage(.showEffectsUnitTab, .time))
    }
    
    // Sets the playback rate to a specific value
    private func setRate(_ rate: Float) {
        
        // Ensure unit is activated
        if graph.getTimeState() != .active {
            
            _ = graph.toggleTimeState()
            btnTimeBypass.updateState()
            SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.time))
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
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.time))
        
        timeSlider.floatValue = rateInfo.rate
        lblTimeStretchRateValue.stringValue = rateInfo.rateString
        updatePitchShift()
        btnTimeBypass.on()
        
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
        
        if let message = notification as? EffectsUnitStateChangedNotification {
            
            if message.effectsUnit == .time {
                btnTimeBypass.updateState()
            }
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        let message = message as! AudioGraphActionMessage
        
        switch message.actionType {
            
        case .increaseRate: increaseRate()
            
        case .decreaseRate: decreaseRate()
            
        case .setRate: setRate(message.value!)
            
        default: return
            
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if request.messageType == .applyTimePreset {
            
            if let applyPresetRequest = request as? ApplyEffectsPresetRequest {
                
                if let timeState = applyPresetRequest.preset as? TimePreset {
                    
                    print("Applying Time preset: ", timeState.name)
                    applyPreset(timeState)
                }
            }
        }
        
        return EmptyResponse.instance
    }
    
    // MARK - StringInputClient functions
    
    func getInputPrompt() -> String {
        return "Enter a new preset name:"
    }
    
    func getDefaultValue() -> String? {
        return "<New Time preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let valid = !TimePresets.presetWithNameExists(string)
        
        if (!valid) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        
        TimePresets.addUserDefinedPreset(string, graph.getTimeState(), timeSlider.floatValue, timeOverlapSlider.floatValue, btnShiftPitch.state == 1)
        
        // Add a menu item for the new preset, at the top of the menu
        presetsMenu.insertItem(withTitle: string, at: 0)
    }
}
