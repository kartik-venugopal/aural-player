import Cocoa

class EffectsPresetsEditorViewController: NSViewController, MessageSubscriber {
    
    private let masterPresetsEditorView: NSView = ViewFactory.getMasterPresetsEditorView()
    private let eqPresetsEditorView: NSView = ViewFactory.getEQPresetsEditorView()
    private let pitchPresetsEditorView: NSView = ViewFactory.getPitchPresetsEditorView()
    private let timePresetsEditorView: NSView = ViewFactory.getTimePresetsEditorView()
    
    // Tab view and its buttons
    
    @IBOutlet weak var fxPresetsTabView: NSTabView!
    
    private var fxPresetsTabViewButtons: [EffectsUnitTabButton]?
    
    @IBOutlet weak var masterPresetsTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var eqPresetsTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var pitchPresetsTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var timePresetsTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var reverbPresetsTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var delayPresetsTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var filterPresetsTabViewButton: EffectsUnitTabButton!
    
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var btnApply: NSButton!
    @IBOutlet weak var btnRename: NSButton!
    
    override var nibName: String? {return "EffectsPresetsEditor"}
    
    override func viewDidAppear() {
        
        addSubViews()
        [btnApply, btnRename, btnDelete].forEach({$0.isEnabled = false})
        tabViewAction(timePresetsTabViewButton)
        
        SyncMessenger.subscribe(messageTypes: [.editorSelectionChangedNotification], subscriber: self)
    }
    
    private func addSubViews() {
        
        fxPresetsTabView.tabViewItem(at: 0).view?.addSubview(masterPresetsEditorView)
        fxPresetsTabView.tabViewItem(at: 1).view?.addSubview(eqPresetsEditorView)
        fxPresetsTabView.tabViewItem(at: 2).view?.addSubview(pitchPresetsEditorView)
        fxPresetsTabView.tabViewItem(at: 3).view?.addSubview(timePresetsEditorView)
        
        fxPresetsTabViewButtons = [masterPresetsTabViewButton, eqPresetsTabViewButton, pitchPresetsTabViewButton, timePresetsTabViewButton, reverbPresetsTabViewButton, delayPresetsTabViewButton, filterPresetsTabViewButton]
    }
    
    // Switches the tab group to a particular tab
    @IBAction func tabViewAction(_ sender: NSButton) {
        
        // Set sender button state, reset all other button states
        fxPresetsTabViewButtons!.forEach({$0.state = UIConstants.buttonState_0})
        sender.state = UIConstants.buttonState_1
        
        // Button tag is the tab index
        fxPresetsTabView.selectTabViewItem(at: sender.tag)
    }
    
    @IBAction func renamePresetAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(EffectsPresetsEditorActionMessage(.renameEffectsPreset, effectsUnit()))
    }
    
    @IBAction func deletePresetsAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(EffectsPresetsEditorActionMessage(.deleteEffectsPresets, effectsUnit()))
    }
    
    @IBAction func applyPresetAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(EffectsPresetsEditorActionMessage(.applyEffectsPreset, effectsUnit()))
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        
        WindowState.showingPopover = false
        UIUtils.dismissModalDialog()
    }
    
    private func updateButtonStates(_ selRows: Int) {
        
        btnDelete.isEnabled = selRows > 0
        [btnApply, btnRename].forEach({$0.isEnabled = selRows == 1})
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AuralTableRowView()
    }
    
    private func effectsUnit() -> EffectsUnit {
        
        let id = fxPresetsTabView.selectedTabViewItem!.identifier as! String
        let selItem = Int(id)
        
        switch selItem {
            
        case 0: return .master
            
        case 1: return .eq
            
        case 2: return .pitch
            
        case 3: return .time
            
        case 4: return .reverb
            
        case 5: return .delay
            
        case 6: return .filter
            
        default: return .master
            
        }
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let msg = notification as? EditorSelectionChangedNotification {
            updateButtonStates(msg.numberOfSelectedRows)
        }
    }
}
