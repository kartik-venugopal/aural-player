//
//  EffectsUnitViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class EffectsUnitViewController: NSViewController, FontSchemeObserver, ColorSchemeObserver {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields

    @IBOutlet weak var btnBypass: EffectsUnitTriStateBypassButton!
    
    // Presets controls
    @IBOutlet weak var presetsAndSettingsMenuButton: NSPopUpButton!
    @IBOutlet weak var presetsAndSettingsMenuIconItem: NSMenuItem!
    @IBOutlet weak var loadPresetsMenuItem: NSMenuItem!
    @IBOutlet weak var presetsAndSettingsMenu: NSMenu!
    lazy var userPresetsPopover: StringInputPopoverViewController = .create(self)
    
    @IBOutlet weak var renderQualityMenu: NSMenu!
    lazy var renderQualityMenuViewController: RenderQualityMenuViewController = RenderQualityMenuViewController()
    
    // Labels
    var functionLabels: [NSTextField] = []
    var functionCaptionLabels: [NSTextField] = []
    var functionValueLabels: [NSTextField] = []
    
    var buttons: [TintedImageButton] = []
    var sliders: [EffectsUnitSlider] = []
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    var effectsUnit: (any EffectsUnitProtocol)!
    var unitType: EffectsUnitType {effectsUnit.unitType}
    var unitStateFunction: EffectsUnitStateFunction {effectsUnit.stateFunction}
    
    var presetsWrapper: PresetsWrapperProtocol!
    
    lazy var messenger = Messenger(for: self)
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func viewDidLoad() {
        
        oneTimeSetup()
        initControls()
    }
    
    func oneTimeSetup() {
        
        findThemeableComponents(under: view)
        
        presetsAndSettingsMenuButton.font = .menuFont
        
        presetsAndSettingsMenu?.items.forEach {
            
            $0.action = presetsAndSettingsMenuButton.action
            $0.target = presetsAndSettingsMenuButton.target
        }
        
        if let theRenderQualityMenu = renderQualityMenu {
            
            renderQualityMenuViewController.effectsUnit = effectsUnit
            theRenderQualityMenu.items.first?.view = renderQualityMenuViewController.view
            theRenderQualityMenu.delegate = renderQualityMenuViewController
        }
        
        initSubscriptions()
    }
    
    func findThemeableComponents(under view: NSView) {
        
        for subview in view.subviews {
            
            if let label = subview as? NSTextField {
                
                if label is FunctionLabel {
                    functionLabels.append(label)
                }
                
                if label is FunctionCaptionLabel {
                    functionCaptionLabels.append(label)
                    
                } else if label is FunctionValueLabel {
                    functionValueLabels.append(label)
                }
                
            } else if let btn = subview as? TintedImageButton {
                
                buttons.append(btn)
                
            } else if let slider = subview as? EffectsUnitSlider {
                
                sliders.append(slider)
                
            } else {
                
                // Recursive call
                findThemeableComponents(under: subview)
            }
        }
    }
    
    override func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    func initControls() {
        
        stateChanged()
        presetsAndSettingsMenuButton.deselect()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    @IBAction func bypassAction(_ sender: AnyObject) {

        _ = effectsUnit.toggleState()
        stateChanged()
        
        messenger.publish(.Effects.unitStateChanged)
    }
    
    // Applies a preset to the effects unit
    @IBAction func presetsAction(_ sender: AnyObject) {
        
        effectsUnit.applyPreset(named: sender.title)
        initControls()
    }
    
    // Displays a popover to allow the user to name the new custom preset
    @IBAction func savePresetAction(_ sender: AnyObject) {
        userPresetsPopover.show(presetsAndSettingsMenuButton, .maxX)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    func initSubscriptions() {
        
        fxUnitStateObserverRegistry.registerObserver(btnBypass, forFXUnit: effectsUnit)
        
        // Subscribe to notifications
        messenger.subscribe(to: .Effects.unitStateChanged, handler: stateChanged)
        
        // FIXME: Revisit this filter logic.
        messenger.subscribe(to: .Effects.updateEffectsUnitView,
                            handler: initControls,
                            filter: {[weak self] (unitType: EffectsUnitType) in
                                unitType.equalsOneOf(self?.unitType, .master)
                            })
        
        messenger.subscribe(to: .Effects.showPresetsAndSettingsMenu, handler: presetsAndSettingsMenuButton.show)
        messenger.subscribe(to: .Effects.hidePresetsAndSettingsMenu, handler: presetsAndSettingsMenuButton.hide)
        
        presetsAndSettingsMenuButton.hide()
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        
//        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: presetsAndSettingsMenuIconItem)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: presetsAndSettingsMenuButton)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, changeReceivers: functionCaptionLabels)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primaryTextColor, changeReceivers: functionValueLabels)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceivers: buttons)

        colorSchemesManager.registerPropertyObserver(self, forProperty: \.activeControlColor, handler: activeControlColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.inactiveControlColor, handler: inactiveControlColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.suppressedControlColor, handler: suppressedControlColorChanged(_:))
        
        sliders.forEach {
            fxUnitStateObserverRegistry.registerObserver($0, forFXUnit: effectsUnit)
        }
    }
    
    func stateChanged() {}
    
    // ------------------------------------------------------------------------
    
    // MARK: Helper functions
    
    func showThisTab() {
        messenger.publish(.Effects.showEffectsUnitTab, payload: unitType)
    }
    
    func fontSchemeChanged() {
        
        (functionLabels + functionValueLabels).forEach {
            $0.font = systemFontScheme.smallFont
        }
    }
    
    func colorSchemeChanged() {
        
        btnBypass.contentTintColor = systemColorScheme.colorForEffectsUnitState(self.effectsUnit.state)
//        presetsAndSettingsMenuIconItem.colorChanged(systemColorScheme.buttonColor)
        presetsAndSettingsMenuButton.colorChanged(systemColorScheme.buttonColor)
        
        functionCaptionLabels.forEach {
            $0.textColor = systemColorScheme.secondaryTextColor
        }
        
        functionValueLabels.forEach {
            $0.textColor = systemColorScheme.primaryTextColor
        }
        
        buttons.forEach {
            $0.contentTintColor = systemColorScheme.buttonColor
        }
        
        redrawSliders()
    }
    
    func activeControlColorChanged(_ newColor: NSColor) {
        
        guard self.effectsUnit.state == .active else {return}
        
        btnBypass.contentTintColor = newColor
        redrawSliders()
    }
    
    func inactiveControlColorChanged(_ newColor: NSColor) {
        
        if self.effectsUnit.state == .bypassed {
            btnBypass.contentTintColor = newColor
        }
        
        redrawSliders()
    }
    
    func suppressedControlColorChanged(_ newColor: NSColor) {
        
        guard self.effectsUnit.state == .suppressed else {return}
        
        btnBypass.contentTintColor = newColor
        redrawSliders()
    }
    
    func redrawSliders() {
        
        sliders.forEach {
            $0.redraw()
        }
    }
}

// ------------------------------------------------------------------------

// MARK: StringInputReceiver

extension EffectsUnitViewController: StringInputReceiver {
    
    var inputPrompt: String {
        "Enter a new preset name:"
    }
    
    var defaultValue: String? {
        "<New preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        if presetsWrapper.presetExists(named: string) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        effectsUnit.savePreset(named: string)
    }
}

// ------------------------------------------------------------------------

// MARK: NSMenuDelegate

extension EffectsUnitViewController: NSMenuDelegate {
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        guard presetsWrapper.hasAnyPresets else {

            loadPresetsMenuItem?.disable()
            return
        }

        loadPresetsMenuItem?.enable()
        presetsAndSettingsMenu.recreateMenu(insertingItemsAt: 0, fromItems: presetsWrapper.userDefinedPresets,
                                 action: #selector(presetsAction(_:)), target: self)
        
        presetsAndSettingsMenu.items.forEach {$0.state = .off}
        
//        if let currentPresetName = effectsUnit.nameOfCurrentPreset,
//           let itemForCurrentPreset = presetsAndSettingsMenu.item(withTitle: currentPresetName) {
//            
//            itemForCurrentPreset.state = .on
//        }
    }
}
