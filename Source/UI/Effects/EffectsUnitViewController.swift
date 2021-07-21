//
//  EffectsUnitViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class EffectsUnitViewController: NSViewController, NSMenuDelegate, StringInputReceiver, Destroyable {
    
    @IBOutlet weak var btnBypass: EffectsUnitTriStateBypassButton!
    
    @IBOutlet weak var lblCaption: VALabel!
    
    // Labels
    var functionLabels: [NSTextField] = []
    
    var functionCaptionLabels: [NSTextField] = []
    var functionValueLabels: [NSTextField] = []

    // Presets controls
    @IBOutlet weak var presetsMenu: NSPopUpButton!
    @IBOutlet weak var presetsMenuIconItem: TintedIconMenuItem!
    @IBOutlet weak var btnSavePreset: TintedImageButton!
    lazy var userPresetsPopover: StringInputPopoverViewController = .create(self)
    
    let graph: AudioGraphDelegateProtocol = objectGraph.audioGraphDelegate
    
    let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    var effectsUnit: EffectsUnitDelegateProtocol!
    var unitStateFunction: EffectsUnitStateFunction!
    var presetsWrapper: PresetsWrapperProtocol!
    
    var unitType: EffectsUnitType!
    
    lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        self.unitStateFunction = effectsUnit.stateFunction
        
        oneTimeSetup()
        initControls()
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    func oneTimeSetup() {
        
        btnBypass.stateFunction = self.unitStateFunction
        btnSavePreset.tintFunction = {Colors.functionButtonColor}
        presetsMenuIconItem.tintFunction = {Colors.functionButtonColor}
        
        initSubscriptions()
        
        functionLabels = findFunctionLabels(self.view)
    }
    
    func findFunctionLabels(_ view: NSView) -> [NSTextField] {
        
        var labels: [NSTextField] = []
        
        for subview in view.subviews {
            
            if let label = subview as? NSTextField, label != lblCaption {
                
                labels.append(label)
                label is FunctionValueLabel ? functionValueLabels.append(label) : functionCaptionLabels.append(label)
            }
            
            // Recursive call
            let subviewLabels = findFunctionLabels(subview)
            labels.append(contentsOf: subviewLabels)
        }
        
        return labels
    }
    
    func initSubscriptions() {
        
        // Subscribe to notifications
        messenger.subscribe(to: .effects_unitStateChanged, handler: stateChanged)
        
        messenger.subscribe(to: .effects_updateEffectsUnitView, handler: {[weak self] (EffectsUnit) in self?.initControls()},
                            filter: {[weak self] (unitType: EffectsUnitType) in unitType == .master || (unitType == self?.unitType)})
        
        messenger.subscribe(to: .effects_changeSliderColors, handler: changeSliderColors)
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyFontScheme, handler: applyFontScheme(_:))
        messenger.subscribe(to: .applyColorScheme, handler: applyColorScheme(_:))
        messenger.subscribe(to: .changeFunctionButtonColor, handler: changeFunctionButtonColor(_:))
        messenger.subscribe(to: .changeMainCaptionTextColor, handler: changeMainCaptionTextColor(_:))
        
        messenger.subscribe(to: .effects_changeFunctionCaptionTextColor, handler: changeFunctionCaptionTextColor(_:))
        messenger.subscribe(to: .effects_changeFunctionValueTextColor, handler: changeFunctionValueTextColor(_:))
        
        messenger.subscribe(to: .effects_changeActiveUnitStateColor, handler: changeActiveUnitStateColor(_:))
        messenger.subscribe(to: .effects_changeBypassedUnitStateColor, handler: changeBypassedUnitStateColor(_:))
        messenger.subscribe(to: .effects_changeSuppressedUnitStateColor, handler: changeSuppressedUnitStateColor(_:))
    }
    
    func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    func initControls() {
        
        stateChanged()
        presetsMenu.selectItem(at: -1)
    }
    
    func stateChanged() {
        btnBypass.updateState()
    }
    
    func showThisTab() {
        messenger.publish(.effects_showEffectsUnitTab, payload: self.unitType!)
    }
    
    @IBAction func bypassAction(_ sender: AnyObject) {

        _ = effectsUnit.toggleState()
        stateChanged()
        
        messenger.publish(.effects_unitStateChanged)
    }
    
    // Applies a preset to the effects unit
    @IBAction func presetsAction(_ sender: AnyObject) {
        
        if let selectedPresetItem = presetsMenu.titleOfSelectedItem {
            
            effectsUnit.applyPreset(named: selectedPresetItem)
            initControls()
        }
    }
    
    // Displays a popover to allow the user to name the new custom preset
    @IBAction func savePresetAction(_ sender: AnyObject) {
        userPresetsPopover.show(btnSavePreset, NSRectEdge.minY)
    }
    
    private func applyTheme() {
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
        lblCaption.font = fontSchemesManager.systemScheme.effects.unitCaptionFont
        functionLabels.forEach({$0.font = fontSchemesManager.systemScheme.effects.unitFunctionFont})
        presetsMenu.font = .menuFont
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        changeMainCaptionTextColor(scheme.general.mainCaptionTextColor)
        
        changeFunctionButtonColor(scheme.general.functionButtonColor)
        changeFunctionCaptionTextColor(scheme.effects.functionCaptionTextColor)
        changeFunctionValueTextColor(scheme.effects.functionValueTextColor)
        
        changeActiveUnitStateColor(scheme.effects.activeUnitStateColor)
        changeBypassedUnitStateColor(scheme.effects.bypassedUnitStateColor)
        changeSuppressedUnitStateColor(scheme.effects.suppressedUnitStateColor)
    }
    
    func changeMainCaptionTextColor(_ color: NSColor) {
        lblCaption.textColor = color
    }
    
    func changeFunctionCaptionTextColor(_ color: NSColor) {
        functionCaptionLabels.forEach({$0.textColor = color})
    }
    
    func changeFunctionValueTextColor(_ color: NSColor) {
        functionValueLabels.forEach({$0.textColor = color})
    }
    
    func changeActiveUnitStateColor(_ color: NSColor) {
        
        if effectsUnit.state == .active {
            btnBypass.reTint()
        }
    }
    
    func changeBypassedUnitStateColor(_ color: NSColor) {
        
        if effectsUnit.state == .bypassed {
            btnBypass.reTint()
        }
    }
    
    func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        if effectsUnit.state == .suppressed {
            btnBypass.reTint()
        }
    }
    
    func changeFunctionButtonColor(_ color: NSColor) {
        
        btnSavePreset.reTint()
        presetsMenuIconItem.reTint()
    }
    
    func changeSliderColors() {
        // Do nothing. Meant to be overriden.
    }
    
    // MARK - StringInputReceiver functions
    
    var inputPrompt: String {
        return "Enter a new preset name:"
    }
    
    var defaultValue: String? {
        return "<New preset>"
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
    
    // MARK: Menu delegate
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all custom presets (all items before the first separator)
        while presetsMenu.itemArray.count > 1 && !presetsMenu.item(at: 1)!.isSeparatorItem {
            presetsMenu.removeItem(at: 1)
        }
        
        
        // Re-initialize the menu with user-defined presets
        presetsWrapper.userDefinedPresets.forEach({presetsMenu.insertItem(withTitle: $0.name, at: 1)})
        
        // Don't select any items from the EQ presets menu
        presetsMenu.selectItem(at: -1)
    }
}

// Marker class to differentiate between caption labels and their corresponding value labels
class FunctionValueLabel: CenterTextLabel {}
