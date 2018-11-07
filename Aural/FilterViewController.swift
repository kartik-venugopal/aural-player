import Cocoa

/*
    View controller for the Filter effects unit
 */
class FilterViewController: NSViewController, NSMenuDelegate, MessageSubscriber, ActionMessageSubscriber, StringInputClient {
    
    // Filter controls
    @IBOutlet weak var btnFilterBypass: EffectsUnitTriStateBypassButton!
    
    @IBOutlet weak var filterView: FilterView!
    
    // Presets menu
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    
    private lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    private lazy var editor: FilterBandEditorController = FilterBandEditorController()
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    private let filterPresets: FilterPresets = ObjectGraph.getAudioGraphDelegate().filterPresets
    
    override var nibName: String? {return "Filter"}
    
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
        
        // Initialize the menu with user-defined presets
        filterPresets.userDefinedPresets.forEach({presetsMenu.insertItem(withTitle: $0.name, at: 0)})
        
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    private func oneTimeSetup() {
        
        let stateFunction = {() -> EffectsUnitState in return self.graph.getFilterState()}
        btnFilterBypass.stateFunction = stateFunction

        let bandsDataFunction = {() -> [FilterBand] in return self.graph.allFilterBands()}
        filterView.initialize(stateFunction, bandsDataFunction, AudioGraphFilterBandsDataSource(graph))
    }
 
    private func initControls() {
        
        btnFilterBypass.updateState()
        filterView.refresh()
        
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
        _ = graph.toggleFilterState()
        
        btnFilterBypass.updateState()
        filterView.redrawChart()
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
    }
    
    @IBAction func editBandAction(_ sender: AnyObject) {
        
        if filterView.numberOfSelectedRows == 1 {
            
            let index = filterView.selectedRow
            editor.editBand(index, graph.getFilterBand(index))
            filterView.bandEdited()
        }
    }
    
    @IBAction func addBandAction(_ sender: AnyObject) {
        
        if editor.showDialog() == .ok {
            filterView.tableRowsAddedOrRemoved()
        }
    }
    
    @IBAction func removeBandsAction(_ sender: AnyObject) {
        
        if filterView.numberOfSelectedRows > 0 {
            
            graph.removeFilterBands(filterView.selectedRows)
            filterView.bandsRemoved()
        }
    }
    
    @IBAction func removeAllBandsAction(_ sender: AnyObject) {
        graph.removeAllFilterBands()
        filterView.tableRowsAddedOrRemoved()
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
        
        let valid = !filterPresets.presetWithNameExists(string)
        
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
            filterView.redrawChart()
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
