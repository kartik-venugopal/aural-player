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
    
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var btnApply: NSButton!
    @IBOutlet weak var btnRename: NSButton!
    
    private var viewControllers: [NSViewController] = []
    
    private lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        viewControllers = [masterPresetsManagerViewController, eqPresetsManagerViewController, pitchPresetsManagerViewController, timePresetsManagerViewController, reverbPresetsManagerViewController, delayPresetsManagerViewController, filterPresetsManagerViewController]
        
        addSubViews()
        messenger.subscribe(to: .presetsManager_selectionChanged, handler: managerSelectionChanged(_:))
    }
    
    override func destroy() {
        
        viewControllers.forEach {$0.destroy()}
        messenger.unsubscribeFromAll()
    }
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        
        [btnApply, btnRename, btnDelete].forEach {$0.disable()}
        tabView.selectTabViewItem(at: 0)
        
        for unitType: EffectsUnitType in [.master, .eq, .pitch, .time, .reverb, .delay, .filter] {
            messenger.publish(.effectsPresetsManager_reload, payload: unitType)
        }
    }
    
    private func addSubViews() {
        
        for (index, viewController) in viewControllers.enumerated() {
            
            tabView.tabViewItem(at: index).view?.addSubview(viewController.view)
            viewController.view.anchorToSuperview()
        }
    }
    
    // Switches the tab group to a particular tab
    @IBAction func switchToTabAction(_ sender: NSToolbarItem) {

        // Toolbar Item tag is the tab index
        tabView.selectTabViewItem(at: sender.tag)
        
        // Reset button states when switching to a new tab.
        updateButtonStates(numberOfSelectedRows: 0)
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
    
    private func updateButtonStates(numberOfSelectedRows: Int) {
        
        btnDelete.enableIf(numberOfSelectedRows > 0)
        [btnApply, btnRename].forEach {$0.enableIf(numberOfSelectedRows == 1)}
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
        updateButtonStates(numberOfSelectedRows: numberOfSelectedRows)
    }
}
