import Cocoa

/*
    View controller for the Filter effects unit
 */
class FilterViewController: NSViewController, NSMenuDelegate, MessageSubscriber, ActionMessageSubscriber, StringInputClient {
    
    // Filter controls
    @IBOutlet weak var btnFilterBypass: EffectsUnitTriStateBypassButton!
    
    // Presets menu
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: NSButton!
    
    @IBOutlet weak var bandsTable: NSTableView!
    @IBOutlet weak var tableViewDelegate: FilterBandsViewDelegate!
    
    @IBOutlet weak var chart: FilterChart!
    
    private lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    private lazy var editor: FilterBandEditorController = FilterBandEditorController()
    
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
        
        chart.bandsDataFunction = {() -> [FilterBand] in
            return self.graph.allFilterBands()
        }
        
        chart.filterUnitStateFunction = {() -> EffectsUnitState in return self.graph.getFilterState()}
        
        tableViewDelegate.dataSource = AudioGraphFilterBandsDataSource(graph)
    }
 
    private func initControls() {
        
        btnFilterBypass.updateState()
        chart.redraw()
        bandsTable.reloadData()
        
        // Don't select any items from the presets menu
        presetsMenu.selectItem(at: -1)
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
        _ = graph.toggleFilterState()
        
        btnFilterBypass.updateState()
        chart.redraw()
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
    }
    
    @IBAction func editBandAction(_ sender: AnyObject) {
        
        if bandsTable.numberOfSelectedRows == 1 {
            
            let index = bandsTable.selectedRow
            editor.editBand(index, graph.getFilterBand(index))
            bandsTable.reloadData(forRowIndexes: IndexSet([index]), columnIndexes: [0, 1])
            chart!.redraw()
        }
    }
    
    @IBAction func addBandAction(_ sender: AnyObject) {
        
        if editor.showDialog() == .ok {
            
            bandsTable.noteNumberOfRowsChanged()
            chart.redraw()
        }
    }
    
    @IBAction func removeBandsAction(_ sender: AnyObject) {
        
        if bandsTable.numberOfSelectedRows > 0 {
            
            graph.removeFilterBands(bandsTable.selectedRowIndexes)
            
            bandsTable.reloadData()
            bandsTable.selectRowIndexes(IndexSet([]), byExtendingSelection: false)
            
            chart.redraw()
        }
    }
    
    @IBAction func removeAllBandsAction(_ sender: AnyObject) {
        graph.removeAllFilterBands()
        bandsTable.noteNumberOfRowsChanged()
        chart.redraw()
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
            chart.redraw()
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
