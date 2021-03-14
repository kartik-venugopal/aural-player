import Cocoa

class EffectsPresetsEditorViewController: NSViewController, NotificationSubscriber {
    
    private let masterPresetsEditorView: NSView = ViewFactory.masterPresetsEditorView
    private let eqPresetsEditorView: NSView = ViewFactory.eqPresetsEditorView
    private let pitchPresetsEditorView: NSView = ViewFactory.pitchPresetsEditorView
    private let timePresetsEditorView: NSView = ViewFactory.timePresetsEditorView
    private let reverbPresetsEditorView: NSView = ViewFactory.reverbPresetsEditorView
    private let delayPresetsEditorView: NSView = ViewFactory.delayPresetsEditorView
    private let filterPresetsEditorView: NSView = ViewFactory.filterPresetsEditorView
    
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
        Messenger.subscribe(self, .presetsEditor_selectionChanged, self.editorSelectionChanged(_:))
    }
    
    override func viewDidAppear() {
        
        [btnApply, btnRename, btnDelete].forEach({$0.disable()})
        tabViewAction(masterPresetsTabViewButton)
        
        for unit: EffectsUnit in [.master, .eq, .pitch, .time, .reverb, .delay, .filter] {
            Messenger.publish(.fxPresetsEditor_reload, payload: unit)
        }
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
        Messenger.publish(.fxPresetsEditor_rename, payload: effectsUnit)
    }
    
    @IBAction func deletePresetsAction(_ sender: AnyObject) {
        Messenger.publish(.fxPresetsEditor_delete, payload: effectsUnit)
    }
    
    @IBAction func applyPresetAction(_ sender: AnyObject) {
        Messenger.publish(.fxPresetsEditor_apply, payload: effectsUnit)
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
        return GenericTableRowView()
    }
    
    private var effectsUnit: EffectsUnit {
        
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
    
    func editorSelectionChanged(_ numberOfSelectedRows: Int) {
        updateButtonStates(numberOfSelectedRows)
    }
}
