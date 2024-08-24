//
//  EffectsContainerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class EffectsContainerViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"EffectsContainer"}
    
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
    private let replayGainViewController: ReplayGainUnitViewController = ReplayGainUnitViewController()
    
    private let auViewController: AudioUnitsViewController = AudioUnitsViewController()
    private let devicesViewController: DevicesViewController = DevicesViewController()
    
    private lazy var viewControllers = [masterViewController, eqViewController, pitchViewController, timeViewController,
                                        reverbViewController, delayViewController, filterViewController, replayGainViewController, auViewController, devicesViewController]

    // Tab view and its buttons

    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var lblCaption: NSTextField!

    @IBOutlet weak var masterTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var eqTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var pitchTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var timeTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var reverbTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var delayTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var filterTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var replayGainTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var auTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var devicesTabViewButton: EffectsUnitTabButton!

    private lazy var tabViewButtons: [EffectsUnitTabButton] = [masterTabViewButton, eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton,
                                                                                delayTabViewButton, filterTabViewButton, replayGainTabViewButton, auTabViewButton, devicesTabViewButton]
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties

    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = audioGraphDelegate
    
    private let viewPreferences: ViewPreferences = preferences.viewPreferences

    private lazy var messenger = Messenger(for: self)
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Fallback image on older systems
        masterTabViewButton.image = .imgMasterUnit
        
        if System.osVersion.majorVersion == 11, let cell = masterTabViewButton.cell as? EffectsUnitTabButtonCell {
            
            cell.imgWidth = 13
            cell.imgHeight = 13
        }
        
        // Initialize all sub-views
        initTabGroup()
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceivers: [rootContainerBox] + tabViewButtons)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.activeControlColor, handler: activeControlColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.inactiveControlColor, handler: inactiveControlColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.suppressedControlColor, handler: suppressedControlColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, handler: buttonColorChanged(_:))
        
        initSubscriptions()
    }
    
    private func initTabGroup() {
        
        for (index, viewController) in viewControllers.enumerated() {
            
            tabView.tabViewItem(at: index).view?.addSubview(viewController.view)
            viewController.view.anchorToSuperview()
        }

        fxUnitStateObserverRegistry.registerObserver(masterTabViewButton, forFXUnit: audioGraphDelegate.masterUnit)
        fxUnitStateObserverRegistry.registerObserver(eqTabViewButton, forFXUnit: audioGraphDelegate.eqUnit)
        fxUnitStateObserverRegistry.registerObserver(pitchTabViewButton, forFXUnit: audioGraphDelegate.pitchShiftUnit)
        fxUnitStateObserverRegistry.registerObserver(timeTabViewButton, forFXUnit: audioGraphDelegate.timeStretchUnit)
        fxUnitStateObserverRegistry.registerObserver(reverbTabViewButton, forFXUnit: audioGraphDelegate.reverbUnit)
        fxUnitStateObserverRegistry.registerObserver(delayTabViewButton, forFXUnit: audioGraphDelegate.delayUnit)
        fxUnitStateObserverRegistry.registerObserver(filterTabViewButton, forFXUnit: audioGraphDelegate.filterUnit)
        fxUnitStateObserverRegistry.registerObserver(replayGainTabViewButton, forFXUnit: audioGraphDelegate.replayGainUnit)
        
        fxUnitStateObserverRegistry.registerAUObserver(auTabViewButton)
        
        // TODO: Add state observer for AU tab button (complicated - composite function comprising states of individual AUs)
        // Might need an overload of registerObserver that takes a function instead of an FXUnitDelegate.

        auTabViewButton.stateFunction = {[weak self] in
            self?.graph.audioUnits.first(where: {$0.state == .active || $0.state == .suppressed})?.state ?? .bypassed
        }
        
        devicesTabViewButton.stateFunction = {.bypassed}
        
        // Select Master tab view by default
        showTab(.master)
    }

    override func destroy() {
        
        ([masterViewController, eqViewController, pitchViewController, timeViewController, reverbViewController,
          delayViewController, filterViewController, auViewController, devicesViewController] as? [Destroyable])?.forEach {$0.destroy()}
        
        messenger.unsubscribeFromAll()
        fxUnitStateObserverRegistry.removeAllObservers()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions

    // Switches the tab group to a particular tab
    @IBAction func tabViewAction(_ sender: EffectsUnitTabButton) {
        doTabViewAction(sender)
    }
    
    private func doTabViewAction(_ sender: EffectsUnitTabButton) {
        
        // Set sender button state, reset all other button states
        tabViewButtons.forEach {$0.unSelect()}
        sender.select()

        // Button tag is the tab index
        tabView.selectTabViewItem(at: sender.tag)
        lblCaption.stringValue = EffectsUnitType(rawValue: sender.tag)!.caption
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    private func initSubscriptions() {
        
        messenger.subscribe(to: .Effects.showEffectsUnitTab, handler: showTab(_:))
        messenger.subscribeAsync(to: .Effects.auStateChanged, handler: auTabViewButton.redraw)
    }

    func showTab(_ effectsUnitType: EffectsUnitType) {
        
        switch effectsUnitType {
        
        case .master: doTabViewAction(masterTabViewButton)

        case .eq: doTabViewAction(eqTabViewButton)

        case .pitch: doTabViewAction(pitchTabViewButton)

        case .time: doTabViewAction(timeTabViewButton)

        case .reverb: doTabViewAction(reverbTabViewButton)

        case .delay: doTabViewAction(delayTabViewButton)

        case .filter: doTabViewAction(filterTabViewButton)
            
        case .replayGain: doTabViewAction(replayGainTabViewButton)
            
        case .au: doTabViewAction(auTabViewButton)
            
        case .devices:  doTabViewAction(devicesTabViewButton)

        }
    }
    
    func changeCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }
}

