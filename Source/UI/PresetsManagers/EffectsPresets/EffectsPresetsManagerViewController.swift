//
//  EffectsPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class EffectsPresetsManagerViewController: NSViewController, NotificationSubscriber, Destroyable {
    
    private let masterPresetsManagerViewController: MasterPresetsManagerViewController = MasterPresetsManagerViewController()
    private let eqPresetsManagerViewController: EQPresetsManagerViewController = EQPresetsManagerViewController()
    private let pitchPresetsManagerViewController: PitchPresetsManagerViewController = PitchPresetsManagerViewController()
    private let timePresetsManagerViewController: TimePresetsManagerViewController = TimePresetsManagerViewController()
    private let reverbPresetsManagerViewController: ReverbPresetsManagerViewController = ReverbPresetsManagerViewController()
    private let delayPresetsManagerViewController: DelayPresetsManagerViewController = DelayPresetsManagerViewController()
    private let filterPresetsManagerViewController: FilterPresetsManagerViewController = FilterPresetsManagerViewController()
    
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
    
    private var viewControllers: [NSViewController] = []
    
    override var nibName: String? {"EffectsPresetsManager"}
    
    override func viewDidLoad() {
        
        viewControllers = [masterPresetsManagerViewController, eqPresetsManagerViewController, pitchPresetsManagerViewController, timePresetsManagerViewController, reverbPresetsManagerViewController, delayPresetsManagerViewController, filterPresetsManagerViewController]
        
        addSubViews()
        Messenger.subscribe(self, .presetsManager_selectionChanged, self.managerSelectionChanged(_:))
    }
    
    func destroy() {
        
        (viewControllers as? [Destroyable])?.forEach {$0.destroy()}
        Messenger.unsubscribeAll(for: self)
    }
    
    override func viewDidAppear() {
        
        [btnApply, btnRename, btnDelete].forEach({$0.disable()})
        tabViewAction(masterPresetsTabViewButton)
        
        for unit: EffectsUnit in [.master, .eq, .pitch, .time, .reverb, .delay, .filter] {
            Messenger.publish(.fxPresetsManager_reload, payload: unit)
        }
    }
    
    private func addSubViews() {
        
        for (index, viewController) in viewControllers.enumerated() {
            fxPresetsTabView.tabViewItem(at: index).view?.addSubview(viewController.view)
        }
        
        fxPresetsTabViewButtons = [masterPresetsTabViewButton, eqPresetsTabViewButton, pitchPresetsTabViewButton, timePresetsTabViewButton, reverbPresetsTabViewButton, delayPresetsTabViewButton, filterPresetsTabViewButton]
    }
    
    // Switches the tab group to a particular tab
    @IBAction func tabViewAction(_ sender: NSButton) {
        
        // Set sender button state, reset all other button states
        fxPresetsTabViewButtons!.forEach({$0.off()})
        sender.on()
        
        // Button tag is the tab index
        fxPresetsTabView.selectTabViewItem(at: sender.tag)
        
        // Reset button states when switching to a new tab.
        updateButtonStates(0)
    }
    
    @IBAction func previousTabAction(_ sender: Any) {
        
        fxPresetsTabView.previousTab(self)
        
        fxPresetsTabViewButtons!.forEach({
            $0.onIf($0.tag == fxPresetsTabView.selectedIndex)
        })
    }
    
    @IBAction func nextTabAction(_ sender: Any) {
        
        fxPresetsTabView.nextTab(self)
        
        fxPresetsTabViewButtons!.forEach({
            $0.onIf($0.tag == fxPresetsTabView.selectedIndex)
        })
    }
    
    @IBAction func renamePresetAction(_ sender: AnyObject) {
        Messenger.publish(.fxPresetsManager_rename, payload: effectsUnit)
    }
    
    @IBAction func deletePresetsAction(_ sender: AnyObject) {
        Messenger.publish(.fxPresetsManager_delete, payload: effectsUnit)
    }
    
    @IBAction func applyPresetAction(_ sender: AnyObject) {
        Messenger.publish(.fxPresetsManager_apply, payload: effectsUnit)
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.view.window!.close()
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
    
    func managerSelectionChanged(_ numberOfSelectedRows: Int) {
        updateButtonStates(numberOfSelectedRows)
    }
}
