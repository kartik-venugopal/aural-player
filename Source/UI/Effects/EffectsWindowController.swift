//
//  EffectsWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
 View controller for the Effects panel containing controls that alter the sound output (i.e. controls that affect the audio graph)
 */

import Cocoa

class EffectsWindowController: NSWindowController, Destroyable {
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var effectsContainerBox: NSBox!
    @IBOutlet weak var tabButtonsBox: NSBox!

    // The constituent sub-views, one for each effects unit
    
    private let masterViewController: MasterViewController = MasterViewController()
    private let eqViewController: EQViewController = EQViewController()
    private let pitchViewController: PitchShiftViewController = PitchShiftViewController()
    private let timeViewController: TimeStretchViewController = TimeStretchViewController()
    private let reverbViewController: ReverbViewController = ReverbViewController()
    private let delayViewController: DelayViewController = DelayViewController()
    private let filterViewController: FilterViewController = FilterViewController()
    private let auViewController: AudioUnitsViewController = AudioUnitsViewController()
    private let recorderViewController: RecorderViewController = RecorderViewController()

    // Tab view and its buttons

    @IBOutlet weak var effectsTabView: NSTabView!

    @IBOutlet weak var masterTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var eqTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var pitchTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var timeTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var reverbTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var delayTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var filterTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var auTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var recorderTabViewButton: EffectsUnitTabButton!

    private var effectsTabViewButtons: [EffectsUnitTabButton] = []
    
    @IBOutlet weak var btnClose: TintedImageButton!

    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    private let recorder: RecorderDelegateProtocol = ObjectGraph.recorderDelegate
    
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager

    private let preferences: ViewPreferences = ObjectGraph.preferences.viewPreferences

    override var windowNibName: String? {"Effects"}
    
    private lazy var messenger = Messenger(for: self)

    override func windowDidLoad() {
        
        // Initialize all sub-views
        addSubViews()

        theWindow.isMovableByWindowBackground = true

        btnClose.tintFunction = {return Colors.viewControlButtonColor}
        
        applyColorScheme(colorSchemesManager.systemScheme)
        rootContainerBox.cornerRadius = WindowAppearanceState.cornerRadius
        
        initUnits()
        initTabGroup()
        initSubscriptions()
    }

    private func addSubViews() {
        
        for (index, viewController) in [masterViewController, eqViewController, pitchViewController, timeViewController, reverbViewController, delayViewController, filterViewController, auViewController, recorderViewController].enumerated() {
            
            effectsTabView.tabViewItem(at: index).view?.addSubview(viewController.view)
        }

        effectsTabViewButtons = [masterTabViewButton, eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton, delayTabViewButton, filterTabViewButton, auTabViewButton, recorderTabViewButton]
        
        masterTabViewButton.stateFunction = graph.masterUnit.stateFunction
        eqTabViewButton.stateFunction = graph.eqUnit.stateFunction
        pitchTabViewButton.stateFunction = graph.pitchShiftUnit.stateFunction
        timeTabViewButton.stateFunction = graph.timeStretchUnit.stateFunction
        reverbTabViewButton.stateFunction = graph.reverbUnit.stateFunction
        delayTabViewButton.stateFunction = graph.delayUnit.stateFunction
        filterTabViewButton.stateFunction = graph.filterUnit.stateFunction

        auTabViewButton.stateFunction = {[weak self] in

            for unit in self?.graph.audioUnits ?? [] {

                if unit.state == .active {
                    return .active
                }
                
                if unit.state == .suppressed {
                    return .suppressed
                }
            }
            
            return .bypassed
        }

        recorderTabViewButton.stateFunction = {[weak self] in
            return (self?.recorder.isRecording ?? false) ? .active : .bypassed
        }
    }

    private func initUnits() {
        effectsTabViewButtons.forEach {$0.updateState()}
    }

    private func initTabGroup() {

        // Select Master tab view by default
        tabViewAction(masterTabViewButton)
    }

