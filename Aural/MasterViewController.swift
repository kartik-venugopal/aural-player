import Cocoa

class MasterViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, StringInputClient {
    
    @IBOutlet weak var btnMasterBypass: EffectsUnitBypassButton!
    
    @IBOutlet weak var btnEQBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnPitchBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnTimeBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnReverbBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnDelayBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnFilterBypass: EffectsUnitTriStateBypassButton!
    
    // Presets menu
    @IBOutlet weak var masterPresets: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    
    private lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
 
    override var nibName: String? {return "Master"}
    
    override func viewDidLoad() {
        
        initControls()
        SyncMessenger.subscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.enableEffects, .disableEffects], subscriber: self)
    }
    
    private func initControls() {
        
        btnEQBypass.stateFunction = {
            () -> EffectsUnitState in
            
            return self.graph.getEQState()
        }
        
        btnPitchBypass.stateFunction = {
            () -> EffectsUnitState in
            
            return self.graph.getPitchState()
        }

        btnTimeBypass.stateFunction = {
            () -> EffectsUnitState in
            
            return self.graph.getTimeState()
        }
        
        btnReverbBypass.stateFunction = {
            () -> EffectsUnitState in
            
            return self.graph.getReverbState()
        }
        
        btnDelayBypass.stateFunction = {
            () -> EffectsUnitState in
            
            return self.graph.getDelayState()
        }
        
        btnFilterBypass.stateFunction = {
            () -> EffectsUnitState in
            
            return self.graph.getFilterState()
        }

        updateButtons()
        
        // Initialize the menu with user-defined presets
        MasterPresets.userDefinedPresets.forEach({masterPresets.insertItem(withTitle: $0.name, at: 0)})
        
        // Don't select any items from the EQ presets menu
        masterPresets.selectItem(at: -1)
    }
    
    @IBAction func masterBypassAction(_ sender: AnyObject) {
        
        // Toggle the master bypass state (simple on/off)
        _ = graph.toggleMasterBypass()
        updateButtons()
    }
    
    @IBAction func masterPresetsAction(_ sender: AnyObject) {
        
        let preset = MasterPresets.presetByName(masterPresets.titleOfSelectedItem!)!

        _ = SyncMessenger.publishRequest(ApplyEffectsPresetRequest(.applyEQPreset, preset.eq))

        _ = SyncMessenger.publishRequest(ApplyEffectsPresetRequest(.applyPitchPreset, preset.pitch))
        
        _ = SyncMessenger.publishRequest(ApplyEffectsPresetRequest(.applyTimePreset, preset.time))
        
        _ = SyncMessenger.publishRequest(ApplyEffectsPresetRequest(.applyReverbPreset, preset.reverb))
        
        _ = SyncMessenger.publishRequest(ApplyEffectsPresetRequest(.applyDelayPreset, preset.delay))
        
        _ = SyncMessenger.publishRequest(ApplyEffectsPresetRequest(.applyFilterPreset, preset.filter))
        
        updateButtons()
        
        // Don't select any of the items
        masterPresets.selectItem(at: -1)
    }
    
    // Displays a popover to allow the user to name the new custom preset
    @IBAction func savePresetAction(_ sender: AnyObject) {
        
        userPresetsPopover.show(btnSavePreset, NSRectEdge.minY)
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        WindowState.mainWindow.orderFront(self)
    }
    
    @IBAction func eqBypassAction(_ sender: AnyObject) {
        
        _ = graph.toggleEQState()
        updateButtons()
    }
    
    // Activates/deactivates the Pitch effects unit
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        
        _ = graph.togglePitchState()
        updateButtons()
    }
    
    private func updateButtons() {
        
        btnMasterBypass.onIf(!graph.isMasterBypass())
        
        // Update the bypass buttons for the effects units
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
        
        [btnEQBypass, btnPitchBypass, btnTimeBypass, btnReverbBypass, btnDelayBypass, btnFilterBypass].forEach({$0?.updateState()})
    }
    
    // Activates/deactivates the Time stretch effects unit
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.toggleTimeState() != .active
        
        let newRate = newBypassState ? 1 : graph.getTimeRate().rate
        SyncMessenger.publishNotification(PlaybackRateChangedNotification(newRate))
        
        updateButtons()
    }
    
    // Activates/deactivates the Reverb effects unit
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        
        _ = graph.toggleReverbState()
        updateButtons()
    }
    
    // Activates/deactivates the Delay effects unit
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        
        _ = graph.toggleDelayState()
        updateButtons()
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
        _ = graph.toggleFilterState()
        updateButtons()
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if notification is EffectsUnitStateChangedNotification {
            
            btnMasterBypass.onIf(!graph.isMasterBypass())
            [btnEQBypass, btnPitchBypass, btnTimeBypass, btnReverbBypass, btnDelayBypass, btnFilterBypass].forEach({$0?.updateState()})
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if message is AudioGraphActionMessage {
            masterBypassAction(self)
        }
    }
    
    // MARK - StringInputClient functions
    
    func getInputPrompt() -> String {
        return "Enter a new preset name:"
    }
    
    func getDefaultValue() -> String? {
        return "<New Master preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let valid = !MasterPresets.presetWithNameExists(string)
        
        if (!valid) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new Master preset name and saves the new preset
    func acceptInput(_ string: String) {
        
        let dummyPresetName = "masterPreset_" + string
        
        // EQ state
        let eqState = graph.getEQState()
        let eqBands = graph.getEQBands()
        let eqGlobalGain = graph.getEQGlobalGain()
        
        let eqPreset = EQPreset(dummyPresetName, eqState, eqBands, eqGlobalGain, false)
        
        // Pitch state
        let pitchState = graph.getPitchState()
        let pitch = graph.getPitch().pitch
        let pitchOverlap = graph.getPitchOverlap().overlap
        
        let pitchPreset = PitchPreset(dummyPresetName, pitchState, pitch, pitchOverlap, false)
        
        // Time state
        let timeState = graph.getTimeState()
        let rate = graph.getTimeRate().rate
        let timeOverlap = graph.getTimeOverlap().overlap
        let timePitchShift = graph.isTimePitchShift()
        
        let timePreset = TimePreset(dummyPresetName, timeState, rate, timeOverlap, timePitchShift, false)
        
        // Reverb state
        let reverbState = graph.getReverbState()
        let space = graph.getReverbSpace()
        let reverbAmount = graph.getReverbAmount().amount
        
        let reverbPreset = ReverbPreset(dummyPresetName, reverbState, space, reverbAmount, false)
        
        // Delay state
        let delayState = graph.getDelayState()
        let delayTime = graph.getDelayTime().time
        let delayAmount = graph.getDelayAmount().amount
        let cutoff = graph.getDelayLowPassCutoff().cutoff
        let feedback = graph.getDelayFeedback().percent
        
        let delayPreset = DelayPreset(dummyPresetName, delayState, delayAmount, delayTime, feedback, cutoff, false)
        
        // Filter state
        let filterState = graph.getFilterState()
        let bassBand = graph.getFilterBassBand()
        let midBand = graph.getFilterMidBand()
        let trebleBand = graph.getFilterTrebleBand()
        
        let filterPreset = FilterPreset(dummyPresetName, filterState, Double(bassBand.min)...Double(bassBand.max), Double(midBand.min)...Double(midBand.max), Double(trebleBand.min)...Double(trebleBand.max), false)
        
        // Save the new preset
        MasterPresets.addUserDefinedPreset(string, eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset)
        
        // Add a menu item for the new preset, at the top of the menu
        masterPresets.insertItem(withTitle: string, at: 0)
    }
}
