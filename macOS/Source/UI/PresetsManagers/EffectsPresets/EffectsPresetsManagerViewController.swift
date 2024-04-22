//
//  EffectsPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class EffectsPresetsManagerViewController: NSViewController {
    
    private let masterPresetsManagerViewController: MasterPresetsManagerViewController = MasterPresetsManagerViewController()
    private let eqPresetsManagerViewController: EQPresetsManagerViewController = EQPresetsManagerViewController()
    private let pitchPresetsManagerViewController: PitchShiftPresetsManagerViewController = PitchShiftPresetsManagerViewController()
    private let timePresetsManagerViewController: TimeStretchPresetsManagerViewController = TimeStretchPresetsManagerViewController()
    private let reverbPresetsManagerViewController: ReverbPresetsManagerViewController = ReverbPresetsManagerViewController()
    private let delayPresetsManagerViewController: DelayPresetsManagerViewController = DelayPresetsManagerViewController()
    private let filterPresetsManagerViewController: FilterPresetsManagerViewController = FilterPresetsManagerViewController()
    
    // Tab view and its buttons
    
    @IBOutlet weak var tabView: NSTabView!
    
    private var tabViewButtons: [NSButton] = []
    
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
    
    private lazy var messenger = Messenger(for: self)
    
    override var nibName: String? {"EffectsPresetsManager"}
    
    override func viewDidLoad() {
        
        viewControllers = [masterPresetsManagerViewController, eqPresetsManagerViewController, pitchPresetsManagerViewController, timePresetsManagerViewController, reverbPresetsManagerViewController, delayPresetsManagerViewController, filterPresetsManagerViewController]
        
        addSubViews()
        messenger.subscribe(to: .presetsManager_selectionChanged, handler: managerSelectionChanged(_:))
    }
    
    override func destroy() {
        
        viewControllers.forEach {$0.destroy()}
        messenger.unsubscribeFromAll()
    }
    
    override func viewDidAppear() {
        
        [btnApply, btnRename, btnDelete].forEach {$0.disable()}
        tabViewAction(masterPresetsTabViewButton)
        
        for unitType: EffectsUnitType in [.master, .eq, .pitch, .time, .reverb, .delay, .filter] {
            messenger.publish(.effectsPresetsManager_reload, payload: unitType)
        }
    }
    
    private func addSubViews() {
        
        for (index, viewController) in viewControllers.enumerated() {
            tabView.tabViewItem(at: index).view?.addSubview(viewController.view)
        }
        
        tabViewButtons = [masterPresetsTabViewButton, eqPresetsTabViewButton, pitchPresetsTabViewButton, timePresetsTabViewButton, reverbPresetsTabViewButton, delayPresetsTabViewButton, filterPresetsTabViewButton]
    }
    
    // Switches the tab group to a particular tab
    @IBAction func tabViewAction(_ sender: NSButton) {
        
        // Set sender button state, reset all other button states
        tabViewButtons.forEach {$0.off()}
        sender.on()
        
        // Button tag is the tab index
        tabView.selectTabViewItem(at: sender.tag)
        
        // Reset button states when switching to a new tab.
        updateButtonStates(0)
    }
    
    @IBAction func previousTabAction(_ sender: Any) {
        
        tabView.previousTab(self)
        
        tabViewButtons.forEach {
            $0.onIf($0.tag == tabView.selectedIndex)
        }
    }
    
    @IBAction func nextTabAction(_ sender: Any) {
        
        tabView.nextTab(self)
        
        tabViewButtons.forEach {
            $0.onIf($0.tag == tabView.selectedIndex)
        }
    }
    
    @IBAction func renamePresetAction(_ sender: AnyObject) {
        messenger.publish(.effectsPresetsManager_rename, payload: effectsUnit)
    }
    
    @IBAction func deletePresetsAction(_ sender: AnyObject) {
        messenger.publish(.effectsPresetsManager_delete, payload: effectsUnit)
    }
    
    @IBAction func applyPresetAction(_ sender: AnyObject) {
        messenger.publish(.effectsPresetsManager_apply, payload: effectsUnit)
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.view.window?.close()
    }
    
    private func updateButtonStates(_ selRows: Int) {
        
        btnDelete.enableIf(selRows > 0)
        [btnApply, btnRename].forEach {$0.enableIf(selRows == 1)}
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        GenericTableRowView()
    }
    
    private var effectsUnit: EffectsUnitType {
        
        switch tabView.selectedIndex {
            
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
