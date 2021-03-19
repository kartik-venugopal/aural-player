import Cocoa

class FXUnitViewController: NSViewController, NSMenuDelegate, StringInputClient, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var btnBypass: EffectsUnitTriStateBypassButton!
    
    @IBOutlet weak var lblCaption: VALabel?
    
    // Labels
    var functionLabels: [NSTextField] = []

    // Presets controls
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: ColorSensitiveImageButton! {
    
        didSet {
            
            btnSavePreset.imageMappings[.darkBackground_lightText] = NSImage(named: "SavePreset")
            btnSavePreset.imageMappings[.lightBackground_darkText] = NSImage(named: "SavePreset_1")
        }
    }
    
    lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    let graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate

    var fxUnit: FXUnitDelegateProtocol!
    var unitStateFunction: EffectsUnitStateFunction!
    var presetsWrapper: PresetsWrapperProtocol!
    
    var unitType: EffectsUnit!
    
    override func viewDidLoad() {
        
        oneTimeSetup()
        initControls()
    }
    
    func oneTimeSetup() {
        
        btnBypass.stateFunction = self.unitStateFunction
        initSubscriptions()
        
        functionLabels = findFunctionLabels(self.view)
    }
    
    func findFunctionLabels(_ view: NSView) -> [NSTextField] {
        
        var labels: [NSTextField] = []
        
        for subview in view.subviews {
            
            if let label = subview as? NSTextField, label != lblCaption {
                labels.append(label)
            }
            
            // Recursive call
            let subviewLabels = findFunctionLabels(subview)
            labels.append(contentsOf: subviewLabels)
        }
        
        return labels
    }
    
    func initSubscriptions() {
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.updateEffectsView, .changeEffectsTextSize, .changeColorScheme], subscriber: self)
    }
    
    func initControls() {
        
        stateChanged()
        presetsMenu.selectItem(at: -1)
    }
    
    func stateChanged() {
        btnBypass.updateState()
    }
    
    func showThisTab() {
        SyncMessenger.publishActionMessage(EffectsViewActionMessage(.showEffectsUnitTab, unitType))
    }
    
    @IBAction func bypassAction(_ sender: AnyObject) {

        _ = fxUnit.toggleState()
        stateChanged()
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
    }
    
    // Applies a preset to the effects unit
    @IBAction func presetsAction(_ sender: AnyObject) {
        
        fxUnit.applyPreset(presetsMenu.titleOfSelectedItem!)
        initControls()
    }
    
    // Displays a popover to allow the user to name the new custom preset
    @IBAction func savePresetAction(_ sender: AnyObject) {
        
        userPresetsPopover.show(btnSavePreset, NSRectEdge.minY)
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        WindowState.mainWindow.orderFront(self)
    }
    
    func changeTextSize() {
        
        lblCaption?.font = TextSizes.fxUnitCaptionFont
        functionLabels.forEach({$0.font = TextSizes.fxUnitFunctionFont})
        presetsMenu.font = TextSizes.effectsMenuFont
    }
    
    func changeColorScheme() {
        
        lblCaption?.textColor = Colors.fxUnitCaptionColor
        functionLabels.forEach({$0.textColor = Colors.fxUnitFunctionColor})
        
        btnBypass.colorSchemeChanged()
        btnSavePreset.colorSchemeChanged()
        presetsMenu.redraw()
    }
    
    var subscriberId: String {
        return self.className
    }
    
    // MARK - StringInputClient functions
    
    func getInputPrompt() -> String {
        return "Enter a new preset name:"
    }
    
    func getDefaultValue() -> String? {
        return "<New preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        if presetsWrapper.presetWithNameExists(string) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        fxUnit.savePreset(string)
    }
    
    func getInputFontSize() -> TextSizeScheme {
        return TextSizes.effectsScheme
    }
    
    // MARK: Menu delegate
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all custom presets (all items before the first separator)
        while !presetsMenu.itemArray.isEmpty && !presetsMenu.item(at: 0)!.isSeparatorItem {
            presetsMenu.removeItem(at: 0)
        }
        
        // Re-initialize the menu with user-defined presets
        presetsWrapper.userDefinedPresets.forEach({presetsMenu.insertItem(withTitle: $0.name, at: 0)})
        
        // Don't select any items from the EQ presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    // MARK: Message handling
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if notification.messageType == .effectsUnitStateChangedNotification {
            stateChanged()
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let msg = message as? EffectsViewActionMessage, msg.effectsUnit == .master || msg.effectsUnit == self.unitType {
            initControls()
        }
        
        switch message.actionType {
            
        case .changeEffectsTextSize:
            changeTextSize()
            
        case .changeColorScheme:
            changeColorScheme()
            
        default: return
            
        }
    }
}
