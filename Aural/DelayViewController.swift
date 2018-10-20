import Cocoa

/*
    View controller for the Delay effects unit
 */
class DelayViewController: NSViewController, NSMenuDelegate, MessageSubscriber, ActionMessageSubscriber, StringInputClient {
    
    // Delay controls
    @IBOutlet weak var btnDelayBypass: EffectsUnitTriStateBypassButton!
    
    @IBOutlet weak var delayTimeSlider: EffectsUnitSlider!
    @IBOutlet weak var delayAmountSlider: EffectsUnitSlider!
    @IBOutlet weak var delayCutoffSlider: EffectsUnitSlider!
    @IBOutlet weak var delayFeedbackSlider: EffectsUnitSlider!
    
    private var sliders: [EffectsUnitSlider] = []
    
    @IBOutlet weak var lblDelayTimeValue: NSTextField!
    @IBOutlet weak var lblDelayAmountValue: NSTextField!
    @IBOutlet weak var lblDelayFeedbackValue: NSTextField!
    @IBOutlet weak var lblDelayLowPassCutoffValue: NSTextField!
    
    // Presets menu
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    
    private lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    override var nibName: String? {return "Delay"}
    
    override func viewDidLoad() {
        
        oneTimeSetup()
        initControls()
        
        SyncMessenger.subscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.updateEffectsView], subscriber: self)
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        let itemCount = presetsMenu.itemArray.count
        
        let customPresetCount = itemCount - 7  // 2 separators, 5 system-defined presets
        
        if customPresetCount > 0 {
            
            for index in (0..<customPresetCount).reversed() {
                presetsMenu.removeItem(at: index)
            }
        }
        
        // Re-initialize the menu with user-defined presets
        DelayPresets.userDefinedPresets.forEach({presetsMenu.insertItem(withTitle: $0.name, at: 0)})
        
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    private func oneTimeSetup() {
        
        let stateFunction = {
            () -> EffectsUnitState in
            return self.graph.getDelayState()
        }
        
        btnDelayBypass.stateFunction = stateFunction
        
        sliders = [delayTimeSlider, delayAmountSlider, delayFeedbackSlider, delayCutoffSlider]
        sliders.forEach({$0.stateFunction = stateFunction})
    }

    private func initControls() {
        
        btnDelayBypass.updateState()
        sliders.forEach({$0.updateState()})
        
        let amount = graph.getDelayAmount()
        delayAmountSlider.floatValue = amount.amount
        lblDelayAmountValue.stringValue = amount.amountString
        
        let time = graph.getDelayTime()
        delayTimeSlider.doubleValue = time.time
        lblDelayTimeValue.stringValue = time.timeString
        
        let feedback = graph.getDelayFeedback()
        delayFeedbackSlider.floatValue = feedback.percent
        lblDelayFeedbackValue.stringValue = feedback.percentString
        
        let cutoff = graph.getDelayLowPassCutoff()
        delayCutoffSlider.floatValue = cutoff.cutoff
        lblDelayLowPassCutoffValue.stringValue = cutoff.cutoffString
        
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }

    // Activates/deactivates the Delay effects unit
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        
        _ = graph.toggleDelayState()
        btnDelayBypass.updateState()
        sliders.forEach({$0.updateState()})
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
    }
    
    // Updates the Delay amount parameter
    @IBAction func delayAmountAction(_ sender: AnyObject) {
        lblDelayAmountValue.stringValue = graph.setDelayAmount(delayAmountSlider.floatValue)
    }
    
    // Updates the Delay time parameter
    @IBAction func delayTimeAction(_ sender: AnyObject) {
        lblDelayTimeValue.stringValue = graph.setDelayTime(delayTimeSlider.doubleValue)
    }
    
    // Updates the Delay feedback parameter
    @IBAction func delayFeedbackAction(_ sender: AnyObject) {
        lblDelayFeedbackValue.stringValue = graph.setDelayFeedback(delayFeedbackSlider.floatValue)
    }
    
    // Updates the Delay low pass cutoff parameter
    @IBAction func delayCutoffAction(_ sender: AnyObject) {
        lblDelayLowPassCutoffValue.stringValue = graph.setDelayLowPassCutoff(delayCutoffSlider.floatValue)
    }
    
    // Applies a preset to the effects unit
    @IBAction func delayPresetsAction(_ sender: AnyObject) {
        graph.applyDelayPreset(presetsMenu.titleOfSelectedItem!)
        initControls()
    }
    
    // Displays a popover to allow the user to name the new custom preset
    @IBAction func savePresetAction(_ sender: AnyObject) {
        
        userPresetsPopover.show(btnSavePreset, NSRectEdge.minY)
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        WindowState.mainWindow.orderFront(self)
    }
    
    // MARK - StringInputClient functions
    
    func getInputPrompt() -> String {
        return "Enter a new preset name:"
    }
    
    func getDefaultValue() -> String? {
        return "<New Delay preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let valid = !DelayPresets.presetWithNameExists(string)
        
        if (!valid) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        
        graph.saveDelayPreset(string)
        
        // Add a menu item for the new preset, at the top of the menu
        presetsMenu.insertItem(withTitle: string, at: 0)
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if notification is EffectsUnitStateChangedNotification {
            btnDelayBypass.updateState()
            sliders.forEach({$0.updateState()})
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if message.actionType == .updateEffectsView {
            
            let msg = message as! EffectsViewActionMessage
            if msg.effectsUnit == .master || msg.effectsUnit == .delay {
                initControls()
            }
        }
    }
}
