import Cocoa

/*
    View controller for the Filter effects unit
 */
class FilterViewController: NSViewController, NSMenuDelegate, MessageSubscriber, ActionMessageSubscriber, StringInputClient {
    
    // Filter controls
    @IBOutlet weak var btnFilterBypass: EffectsUnitTriStateBypassButton!
    
    @IBOutlet weak var filterBassSlider: RangeSlider!
    @IBOutlet weak var filterMidSlider: RangeSlider!
    @IBOutlet weak var filterTrebleSlider: RangeSlider!
    
    private var sliders: [RangeSlider] = []
    
    @IBOutlet weak var lblFilterBassRange: NSTextField!
    @IBOutlet weak var lblFilterMidRange: NSTextField!
    @IBOutlet weak var lblFilterTrebleRange: NSTextField!
    
    // Presets menu
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    
    private lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    override var nibName: String? {return "Filter"}
    
    override func viewDidLoad() {
        
        oneTimeSetup()
        initControls()
        
        SyncMessenger.subscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.updateEffectsView], subscriber: self)
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        let itemCount = presetsMenu.itemArray.count
        
        let customPresetCount = itemCount - 6  // 1 separator, 5 system-defined presets
        
        if customPresetCount > 0 {
            
            for index in (0..<customPresetCount).reversed() {
                presetsMenu.removeItem(at: index)
            }
        }
        
        // Re-initialize the menu with user-defined presets
        
        // Initialize the menu with user-defined presets
        FilterPresets.userDefinedPresets.forEach({presetsMenu.insertItem(withTitle: $0.name, at: 0)})
        
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    private func oneTimeSetup() {
        
        let stateFunction = {
            () -> EffectsUnitState in
            return self.graph.getFilterState()
        }
        
        btnFilterBypass.stateFunction = stateFunction
        
        filterBassSlider.initialize(AppConstants.bass_min, AppConstants.bass_max, {
            (slider: RangeSlider) -> Void in
            self.filterBassChanged()
        })
        
        filterMidSlider.initialize(AppConstants.mid_min, AppConstants.mid_max, {
            (slider: RangeSlider) -> Void in
            self.filterMidChanged()
        })
        
        filterTrebleSlider.initialize(AppConstants.treble_min, AppConstants.treble_max, {
            (slider: RangeSlider) -> Void in
            self.filterTrebleChanged()
        })
        
        sliders = [filterBassSlider, filterMidSlider, filterTrebleSlider]
        sliders.forEach({$0.stateFunction = stateFunction})
    }
 
    private func initControls() {
        
        btnFilterBypass.updateState()
        sliders.forEach({$0.updateState()})
        
        let bassBand = graph.getFilterBassBand()
        filterBassSlider.start = Double(bassBand.min)
        filterBassSlider.end = Double(bassBand.max)
        lblFilterBassRange.stringValue = bassBand.rangeString
        
        let midBand = graph.getFilterMidBand()
        filterMidSlider.start = Double(midBand.min)
        filterMidSlider.end = Double(midBand.max)
        lblFilterMidRange.stringValue = midBand.rangeString
        
        let trebleBand = graph.getFilterTrebleBand()
        filterTrebleSlider.start = Double(trebleBand.min)
        filterTrebleSlider.end = Double(trebleBand.max)
        lblFilterTrebleRange.stringValue = trebleBand.rangeString
        
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
        _ = graph.toggleFilterState()
        
        btnFilterBypass.updateState()
        sliders.forEach({$0.updateState()})
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
    }
    
    // Action function for the Filter unit's bass slider. Updates the Filter bass band.
    private func filterBassChanged() {
        lblFilterBassRange.stringValue = graph.setFilterBassBand(Float(filterBassSlider.start), Float(filterBassSlider.end))
    }
    
    // Action function for the Filter unit's mid-frequency slider. Updates the Filter mid-frequency band.
    private func filterMidChanged() {
        lblFilterMidRange.stringValue = graph.setFilterMidBand(Float(filterMidSlider.start), Float(filterMidSlider.end))
    }
    
    // Action function for the Filter unit's treble slider. Updates the Filter treble band.
    private func filterTrebleChanged() {
        lblFilterTrebleRange.stringValue = graph.setFilterTrebleBand(Float(filterTrebleSlider.start), Float(filterTrebleSlider.end))
    }
    
    // Applies a preset to the effects unit
    @IBAction func filterPresetsAction(_ sender: AnyObject) {
        graph.applyFilterPreset(presetsMenu.titleOfSelectedItem!)
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
        return "<New Filter preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let valid = !FilterPresets.presetWithNameExists(string)
        
        if (!valid) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        
        graph.saveFilterPreset(string)
        
        // Add a menu item for the new preset, at the top of the menu
        presetsMenu.insertItem(withTitle: string, at: 0)
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if notification is EffectsUnitStateChangedNotification {
            
            btnFilterBypass.updateState()
            sliders.forEach({$0.updateState()})
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if message.actionType == .updateEffectsView {
            
            let msg = message as! EffectsViewActionMessage
            if msg.effectsUnit == .master || msg.effectsUnit == .filter {
                initControls()
            }
        }
    }
}
