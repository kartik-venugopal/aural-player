import Cocoa

class FXUnitViewController: NSViewController, NSMenuDelegate, StringInputClient, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var btnBypass: EffectsUnitTriStateBypassButton!
    
    @IBOutlet weak var lblCaption: VALabel!
    
    // Labels
    var functionLabels: [NSTextField] = []

    // Presets controls
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    let graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    private lazy var windowManager: WindowManagerProtocol = ObjectGraph.windowManager

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
        SyncMessenger.subscribe(actionTypes: [.updateEffectsView, .changeEffectsTextSize, .changeEffectsMainCaptionTextColor, .changeEffectsFunctionCaptionTextColor, .changeEffectsActiveUnitStateColor, .changeEffectsBypassedUnitStateColor, .changeEffectsSuppressedUnitStateColor], subscriber: self)
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
        windowManager.mainWindow.orderFront(self)
    }
    
    func changeTextSize() {
        
        lblCaption.font = Fonts.Effects.unitCaptionFont
        functionLabels.forEach({$0.font = Fonts.Effects.unitFunctionFont})
        presetsMenu.font = Fonts.Effects.menuFont
    }
    
    func changeMainCaptionTextColor(_ color: NSColor) {
        lblCaption.textColor = color
    }
    
    func changeFunctionCaptionTextColor(_ color: NSColor) {
        functionLabels.forEach({$0.textColor = color})
    }
    
    func changeActiveUnitStateColor(_ color: NSColor) {
        
        if fxUnit.state == .active {
            btnBypass.reTint()
        }
    }
    
    func changeBypassedUnitStateColor(_ color: NSColor) {
        
        if fxUnit.state == .bypassed {
            btnBypass.reTint()
        }
    }
    
    func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        if fxUnit.state == .suppressed {
            btnBypass.reTint()
        }
    }
    
    var subscriberId: String {
        return self.className
    }
    
    // MARK - StringInputClient functions
    
    var inputPrompt: String {
        return "Enter a new preset name:"
    }
    
    var defaultValue: String? {
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
    
    var inputFontSize: TextSize {
        return EffectsViewState.textSize
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
            return
        }
        
        if let colorSchemeMsg = message as? ColorSchemeActionMessage {
            
            switch colorSchemeMsg.actionType {
                
            case .changeEffectsMainCaptionTextColor:
                
                changeMainCaptionTextColor(colorSchemeMsg.color)
                
            case .changeEffectsFunctionCaptionTextColor:
                
                changeFunctionCaptionTextColor(colorSchemeMsg.color)
                
            case .changeEffectsActiveUnitStateColor:
                
                changeActiveUnitStateColor(colorSchemeMsg.color)
                
            case .changeEffectsBypassedUnitStateColor:
                
                changeBypassedUnitStateColor(colorSchemeMsg.color)
                
            case .changeEffectsSuppressedUnitStateColor:
                
                changeSuppressedUnitStateColor(colorSchemeMsg.color)
                
            default: return
                
            }
        }
    }
}
