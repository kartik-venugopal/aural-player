import Cocoa

/*
    View controller for the Pitch effects unit
 */
class PitchViewController: NSViewController, NSMenuDelegate, MessageSubscriber, ActionMessageSubscriber, StringInputClient {
    
    // Pitch controls
    @IBOutlet weak var btnPitchBypass: EffectsUnitTriStateBypassButton!
    
    @IBOutlet weak var pitchView: PitchView!
    @IBOutlet weak var box: NSBox!
    
    // Presets menu
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    
    private lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    private var fxUnit: PitchUnitDelegate = ObjectGraph.getAudioGraphDelegate().pitchUnit
    
//    private let pitchPresets: PitchPresets = ObjectGraph.getAudioGraphDelegate().pitchPresets
    private let pitchPresets: PitchPresets = PitchPresets()
    
    override var nibName: String? {return "Pitch"}
    
    override func viewDidLoad() {
        
        oneTimeSetup()
        initControls()
        initSubscriptions()
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all custom presets
        while !presetsMenu.item(at: 0)!.isSeparatorItem {
            presetsMenu.removeItem(at: 0)
        }
        
        // Re-initialize the menu with user-defined presets
        pitchPresets.userDefinedPresets.forEach({presetsMenu.insertItem(withTitle: $0.name, at: 0)})
        
        // Don't select any items from the EQ presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    private func initSubscriptions() {
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.increasePitch, .decreasePitch, .setPitch, .updateEffectsView], subscriber: self)
    }
    
    private func oneTimeSetup() {
        
        let stateFunction = {
            () -> EffectsUnitState in
            
            return self.fxUnit.state
        }
        
        btnPitchBypass.stateFunction = stateFunction
        pitchView.initialize(stateFunction)
    }
    
    private func initControls() {
        
        btnPitchBypass.updateState()
        pitchView.stateChanged()
        pitchView.setState(fxUnit.pitch, fxUnit.formattedPitch, fxUnit.overlap, fxUnit.formattedOverlap)
        
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    // Activates/deactivates the Pitch effects unit
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        
        _ = fxUnit.toggleState()
        
        btnPitchBypass.updateState()
        pitchView.stateChanged()
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
    }
    
    // Updates the pitch
    @IBAction func pitchAction(_ sender: AnyObject) {
        
        fxUnit.pitch = pitchView.pitch
        pitchView.setPitch(fxUnit.pitch, fxUnit.formattedPitch)
    }
    
    private func showPitchTab() {
        SyncMessenger.publishActionMessage(EffectsViewActionMessage(.showEffectsUnitTab, .pitch))
    }
    
    // Sets the pitch to a specific value
    private func setPitch(_ pitch: Float) {
        
        // TODO: Ensure unit active
        fxUnit.pitch = pitch
        pitchView.setPitch(pitch, fxUnit.formattedPitch)
        
        btnPitchBypass.updateState()
        pitchView.stateChanged()
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
        
        // Show the Pitch tab
        showPitchTab()
    }
    
    // Updates the Overlap parameter of the Pitch shift effects unit
    @IBAction func pitchOverlapAction(_ sender: AnyObject) {

        fxUnit.overlap = pitchView.overlap
        pitchView.setPitchOverlap(fxUnit.overlap, fxUnit.formattedOverlap)
    }
    
    // Applies a preset to the effects unit
    @IBAction func pitchPresetsAction(_ sender: AnyObject) {
//        graph.applyPitchPreset(presetsMenu.titleOfSelectedItem!)
        initControls()
    }
    
    // Displays a popover to allow the user to name the new custom preset
    @IBAction func savePresetAction(_ sender: AnyObject) {
        
        userPresetsPopover.show(btnSavePreset, NSRectEdge.minY)
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        WindowState.mainWindow.orderFront(self)
    }
    
    // Increases the overall pitch by a certain preset increment
    private func increasePitch() {
        
        let newPitch = fxUnit.increasePitch()
        pitchChange(newPitch.pitch, newPitch.pitchString)
    }
    
    // Decreases the overall pitch by a certain preset decrement
    private func decreasePitch() {
        
        let newPitch = fxUnit.decreasePitch()
        pitchChange(newPitch.pitch, newPitch.pitchString)
    }
    
    // Changes the pitch to a specified value
    private func pitchChange(_ pitch: Float, _ pitchString: String) {
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
        
        pitchView.setPitch(pitch, pitchString)
        btnPitchBypass.updateState()
        pitchView.stateChanged()
        
        // Show the Pitch tab if the Effects panel is shown
        showPitchTab()
    }
    
    func getID() -> String {
        return self.className
    }
    
    // MARK: Message handling
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if notification is EffectsUnitStateChangedNotification {
            btnPitchBypass.updateState()
            pitchView.stateChanged()
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let message = message as? AudioGraphActionMessage {
        
            switch message.actionType {
                
            case .increasePitch: increasePitch()
                
            case .decreasePitch: decreasePitch()
                
            case .setPitch: setPitch(message.value!)
                
            default: return
                
            }
            
        } else if message.actionType == .updateEffectsView {
            
            let msg = message as! EffectsViewActionMessage
            if msg.effectsUnit == .master || msg.effectsUnit == .pitch {
                initControls()
            }
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
        
        let valid = !pitchPresets.presetWithNameExists(string)
        
        if (!valid) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        
//        graph.savePitchPreset(string)
        
        // Add a menu item for the new preset, at the top of the menu
        presetsMenu.insertItem(withTitle: string, at: 0)
    }
}
