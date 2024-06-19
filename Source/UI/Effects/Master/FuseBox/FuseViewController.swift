//
//  FuseViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FuseViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"Fuse"}
    
    @IBOutlet weak var imgBypass: EffectsUnitTriStateBypassImage!
    @IBOutlet weak var icon: EffectsUnitTriStateBypassImage!
    @IBOutlet weak var lblUnitCaption: EffectsUnitTriStateLabel!
    @IBOutlet weak var backgroundBox: NSBox!
    
    var effectsUnit: EffectsUnitDelegateProtocol!
    
    private lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        guard let fxUnit = effectsUnit else {return}
        
        let unitType = fxUnit.unitType
        
        if let auUnit = effectsUnit as? HostedAudioUnitDelegateProtocol {
            lblUnitCaption.stringValue = "\(auUnit.name) v\(auUnit.version)"
        } else {
            lblUnitCaption.stringValue = unitType.caption
        }
        
        icon.image = fxUnit.unitType.icon
        
        ([imgBypass, icon, lblUnitCaption] as! [FXUnitStateObserver]).forEach {
            fxUnitStateObserverRegistry.registerObserver($0, forFXUnit: fxUnit)
        }
        
        imgBypass.addGestureRecognizer(NSClickGestureRecognizer(target: self,
                                                                       action: #selector(self.bypassAction)))
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.activeControlColor, handler: activeControlColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.inactiveControlColor, handler: inactiveControlColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.suppressedControlColor, handler: suppressedControlColorChanged(_:))
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        backgroundBox.fillColor = systemColorScheme.backgroundColor
    }
    
    @IBAction func bypassAction(_ sender: EffectsUnitTriStateBypassImage) {
        
        effectsUnit.toggleState()
        
        // Update the bypass buttons for all effects units
        messenger.publish(.Effects.unitStateChanged)
    }
}

extension FuseViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        lblUnitCaption.font = systemFontScheme.normalFont
    }
}

extension FuseViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        lblUnitCaption.unitStateChanged(to: effectsUnit.state)
        icon.unitStateChanged(to: effectsUnit.state)
        imgBypass.unitStateChanged(to: effectsUnit.state)
    }
    
    func activeControlColorChanged(_ newColor: NSColor) {
        controlStateColorChanged(forState: .active)
    }
    
    func inactiveControlColorChanged(_ newColor: NSColor) {
        controlStateColorChanged(forState: .bypassed)
    }
    
    func suppressedControlColorChanged(_ newColor: NSColor) {
        controlStateColorChanged(forState: .suppressed)
    }
    
    private func controlStateColorChanged(forState state: EffectsUnitState) {
        
        guard effectsUnit.state == state else {return}
        
        icon.unitStateChanged(to: state)
        imgBypass.unitStateChanged(to: state)
    }
}
