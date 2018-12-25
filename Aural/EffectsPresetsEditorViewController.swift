import Cocoa

class EffectsPresetsEditorViewController: NSViewController, MessageSubscriber {
    
    private let masterPresetsEditorView: NSView = ViewFactory.getMasterPresetsEditorView()
    private let eqPresetsEditorView: NSView = ViewFactory.getEQPresetsEditorView()
    private let pitchPresetsEditorView: NSView = ViewFactory.getPitchPresetsEditorView()
    private let timePresetsEditorView: NSView = ViewFactory.getTimePresetsEditorView()
    private let reverbPresetsEditorView: NSView = ViewFactory.getReverbPresetsEditorView()
    private let delayPresetsEditorView: NSView = ViewFactory.getDelayPresetsEditorView()
    private let filterPresetsEditorView: NSView = ViewFactory.getFilterPresetsEditorView()
    
    // Tab view and its buttons
    
    @IBOutlet weak var fxPresetsTabView: NSTabView!
    
    private var fxPresetsTabViewButtons: [NSButton]?
    
    @IBOutlet weak var masterPresetsTabViewButton: NSButton!
    @IBOutlet weak var eqPresetsTabViewButton: NSButton!
    @IBOutlet weak var pitchPresetsTabViewButton: NSButton!
    @IBOutlet weak var timePresetsTabViewButton: NSButton!
    @IBOutlet weak var reverbPresetsTabViewButton: NSButton!
    @IBOutlet weak var delayPresetsTabViewButton: NSButton!
    @IBOutlet weak var filterPresetsTabViewButton: NSButton!
    
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var btnApply: NSButton!
    @IBOutlet weak var btnRename: NSButton!
    
    override var nibName: String? {return "EffectsPresetsEditor"}
    
    override func viewDidLoad() {
        
        addSubViews()
        SyncMessenger.subscribe(messageTypes: [.editorSelectionChangedNotification], subscriber: self)
    }
    
    override func viewDidAppear() {
        
        [btnApply, btnRename, btnDelete].forEach({$0.disable()})
        tabViewAction(masterPresetsTabViewButton)
        
        let units: [EffectsUnit] = [.master, .eq, .pitch, .time, .reverb, .delay, .filter]
        units.forEach({SyncMessenger.publishActionMessage(EffectsPresetsEditorActionMessage(.reloadPresets, $0))})
    }
    
    private func addSubViews() {
        
        fxPresetsTabView.tabViewItem(at: 0).view?.addSubview(masterPresetsEditorView)
        fxPresetsTabView.tabViewItem(at: 1).view?.addSubview(eqPresetsEditorView)
        fxPresetsTabView.tabViewItem(at: 2).view?.addSubview(pitchPresetsEditorView)
        fxPresetsTabView.tabViewItem(at: 3).view?.addSubview(timePresetsEditorView)
        fxPresetsTabView.tabViewItem(at: 4).view?.addSubview(reverbPresetsEditorView)
        fxPresetsTabView.tabViewItem(at: 5).view?.addSubview(delayPresetsEditorView)
        fxPresetsTabView.tabViewItem(at: 6).view?.addSubview(filterPresetsEditorView)
        
        fxPresetsTabViewButtons = [masterPresetsTabViewButton, eqPresetsTabViewButton, pitchPresetsTabViewButton, timePresetsTabViewButton, reverbPresetsTabViewButton, delayPresetsTabViewButton, filterPresetsTabViewButton]
    }
    
    // Switches the tab group to a particular tab
    @IBAction func tabViewAction(_ sender: NSButton) {
        
        // Set sender button state, reset all other button states
        fxPresetsTabViewButtons!.forEach({$0.off()})
        sender.on()
        
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
        UIUtils.dismissDialog(self.view.window!)
    }
    
    private func updateButtonStates(_ selRows: Int) {
        
        btnDelete.enableIf(selRows > 0)
        [btnApply, btnRename].forEach({$0.enableIf(selRows == 1)})
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
    
    var subscriberId: String {
        return self.className
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let msg = notification as? EditorSelectionChangedNotification {
            updateButtonStates(msg.numberOfSelectedRows)
        }
    }
}
