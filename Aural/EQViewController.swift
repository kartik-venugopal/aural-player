import Cocoa

/*
    View controller for the EQ (Equalizer) effects unit
 */
class EQViewController: NSViewController, ActionMessageSubscriber, StringInputClient {
    
    @IBOutlet weak var btnEQBypass: EffectsUnitBypassButton!
    
    @IBOutlet weak var eqGlobalGainSlider: NSSlider!
    @IBOutlet weak var eqSlider1k: NSSlider!
    @IBOutlet weak var eqSlider64: NSSlider!
    @IBOutlet weak var eqSlider16k: NSSlider!
    @IBOutlet weak var eqSlider8k: NSSlider!
    @IBOutlet weak var eqSlider4k: NSSlider!
    @IBOutlet weak var eqSlider2k: NSSlider!
    @IBOutlet weak var eqSlider32: NSSlider!
    @IBOutlet weak var eqSlider512: NSSlider!
    @IBOutlet weak var eqSlider256: NSSlider!
    @IBOutlet weak var eqSlider128: NSSlider!
    
    private var eqSliders: [NSSlider] = []
    
    // Presets menu
    @IBOutlet weak var eqPresets: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    
    private lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    override var nibName: String? {return "EQ"}
    
    override func viewDidLoad() {
        
        initControls()
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(actionTypes: [.increaseBass, .decreaseBass, .increaseMids, .decreaseMids, .increaseTreble, .decreaseTreble], subscriber: self)
    }
    
    private func initControls() {
        
        btnEQBypass.onIf(!graph.isEQBypass())
        
        eqSliders = [eqSlider32, eqSlider64, eqSlider128, eqSlider256, eqSlider512, eqSlider1k, eqSlider2k, eqSlider4k, eqSlider8k, eqSlider16k]
        
        eqGlobalGainSlider.floatValue = graph.getEQGlobalGain()
        updateAllEQSliders(graph.getEQBands())
        
        // Initialize the menu with user-defined presets
        EQPresets.userDefinedPresets.forEach({eqPresets.insertItem(withTitle: $0.name, at: 0)})
        
        // Don't select any items from the EQ presets menu
        eqPresets.selectItem(at: -1)
    }
    
    @IBAction func eqBypassAction(_ sender: AnyObject) {
        btnEQBypass.toggle()
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.eq, !graph.toggleEQBypass()))
    }
    
    // Updates the global gain value of the Equalizer
    @IBAction func eqGlobalGainAction(_ sender: AnyObject) {
        graph.setEQGlobalGain(eqGlobalGainSlider.floatValue)
    }
    
    // Updates the gain value of a single frequency band (specified by the slider parameter) of the Equalizer
    @IBAction func eqSliderAction(_ sender: NSSlider) {
        // Slider tags match the corresponding EQ band indexes
        graph.setEQBand(sender.tag, gain: sender.floatValue)
    }
    
    // Applies a built-in preset to the Equalizer
    @IBAction func eqPresetsAction(_ sender: AnyObject) {
        
        // Check if the preset is user-defined (tag == -1) or built-in
        
        let preset = EQPresets.presetByName(eqPresets.titleOfSelectedItem!)
        
        graph.setEQBands(preset.bands)
        updateAllEQSliders(preset.bands)
        
        // Don't select any of the items
        eqPresets.selectItem(at: -1)
    }
    
    // Displays a popover to allow the user to name the new custom preset
    @IBAction func savePresetAction(_ sender: AnyObject) {
        
        userPresetsPopover.show(btnSavePreset, NSRectEdge.minY)
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        WindowState.mainWindow.orderFront(self)
    }
    
    private func updateAllEQSliders(_ eqBands: [Int: Float]) {
        // Slider tag = index. Default gain value, if bands array doesn't contain gain for index, is 0
        eqSliders.forEach({
            $0.floatValue = eqBands[$0.tag] ?? 0
        })
    }
    
    private func showEQTab() {
    
        SyncMessenger.publishActionMessage(EffectsViewActionMessage(.showEffectsUnitTab, .eq))
    }
    
    // Provides a "bass boost". Increases each of the EQ bass bands by a certain preset increment.
    private func increaseBass() {
        bandsUpdated(graph.increaseBass())
    }
    
    // Decreases each of the EQ bass bands by a certain preset decrement
    private func decreaseBass() {
        bandsUpdated(graph.decreaseBass())
    }
    
    // Increases each of the EQ mid-frequency bands by a certain preset increment
    private func increaseMids() {
        bandsUpdated(graph.increaseMids())
    }
    
    // Decreases each of the EQ mid-frequency bands by a certain preset decrement
    private func decreaseMids() {
        bandsUpdated(graph.decreaseMids())
    }
    
    // Decreases each of the EQ treble bands by a certain preset increment
    private func increaseTreble() {
        bandsUpdated(graph.increaseTreble())
    }
    
    // Decreases each of the EQ treble bands by a certain preset decrement
    private func decreaseTreble() {
        bandsUpdated(graph.decreaseTreble())
    }
    
    private func bandsUpdated(_ bands: [Int: Float]) {
        
        btnEQBypass.on()
        updateAllEQSliders(bands)
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.eq, true))
        showEQTab()
    }
    
    private func getAllBands() -> [Int: Float] {
        
        var allBands: [Int: Float] = [Int: Float]()
        eqSliders.forEach({allBands[$0.tag] = $0.floatValue})
        return allBands
    }
    
    func getID() -> String {
        return self.className
    }
    
    // MARK: Message handling
    
    func consumeMessage(_ message: ActionMessage) {
        
        let message = message as! AudioGraphActionMessage
        
        switch message.actionType {
            
        case .increaseBass: increaseBass()
            
        case .decreaseBass: decreaseBass()
            
        case .increaseMids: increaseMids()
            
        case .decreaseMids: decreaseMids()
            
        case .increaseTreble: increaseTreble()
            
        case .decreaseTreble: decreaseTreble()
            
        default: return
            
        }
    }
    
    // MARK - StringInputClient functions
    
    func getInputPrompt() -> String {
        return "Enter a new preset name:"
    }
    
    func getDefaultValue() -> String? {
        return "<New EQ preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let valid = !EQPresets.presetWithNameExists(string)
        
        if (!valid) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
 
        EQPresets.addUserDefinedPreset(string, getAllBands())
        
        // Add a menu item for the new preset, at the top of the menu
        eqPresets.insertItem(withTitle: string, at: 0)
    }
}