extension EffectsContainerViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        lblCaption.font = systemFontScheme.captionFont
    }
}

extension EffectsContainerViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        lblCaption.textColor = systemColorScheme.captionTextColor
        tabViewButtons.forEach {$0.redraw()}
    }
    
    private func activeControlColorChanged(_ newColor: NSColor) {
        updateTabButtons(forUnitState: .active, newColor: newColor)
    }
    
    private func inactiveControlColorChanged(_ newColor: NSColor) {
        
        updateTabButtons(forUnitState: .bypassed, newColor: newColor)
        devicesTabViewButton.redraw()
    }
    
    private func suppressedControlColorChanged(_ newColor: NSColor) {
        updateTabButtons(forUnitState: .suppressed, newColor: newColor)
    }
    
    private func updateTabButtons(forUnitState unitState: EffectsUnitState, newColor: NSColor) {
        
        if graph.masterUnit.state == unitState {
            masterTabViewButton.redraw()
        }
        
        if graph.eqUnit.state == unitState {
            eqTabViewButton.redraw()
        }
        
        if graph.pitchShiftUnit.state == unitState {
            pitchTabViewButton.redraw()
        }
        
        if graph.timeStretchUnit.state == unitState {
            timeTabViewButton.redraw()
        }
        
        if graph.reverbUnit.state == unitState {
            reverbTabViewButton.redraw()
        }
        
        if graph.delayUnit.state == unitState {
            delayTabViewButton.redraw()
        }
        
        if graph.filterUnit.state == unitState {
            filterTabViewButton.redraw()
        }
        
        if graph.replayGainUnit.state == unitState {
            replayGainTabViewButton.redraw()
        }
        
        if graph.audioUnitsStateFunction() == unitState {
            auTabViewButton.redraw()
        }
    }
    
    private func buttonColorChanged(_ newColor: NSColor) {
        tabViewButtons[tabView.selectedIndex].redraw()
    }
}
