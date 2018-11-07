import Cocoa

/*
    View controller for the Delay effects unit
 */
class DelayViewController: NSViewController, NSMenuDelegate, MessageSubscriber, ActionMessageSubscriber, StringInputClient {
    
    // Delay controls
    @IBOutlet weak var btnDelayBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var delayView: DelayView!
    
    // Presets menu
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    
    private lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    private let delayPresets: DelayPresets = ObjectGraph.getAudioGraphDelegate().delayPresets
    
    override var nibName: String? {return "Delay"}
    
    override func viewDidLoad() {
        
        oneTimeSetup()
        initControls()
        
        SyncMessenger.subscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.updateEffectsView], subscriber: self)
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all custom presets
        while !presetsMenu.item(at: 0)!.isSeparatorItem {
            presetsMenu.removeItem(at: 0)
        }
        
        // Re-initialize the menu with user-defined presets
        delayPresets.userDefinedPresets.forEach({presetsMenu.insertItem(withTitle: $0.name, at: 0)})
        
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    private func oneTimeSetup() {
        
        let stateFunction = {() -> EffectsUnitState in return self.graph.getDelayState()}
        btnDelayBypass.stateFunction = stateFunction
        delayView.initialize(stateFunction)
    }

    private func initControls() {
        
        btnDelayBypass.updateState()
        delayView.stateChanged()
        
        let amount = graph.getDelayAmount()
        let time = graph.getDelayTime()
        let feedback = graph.getDelayFeedback()
        let cutoff = graph.getDelayLowPassCutoff()
        
        delayView.setState(time.time, time.timeString, amount.amount, amount.amountString, feedback.percent, feedback.percentString, cutoff.cutoff, cutoff.cutoffString)
        
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }

    // Activates/deactivates the Delay effects unit
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        
        _ = graph.toggleDelayState()
        btnDelayBypass.updateState()
        delayView.stateChanged()
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
    }
    
    // Updates the Delay amount parameter
    @IBAction func delayAmountAction(_ sender: AnyObject) {
        
        let amountString = graph.setDelayAmount(delayView.amount)
        delayView.setAmount(delayView.amount, amountString)
    }
    
    // Updates the Delay time parameter
    @IBAction func delayTimeAction(_ sender: AnyObject) {
        
        let timeString = graph.setDelayTime(delayView.time)
        delayView.setTime(delayView.time, timeString)
    }
    
    // Updates the Delay feedback parameter
    @IBAction func delayFeedbackAction(_ sender: AnyObject) {
        
        let feedbackString = graph.setDelayFeedback(delayView.feedback)
        delayView.setFeedback(delayView.feedback, feedbackString)
    }
    
    // Updates the Delay low pass cutoff parameter
    @IBAction func delayCutoffAction(_ sender: AnyObject) {
        
        let cutoffString = graph.setDelayLowPassCutoff(delayView.cutoff)
        delayView.setCutoff(delayView.cutoff, cutoffString)
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
        
        let valid = !delayPresets.presetWithNameExists(string)
        
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
            delayView.stateChanged()
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
