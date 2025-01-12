//
//  EffectsPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
        messenger.subscribe(to: .PresetsManager.selectionChanged, handler: managerSelectionChanged(numberOfSelectedRows:))
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
            messenger.publish(.PresetsManager.Effects.reload, payload: unitType)
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
        displayedViewController.renameSelectedPreset()
    }
    
    @IBAction func deletePresetsAction(_ sender: AnyObject) {
        displayedViewController.deleteSelectedPresets()
    }
    
    @IBAction func applyPresetAction(_ sender: AnyObject) {
        displayedViewController.applySelectedPreset()
    }
    
    private func updateButtonStates(numberOfSelectedRows: Int) {
        
        btnDelete.enableIf(numberOfSelectedRows > 0)
        [btnApply, btnRename].forEach {$0.enableIf(numberOfSelectedRows == 1)}
    }
    
    private var displayedViewController: EffectsPresetsManagerGenericViewController {
        
        switch tabView.selectedIndex {
            
        case 0: return masterPresetsManagerViewController
            
        case 1: return eqPresetsManagerViewController
            
        case 2: return pitchPresetsManagerViewController
            
        case 3: return timePresetsManagerViewController
            
        case 4: return reverbPresetsManagerViewController
            
        case 5: return delayPresetsManagerViewController
            
        case 6: return filterPresetsManagerViewController
            
        default: return masterPresetsManagerViewController
            
        }
    }
    
    private var effectsUnit: EffectsUnitType {
        displayedViewController.unitType
    }
    
    // MARK: Message handling
    
    func managerSelectionChanged(numberOfSelectedRows: Int) {
        updateButtonStates(numberOfSelectedRows: numberOfSelectedRows)
    }
}
