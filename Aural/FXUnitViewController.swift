import Cocoa

class FXUnitViewController: NSViewController, NSMenuDelegate, StringInputClient {
    
    @IBOutlet weak var btnBypass: EffectsUnitTriStateBypassButton!

    // Presets controls
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()

    var fxUnit: FXUnitDelegateProtocol!
    var unitStateFunction: EffectsUnitStateFunction!
    var presets: UserDefinedPresets!
    
    override func viewDidLoad() {
        
        // one-time setup
        btnBypass.stateFunction = self.unitStateFunction
        
        initControls()
    }
    
    func initControls() {
        
        btnBypass.updateState()
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all custom presets
        while !presetsMenu.item(at: 0)!.isSeparatorItem {
            presetsMenu.removeItem(at: 0)
        }
        
        // Re-initialize the menu with user-defined presets
        presets.presets.forEach({presetsMenu.insertItem(withTitle: $0.name, at: 0)})
        
        // Don't select any items from the EQ presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    @IBAction func bypassAction(_ sender: AnyObject) {

        _ = fxUnit.toggleState()
        btnBypass.updateState()
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
        
        print(presets.presets.count)
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
    
    func getID() -> String {
        return self.className
    }
    
    // MARK - StringInputClient functions
    
    func getInputPrompt() -> String {
        return "Enter a new preset name:"
    }
    
    func getDefaultValue() -> String? {
        return "<New Pitch preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let valid = !presets.presetWithNameExists(string)

        if (!valid) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        
        fxUnit.savePreset(string)
        
        // Add a menu item for the new preset, at the top of the menu
        presetsMenu.insertItem(withTitle: string, at: 0)
    }
}
