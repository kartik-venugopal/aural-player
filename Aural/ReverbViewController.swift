import Cocoa

/*
    View controller for the Reverb effects unit
 */
class ReverbViewController: NSViewController, StringInputClient {
    
    // Reverb controls
    @IBOutlet weak var btnReverbBypass: EffectsUnitBypassButton!
    @IBOutlet weak var reverbSpaceMenu: NSPopUpButton!
    @IBOutlet weak var reverbAmountSlider: NSSlider!
    @IBOutlet weak var lblReverbAmountValue: NSTextField!
    
    // Presets menu
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    
    private lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    override var nibName: String? {return "Reverb"}
    
    override func viewDidLoad() {
        initControls()
    }
    
    private func initControls() {
        
        btnReverbBypass.setBypassState(graph.isReverbBypass())
        reverbSpaceMenu.select(reverbSpaceMenu.item(withTitle: graph.getReverbSpace()))
        
        let amount = graph.getReverbAmount()
        reverbAmountSlider.floatValue = amount.amount
        lblReverbAmountValue.stringValue = amount.amountString
        
        // Initialize the menu with user-defined presets
        ReverbPresets.allPresets().forEach({presetsMenu.insertItem(withTitle: $0.name, at: 0)})
        
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }

    // Activates/deactivates the Reverb effects unit
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        btnReverbBypass.toggle()
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.reverb, !graph.toggleReverbBypass()))
    }

    // Updates the Reverb preset
    @IBAction func reverbSpaceAction(_ sender: AnyObject) {
        graph.setReverbSpace(ReverbSpaces.fromDescription((reverbSpaceMenu.selectedItem?.title)!))
    }

    // Updates the Reverb amount parameter
    @IBAction func reverbAmountAction(_ sender: AnyObject) {
        lblReverbAmountValue.stringValue = graph.setReverbAmount(reverbAmountSlider.floatValue)
    }
    
    // Applies a preset to the effects unit
    @IBAction func reverbPresetsAction(_ sender: AnyObject) {
        
        // Get preset definition
        if let preset = ReverbPresets.presetByName(presetsMenu.titleOfSelectedItem!) {
        
            graph.setReverbSpace(preset.space)
            reverbSpaceMenu.selectItem(withTitle: preset.space.description)
            
            lblReverbAmountValue.stringValue = graph.setReverbAmount(preset.amount)
            reverbAmountSlider.floatValue = preset.amount
        }
        
        // Don't select any of the items
        presetsMenu.selectItem(at: -1)
    }
    
    // Displays a popover to allow the user to name the new custom preset
    @IBAction func savePresetAction(_ sender: AnyObject) {
        
        userPresetsPopover.show(btnSavePreset, NSRectEdge.minY)
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        WindowState.window.orderFront(self)
    }
    
    // MARK - StringInputClient functions
    
    func getInputPrompt() -> String {
        return "Enter a new preset name:"
    }
    
    func getDefaultValue() -> String? {
        return "<New Reverb preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let valid = !ReverbPresets.presetWithNameExists(string)

        if (!valid) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        
        ReverbPresets.addUserDefinedPreset(string, ReverbSpaces.fromDescription((reverbSpaceMenu.selectedItem?.title)!), reverbAmountSlider.floatValue)
        
        // Add a menu item for the new preset, at the top of the menu
        presetsMenu.insertItem(withTitle: string, at: 0)
    }
}
