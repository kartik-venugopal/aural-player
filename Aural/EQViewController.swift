import Cocoa

/*
    View controller for the EQ (Equalizer) effects unit
 */
class EQViewController: NSViewController, MessageSubscriber, NSMenuDelegate, ActionMessageSubscriber, StringInputClient {
    
    @IBOutlet weak var btnEQBypass: EffectsUnitTriStateBypassButton!
    
    @IBOutlet weak var container: NSBox!
    
    @IBOutlet weak var eq10BandView: EQView!
    @IBOutlet weak var eq15BandView: EQView!
    
    @IBOutlet weak var btn10Band: NSButton!
    @IBOutlet weak var btn15Band: NSButton!
    @IBOutlet weak var btnSync: NSButton!
    
    // Presets menu
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    
    private var activeView: EQView {
        return btn10Band.isOn() ? eq10BandView : eq15BandView
    }
    
    private var inactiveView: EQView {
        return btn10Band.isOn() ? eq15BandView : eq10BandView
    }
    
    private lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    override var nibName: String? {return "EQ"}
    
    override func viewDidLoad() {
        
        oneTimeSetup()
        initControls()
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.increaseBass, .decreaseBass, .increaseMids, .decreaseMids, .increaseTreble, .decreaseTreble, .updateEffectsView], subscriber: self)
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        let itemCount = presetsMenu.itemArray.count
        
        let customPresetCount = itemCount - 18  // 3 separators, 15 system-defined presets
        
        if customPresetCount > 0 {
            
            for index in (0..<customPresetCount).reversed() {
                presetsMenu.removeItem(at: index)
            }
        }
        
        // Re-initialize the menu with user-defined presets
        EQPresets.userDefinedPresets.forEach({presetsMenu.insertItem(withTitle: $0.name, at: 0)})
        
        // Don't select any items from the EQ presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    private func oneTimeSetup() {
        
        container.addSubview(eq10BandView)
        container.addSubview(eq15BandView)
        
        eq10BandView.setFrameOrigin(NSPoint.zero)
        eq15BandView.setFrameOrigin(NSPoint.zero)
        
        let eqStateFunction = {
            () -> EffectsUnitState in
            return self.graph.getEQState()
        }
        
        btnEQBypass.stateFunction = eqStateFunction
        eq10BandView.initialize(eqStateFunction)
        eq15BandView.initialize(eqStateFunction)
        
        eq10BandView.bandSliders.forEach({
            $0.action = #selector(self.eqSliderAction(_:))
            $0.target = self
        })
        
        eq15BandView.bandSliders.forEach({
            $0.action = #selector(self.eqSliderAction(_:))
            $0.target = self
        })
        
        graph.getEQType() == .tenBand ? btn10Band.on() : btn15Band.on()
        activeView.stateChanged()
        activeView.updateBands(graph.getEQBands(), graph.getEQGlobalGain())
        activeView.show()
        inactiveView.hide()
        
        btnSync.onIf(graph.getEQSync())
    }
    
    private func initControls() {
        
        btnEQBypass.updateState()
        activeView.stateChanged()
        activeView.updateBands(graph.getEQBands(), graph.getEQGlobalGain())
        
        // Don't select any items from the EQ presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    @IBAction func chooseEQTypeAction(_ sender: AnyObject) {
        
        graph.chooseEQType(btn10Band.isOn() ? .tenBand : .fifteenBand)
        
        activeView.stateChanged()
        activeView.updateBands(graph.getEQBands(), graph.getEQGlobalGain())
        activeView.show()
        
        inactiveView.hide()
    }
    
    @IBAction func eqSyncAction(_ sender: AnyObject) {
        _ = graph.toggleEQSync()
    }
    
    @IBAction func eqBypassAction(_ sender: AnyObject) {
        
        _ = graph.toggleEQState()
        
        btnEQBypass.updateState()
        activeView.stateChanged()
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
    }
    
    @IBAction func eqGlobalGainAction(_ sender: EffectsUnitSlider) {
        graph.setEQGlobalGain(sender.floatValue)
    }
    
    // Updates the gain value of a single frequency band (specified by the slider parameter) of the Equalizer
    @IBAction func eqSliderAction(_ sender: EffectsUnitSlider) {
        // Slider tags match the corresponding EQ band indexes
        graph.setEQBand(sender.tag, gain: sender.floatValue)
    }
   
    // Applies a built-in preset to the Equalizer
    @IBAction func eqPresetsAction(_ sender: AnyObject) {
        graph.applyEQPreset(presetsMenu.titleOfSelectedItem!)
        initControls()
    }
    
    // Displays a popover to allow the user to name the new custom preset
    @IBAction func savePresetAction(_ sender: AnyObject) {
        
        userPresetsPopover.show(btnSavePreset, NSRectEdge.minY)
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        WindowState.mainWindow.orderFront(self)
    }
    
    private func showEQTab() {
        SyncMessenger.publishActionMessage(EffectsViewActionMessage(.showEffectsUnitTab, .eq))
    }
    
    // Provides a "bass boost". Increases each of the EQ bass bands by a certain preset increment.
    private func increaseBass() {
//        bandsUpdated(graph.increaseBass())
    }
    
    // Decreases each of the EQ bass bands by a certain preset decrement
    private func decreaseBass() {
//        bandsUpdated(graph.decreaseBass())
    }
    
    // Increases each of the EQ mid-frequency bands by a certain preset increment
    private func increaseMids() {
//        bandsUpdated(graph.increaseMids())
    }
    
    // Decreases each of the EQ mid-frequency bands by a certain preset decrement
    private func decreaseMids() {
//        bandsUpdated(graph.decreaseMids())
    }
    
    // Decreases each of the EQ treble bands by a certain preset increment
    private func increaseTreble() {
//        bandsUpdated(graph.increaseTreble())
    }
    
    // Decreases each of the EQ treble bands by a certain preset decrement
    private func decreaseTreble() {
//        bandsUpdated(graph.decreaseTreble())
    }
    
    func getID() -> String {
        return self.className
    }
    
    // MARK: Message handling
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if notification is EffectsUnitStateChangedNotification {
            btnEQBypass.updateState()
            activeView.stateChanged()
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let message = message as? AudioGraphActionMessage {
        
            switch message.actionType {
                
            case .increaseBass: increaseBass()
                
            case .decreaseBass: decreaseBass()
                
            case .increaseMids: increaseMids()
                
            case .decreaseMids: decreaseMids()
                
            case .increaseTreble: increaseTreble()
                
            case .decreaseTreble: decreaseTreble()
                
            default: return
                
            }
            
        } else if message.actionType == .updateEffectsView {
            
            let msg = message as! EffectsViewActionMessage
            if msg.effectsUnit == .master || msg.effectsUnit == .eq {
                initControls()
            }
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
 
        graph.saveEQPreset(string)
        
        // Add a menu item for the new preset, at the top of the menu
        presetsMenu.insertItem(withTitle: string, at: 0)
    }
}
