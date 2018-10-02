import Cocoa

/*
    View controller for the Pitch effects unit
 */
class PitchViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, StringInputClient {
    
    // Pitch controls
    @IBOutlet weak var btnPitchBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var pitchSlider: NSSlider!
    @IBOutlet weak var pitchOverlapSlider: NSSlider!
    @IBOutlet weak var lblPitchValue: NSTextField!
    @IBOutlet weak var lblPitchOverlapValue: NSTextField!
    
    // Presets menu
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    
    private lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    override var nibName: String? {return "Pitch"}
    
    override func viewDidLoad() {
        
        initControls()
        initSubscriptions()
    }
    
    private func initSubscriptions() {
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.increasePitch, .decreasePitch, .setPitch], subscriber: self)
    }
    
    private func initControls() {
        
        btnPitchBypass.stateFunction = {
            () -> EffectsUnitState in
            
            return self.graph.getPitchState()
        }
        btnPitchBypass.updateState()
        
        let pitch = graph.getPitch()
        pitchSlider.floatValue = pitch.pitch
        lblPitchValue.stringValue = pitch.pitchString
        
        let overlap = graph.getPitchOverlap()
        pitchOverlapSlider.floatValue = overlap.overlap
        lblPitchOverlapValue.stringValue = overlap.overlapString
        
        // Initialize the menu with user-defined presets
        PitchPresets.userDefinedPresets.forEach({presetsMenu.insertItem(withTitle: $0.name, at: 0)})
        
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    // Activates/deactivates the Pitch effects unit
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        
        _ = graph.togglePitchState()
        btnPitchBypass.updateState()
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.master))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.eq))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.pitch))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.time))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.reverb))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.delay))
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.filter))
    }
    
    // Updates the pitch
    @IBAction func pitchAction(_ sender: AnyObject) {
        lblPitchValue.stringValue = graph.setPitch(pitchSlider.floatValue)
    }
    
    private func showPitchTab() {
        SyncMessenger.publishActionMessage(EffectsViewActionMessage(.showEffectsUnitTab, .pitch))
    }
    
    // Sets the pitch to a specific value
    private func setPitch(_ pitch: Float) {
        
        lblPitchValue.stringValue = graph.setPitch(pitch)
        btnPitchBypass.updateState()
        pitchSlider.floatValue = pitch
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.pitch))
        
        // Show the Pitch tab
        showPitchTab()
    }
    
    // Updates the Overlap parameter of the Pitch shift effects unit
    @IBAction func pitchOverlapAction(_ sender: AnyObject) {
        lblPitchOverlapValue.stringValue = graph.setPitchOverlap(pitchOverlapSlider.floatValue)
    }
    
    // Applies a preset to the effects unit
    @IBAction func pitchPresetsAction(_ sender: AnyObject) {
        
        // Get preset definition
        let preset = PitchPresets.presetByName(presetsMenu.titleOfSelectedItem!)
        
        lblPitchValue.stringValue = graph.setPitch(preset.pitch)
        pitchSlider.floatValue = preset.pitch
        
        lblPitchOverlapValue.stringValue = graph.setPitchOverlap(preset.overlap)
        pitchOverlapSlider.floatValue = preset.overlap
        
        // Don't select any of the items
        presetsMenu.selectItem(at: -1)
    }
    
    // Displays a popover to allow the user to name the new custom preset
    @IBAction func savePresetAction(_ sender: AnyObject) {
        
        userPresetsPopover.show(btnSavePreset, NSRectEdge.minY)
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        WindowState.mainWindow.orderFront(self)
    }
    
    // Increases the overall pitch by a certain preset increment
    private func increasePitch() {
        pitchChange(graph.increasePitch())
    }
    
    // Decreases the overall pitch by a certain preset decrement
    private func decreasePitch() {
        pitchChange(graph.decreasePitch())
    }
    
    // Changes the pitch to a specified value
    private func pitchChange(_ pitchInfo: (pitch: Float, pitchString: String)) {
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.pitch))
        
        pitchSlider.floatValue = pitchInfo.pitch
        lblPitchValue.stringValue = pitchInfo.pitchString
        btnPitchBypass.updateState()
        
        // Show the Pitch tab if the Effects panel is shown
        showPitchTab()
    }
    
    func getID() -> String {
        return self.className
    }
    
    // MARK: Message handling
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let message = notification as? EffectsUnitStateChangedNotification {
            
            if message.effectsUnit == .pitch {
                btnPitchBypass.updateState()
            }
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        let message = message as! AudioGraphActionMessage
        
        switch message.actionType {
            
        case .increasePitch: increasePitch()
            
        case .decreasePitch: decreasePitch()
            
        case .setPitch: setPitch(message.value!)
            
        default: return
            
        }
    }
    
    // MARK - StringInputClient functions
    
    func getInputPrompt() -> String {
        return "Enter a new preset name:"
    }
    
    func getDefaultValue() -> String? {
        return "<New Pitch preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let valid = !PitchPresets.presetWithNameExists(string)
        
        if (!valid) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        
        PitchPresets.addUserDefinedPreset(string, pitchSlider.floatValue, pitchOverlapSlider.floatValue)
        
        // Add a menu item for the new preset, at the top of the menu
        presetsMenu.insertItem(withTitle: string, at: 0)
    }
}
