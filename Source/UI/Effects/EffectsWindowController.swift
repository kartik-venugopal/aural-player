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
    
    override var windowNibName: String? {"EffectsWindow"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var rootContainerBox: NSBox!

    // The constituent sub-views, one for each effects unit
    
    private let masterViewController: MasterUnitViewController = MasterUnitViewController()
    private let eqViewController: EQUnitViewController = EQUnitViewController()
    private let pitchViewController: PitchShiftUnitViewController = PitchShiftUnitViewController()
    private let timeViewController: TimeStretchUnitViewController = TimeStretchUnitViewController()
    private let reverbViewController: ReverbUnitViewController = ReverbUnitViewController()
    private let delayViewController: DelayUnitViewController = DelayUnitViewController()
    private let filterViewController: FilterUnitViewController = FilterUnitViewController()
    private let auViewController: AudioUnitsViewController = AudioUnitsViewController()

    // Tab view and its buttons

    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var lblDisplayedUnit: NSTextField!

    @IBOutlet weak var masterTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var eqTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var pitchTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var timeTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var reverbTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var delayTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var filterTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var auTabViewButton: EffectsUnitTabButton!

    private var tabViewButtons: [EffectsUnitTabButton] = []
    
    @IBOutlet weak var btnClose: TintedImageButton!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties

    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = objectGraph.audioGraphDelegate
    
    private let preferences: ViewPreferences = objectGraph.preferences.viewPreferences

    private lazy var messenger = Messenger(for: self)
    
    private let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    
    private let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    private lazy var windowLayoutsManager: WindowLayoutsManager = objectGraph.windowLayoutsManager
    
    private lazy var uiState: WindowAppearanceState = objectGraph.windowAppearanceState
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle

    override func windowDidLoad() {
        
        theWindow.isMovableByWindowBackground = true
        
        // Initialize all sub-views
        initTabGroup()

        btnClose.tintFunction = {Colors.functionButtonColor}
        
        applyTheme()
        
        initUnits()
        initSubscriptions()
    }

    private func initTabGroup() {
        
        for (index, viewController) in [masterViewController, eqViewController, pitchViewController, timeViewController, reverbViewController, delayViewController, filterViewController, auViewController].enumerated() {
            
            tabView.tabViewItem(at: index).view?.addSubview(viewController.view)
        }

        tabViewButtons = [masterTabViewButton, eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton, delayTabViewButton, filterTabViewButton, auTabViewButton]
        
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
        
        // Select Master tab view by default
        tabViewAction(timeTabViewButton)
    }

    private func initUnits() {
        tabViewButtons.forEach {$0.updateState()}
    }

    func destroy() {
        
        ([masterViewController, eqViewController, pitchViewController, timeViewController, reverbViewController,
          delayViewController, filterViewController, auViewController] as? [Destroyable])?.forEach {$0.destroy()}
        
        close()
        messenger.unsubscribeFromAll()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions

    // Switches the tab group to a particular tab
    @IBAction func tabViewAction(_ sender: EffectsUnitTabButton) {

        // Set sender button state, reset all other button states
        tabViewButtons.forEach {$0.unSelect()}
        sender.select()

        // Button tag is the tab index
        tabView.selectTabViewItem(at: sender.tag)
        lblDisplayedUnit.stringValue = EffectsUnitType(rawValue: sender.tag)!.caption
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        windowLayoutsManager.hideEffectsWindow()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    private func initSubscriptions() {

        messenger.subscribe(to: .effects_unitStateChanged, handler: stateChanged)
        
        messenger.subscribe(to: .effects_showEffectsUnitTab, handler: showTab(_:))
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyFontScheme, handler: applyFontScheme(_:))
        messenger.subscribe(to: .applyColorScheme, handler: applyColorScheme(_:))
        messenger.subscribe(to: .changeBackgroundColor, handler: changeBackgroundColor(_:))
        messenger.subscribe(to: .changeFunctionButtonColor, handler: changeFunctionButtonColor(_:))
        messenger.subscribe(to: .changeSelectedTabButtonColor, handler: changeSelectedTabButtonColor(_:))
        messenger.subscribe(to: .windowAppearance_changeCornerRadius, handler: changeWindowCornerRadius(_:))
        
        messenger.subscribe(to: .effects_changeActiveUnitStateColor, handler: changeActiveUnitStateColor(_:))
        messenger.subscribe(to: .effects_changeBypassedUnitStateColor, handler: changeBypassedUnitStateColor(_:))
        messenger.subscribe(to: .effects_changeSuppressedUnitStateColor, handler: changeSuppressedUnitStateColor(_:))
    }

    // Notification that an effect unit's state has changed (active/inactive)
    private func stateChanged() {

        // Update the tab button states
        tabViewButtons.forEach {$0.updateState()}
    }
    
    private func showTab(_ effectsUnitType: EffectsUnitType) {
        
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
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    private func applyTheme() {
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
        changeWindowCornerRadius(uiState.cornerRadius)
    }
    
    private func applyFontScheme(_ scheme: FontScheme) {
        lblDisplayedUnit.font = scheme.effects.unitCaptionFont
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeFunctionButtonColor(scheme.general.functionButtonColor)
        
        tabViewButtons.forEach {$0.reTint()}
        lblDisplayedUnit.textColor = scheme.general.mainCaptionTextColor
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        rootContainerBox.fillColor = color
        tabViewButtons.forEach {$0.redraw()}
    }
    
    private func changeFunctionButtonColor(_ color: NSColor) {
        btnClose.reTint()
    }
    
    private func changeActiveUnitStateColor(_ color: NSColor) {
        
        tabViewButtons.filter {$0.unitState == .active}.forEach {
            $0.reTint()
        }
    }
    
    private func changeBypassedUnitStateColor(_ color: NSColor) {
        
        tabViewButtons.filter {$0.unitState == .bypassed}.forEach {
            $0.reTint()
        }
    }
    
    private func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        tabViewButtons.filter {$0.unitState == .suppressed}.forEach {
            $0.reTint()
        }
    }
    
    private func changeSelectedTabButtonColor(_ color: NSColor) {
        tabViewButtons[tabView.selectedIndex].redraw()
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }
}
