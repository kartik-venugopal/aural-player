import Cocoa

class FXUnitViewController: NSViewController, NSMenuDelegate, StringInputReceiver, NotificationSubscriber, Destroyable {
    
    @IBOutlet weak var btnBypass: EffectsUnitTriStateBypassButton!
    
    @IBOutlet weak var lblCaption: VALabel!
    
    // Labels
    var functionLabels: [NSTextField] = []
    
    var functionCaptionLabels: [NSTextField] = []
    var functionValueLabels: [NSTextField] = []

    // Presets controls
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var presetsMenuIconItem: TintedIconMenuItem!
    @IBOutlet weak var btnSavePreset: TintedImageButton!
    lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    let graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    let fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    
    var fxUnit: FXUnitDelegateProtocol!
    var unitStateFunction: EffectsUnitStateFunction!
    var presetsWrapper: PresetsWrapperProtocol!
    
    var unitType: EffectsUnit!
    
    override func viewDidLoad() {
        
        self.unitStateFunction = fxUnit.stateFunction
        
        oneTimeSetup()
        initControls()
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(ColorSchemes.systemScheme)
    }
    
    func oneTimeSetup() {
        
        btnBypass.stateFunction = self.unitStateFunction
        btnSavePreset.tintFunction = {return Colors.functionButtonColor}
        presetsMenuIconItem.tintFunction = {return Colors.functionButtonColor}
        
        initSubscriptions()
        
        functionLabels = findFunctionLabels(self.view)
    }
    
    func findFunctionLabels(_ view: NSView) -> [NSTextField] {
        
        var labels: [NSTextField] = []
        
        for subview in view.subviews {
            
            if let label = subview as? NSTextField, label != lblCaption {
                
                labels.append(label)
                label is FunctionValueLabel ? functionValueLabels.append(label) : functionCaptionLabels.append(label)
            }
            
            // Recursive call
            let subviewLabels = findFunctionLabels(subview)
            labels.append(contentsOf: subviewLabels)
        }
        
        return labels
    }
    
    func initSubscriptions() {
        
        // Subscribe to notifications
        Messenger.subscribe(self, .fx_unitStateChanged, self.stateChanged)
        
        Messenger.subscribe(self, .fx_updateFXUnitView, {[weak self] (EffectsUnit) in self?.initControls()},
                            filter: {[weak self] (unit: EffectsUnit) in unit == .master || (unit == self?.unitType)})
        
        Messenger.subscribe(self, .fx_changeSliderColors, self.changeSliderColors)
        
        Messenger.subscribe(self, .applyTheme, self.applyTheme)
        Messenger.subscribe(self, .applyFontScheme, self.applyFontScheme(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeFunctionButtonColor, self.changeFunctionButtonColor(_:))
        Messenger.subscribe(self, .changeMainCaptionTextColor, self.changeMainCaptionTextColor(_:))
        
        Messenger.subscribe(self, .fx_changeFunctionCaptionTextColor, self.changeFunctionCaptionTextColor(_:))
        Messenger.subscribe(self, .fx_changeFunctionValueTextColor, self.changeFunctionValueTextColor(_:))
        
        Messenger.subscribe(self, .fx_changeActiveUnitStateColor, self.changeActiveUnitStateColor(_:))
        Messenger.subscribe(self, .fx_changeBypassedUnitStateColor, self.changeBypassedUnitStateColor(_:))
        Messenger.subscribe(self, .fx_changeSuppressedUnitStateColor, self.changeSuppressedUnitStateColor(_:))
    }
    
    func destroy() {
        Messenger.unsubscribeAll(for: self)
    }
    
    func initControls() {
        
        stateChanged()
        presetsMenu.selectItem(at: -1)
    }
    
    func stateChanged() {
        btnBypass.updateState()
    }
    
    func showThisTab() {
        Messenger.publish(.fx_showFXUnitTab, payload: self.unitType!)
    }
    
    @IBAction func bypassAction(_ sender: AnyObject) {

        _ = fxUnit.toggleState()
        stateChanged()
        
        Messenger.publish(.fx_unitStateChanged)
    }
    
    // Applies a preset to the effects unit
    @IBAction func presetsAction(_ sender: AnyObject) {
        
        fxUnit.applyPreset(presetsMenu.titleOfSelectedItem!)
        initControls()
    }
    
    // Displays a popover to allow the user to name the new custom preset
    @IBAction func savePresetAction(_ sender: AnyObject) {
        userPresetsPopover.show(btnSavePreset, NSRectEdge.minY)
    }
    
    private func applyTheme() {
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(ColorSchemes.systemScheme)
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
        lblCaption.font = fontSchemesManager.systemScheme.effects.unitCaptionFont
        functionLabels.forEach({$0.font = fontSchemesManager.systemScheme.effects.unitFunctionFont})
        presetsMenu.font = Fonts.menuFont
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        changeMainCaptionTextColor(scheme.general.mainCaptionTextColor)
        
        changeFunctionButtonColor(scheme.general.functionButtonColor)
        changeFunctionCaptionTextColor(scheme.effects.functionCaptionTextColor)
        changeFunctionValueTextColor(scheme.effects.functionValueTextColor)
        
        changeActiveUnitStateColor(scheme.effects.activeUnitStateColor)
        changeBypassedUnitStateColor(scheme.effects.bypassedUnitStateColor)
        changeSuppressedUnitStateColor(scheme.effects.suppressedUnitStateColor)
    }
    
    func changeMainCaptionTextColor(_ color: NSColor) {
        lblCaption.textColor = color
    }
    
    func changeFunctionCaptionTextColor(_ color: NSColor) {
        functionCaptionLabels.forEach({$0.textColor = color})
    }
    
    func changeFunctionValueTextColor(_ color: NSColor) {
        functionValueLabels.forEach({$0.textColor = color})
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
    
    func changeFunctionButtonColor(_ color: NSColor) {
        
        btnSavePreset.reTint()
        presetsMenuIconItem.reTint()
    }
    
    func changeSliderColors() {
        // Do nothing. Meant to be overriden.
    }
    
    // MARK - StringInputReceiver functions
    
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
    
    // MARK: Menu delegate
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all custom presets (all items before the first separator)
        while presetsMenu.itemArray.count > 1 && !presetsMenu.item(at: 1)!.isSeparatorItem {
            presetsMenu.removeItem(at: 1)
        }
        
        
        // Re-initialize the menu with user-defined presets
        presetsWrapper.userDefinedPresets.forEach({presetsMenu.insertItem(withTitle: $0.name, at: 1)})
        
        // Don't select any items from the EQ presets menu
        presetsMenu.selectItem(at: -1)
    }
}

// Marker class to differentiate between caption labels and their corresponding value labels
class FunctionValueLabel: CenterTextLabel {}