    private func initSubscriptions() {

        messenger.subscribe(to: .effects_unitStateChanged, handler: stateChanged)
        
        // MARK: Commands ----------------------------------------------------------------------------------------
        
        messenger.subscribe(to: .effects_showEffectsUnitTab, handler: showTab(_:))
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyColorScheme, handler: applyColorScheme(_:))
        messenger.subscribe(to: .changeBackgroundColor, handler: changeBackgroundColor(_:))
        messenger.subscribe(to: .changeViewControlButtonColor, handler: changeViewControlButtonColor(_:))
        messenger.subscribe(to: .changeSelectedTabButtonColor, handler: changeSelectedTabButtonColor(_:))
        messenger.subscribe(to: .windowAppearance_changeCornerRadius, handler: changeWindowCornerRadius(_:))
        
        messenger.subscribe(to: .effects_changeActiveUnitStateColor, handler: changeActiveUnitStateColor(_:))
        messenger.subscribe(to: .effects_changeBypassedUnitStateColor, handler: changeBypassedUnitStateColor(_:))
        messenger.subscribe(to: .effects_changeSuppressedUnitStateColor, handler: changeSuppressedUnitStateColor(_:))
    }
    
    func destroy() {
        
        ([masterViewController, eqViewController, pitchViewController, timeViewController, reverbViewController, delayViewController, filterViewController, auViewController, recorderViewController] as? [Destroyable])?.forEach {$0.destroy()}
        
        close()
        messenger.unsubscribeFromAll()
    }

    // Switches the tab group to a particular tab
    @IBAction func tabViewAction(_ sender: EffectsUnitTabButton) {

        // Set sender button state, reset all other button states
        effectsTabViewButtons.forEach {$0.unSelect()}
        sender.select()

        // Button tag is the tab index
        effectsTabView.selectTabViewItem(at: sender.tag)
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        messenger.publish(.windowManager_toggleEffectsWindow)
    }
    
    private func applyTheme() {
        
        applyColorScheme(colorSchemesManager.systemScheme)
        changeWindowCornerRadius(WindowAppearanceState.cornerRadius)
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeViewControlButtonColor(scheme.general.viewControlButtonColor)
        
        effectsTabViewButtons.forEach({$0.reTint()})
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        rootContainerBox.fillColor = color
        tabButtonsBox.fillColor = color
        
        effectsTabViewButtons.forEach({$0.redraw()})
    }
    
    private func changeViewControlButtonColor(_ color: NSColor) {
        btnClose.reTint()
    }
    
    private func changeActiveUnitStateColor(_ color: NSColor) {
        
        effectsTabViewButtons.forEach({
            
            if $0.unitState == .active {
                $0.reTint()
            }
        })
    }
    
    private func changeBypassedUnitStateColor(_ color: NSColor) {
        
        effectsTabViewButtons.forEach({
            
            if $0.unitState == .bypassed {
                $0.reTint()
            }
        })
    }
    
    private func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        effectsTabViewButtons.forEach({
            
            if $0.unitState == .suppressed {
                $0.reTint()
            }
        })
    }
    
    private func changeSelectedTabButtonColor(_ color: NSColor) {
        effectsTabViewButtons[effectsTabView.selectedIndex].redraw()
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }

    // MARK: Message handling

    // Notification that an effect unit's state has changed (active/inactive)
    func stateChanged() {

        // Update the tab button states
        effectsTabViewButtons.forEach {$0.updateState()}
    }
    
    func showTab(_ effectsUnitType: EffectsUnitType) {
        
        switch effectsUnitType {
        
        case .master: tabViewAction(masterTabViewButton)

        case .eq: tabViewAction(eqTabViewButton)

        case .pitch: tabViewAction(pitchTabViewButton)

        case .time: tabViewAction(timeTabViewButton)

        case .reverb: tabViewAction(reverbTabViewButton)

        case .delay: tabViewAction(delayTabViewButton)

        case .filter: tabViewAction(filterTabViewButton)
            
        case .au: tabViewAction(auTabViewButton)

        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSControlStateValue(_ input: Int) -> NSControl.StateValue {
	return NSControl.StateValue(rawValue: input)
}
