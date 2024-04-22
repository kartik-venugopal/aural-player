//
//  EQUnitViewController.swift
//  Aural-iOS
//
//  Created by Kartik Venugopal on 9/23/22.
//

import UIKit

class EQUnitViewController: UIViewController {
    
    @IBOutlet weak var globalGainSlider: UISlider!
    
    /// The sliders corresponding to all the bands of the equalizer.
    private var bandSliders: [UISlider] = []
    
    @IBOutlet weak var btnBypass: UIButton!
    @IBOutlet weak var btnPresets: UIButton!
    
    private var eqUnit: EQUnitDelegateProtocol = audioGraphDelegate.eqUnit
    
    private var rotated: Bool = false
    
    ///
    /// Sets the state of the controls based on the current state of the FX unit.
    ///
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        navigationItem.title = "Equalizer Settings"
        
        if !rotated {
            
            // Discover the EQ band sliders among this view's subviews.
            // The band sliders have a tag value that is >= 0.
            // Perform filtering to exclude the global gain slider.
            let allSliders = view.subviews.compactMap {$0 as? UISlider}
            bandSliders = allSliders.filter {$0.tag >= 0}.sorted(by: {$0.tag < $1.tag})
            
            // Rotate the sliders by 90 degrees counter-clockwise (to make them vertical).
            allSliders.forEach {
                $0.transform = $0.transform.rotated(by: CGFloat(3 * Float.pi / 2))
            }
            
            rotated = true
        }
        
        updateControls()
        createPresetsMenu()
    }
    
    private func updateControls() {
        
        btnBypass.tintColor = eqUnit.isActive ? .blue : .gray
        
        globalGainSlider.value = eqUnit.globalGain
        
        bandSliders.forEach {
            $0.value = eqUnit[$0.tag]
        }
    }
    
    private func createPresetsMenu() {
        
        let presets = eqUnit.presets
        
        func actionForPreset(_ preset: EQPreset) -> UIAction {
            
            UIAction(title: preset.name, image: nil) {[weak self] _ in
                
                self?.eqUnit.applyPreset(named: preset.name)
                self?.updateControls()
            }
        }
        
        let systemDefinedPresetItems = presets.systemDefinedObjects.map(actionForPreset(_:))
        let systemDefinedPresetsMenu = UIMenu(title: "System-defined presets", image: nil, identifier: nil, options: [], children: systemDefinedPresetItems)
        
        var allMenus: [UIMenuElement] = [systemDefinedPresetsMenu]
        
        if presets.numberOfUserDefinedObjects > 0 {
            
            let userDefinedPresetItems = presets.userDefinedObjects.map(actionForPreset(_:))
            let userDefinedPresetsMenu = UIMenu(title: "User-defined presets", image: nil, identifier: nil, options: [], children: userDefinedPresetItems)
            allMenus.append(userDefinedPresetsMenu)
        }
        
        // TODO: Create an action for "Save preset".
        let savePresetAction = UIAction(title: "Save preset", image: .imgSave) {[weak self] _ in
            self?.promptForNewPresetName()
        }
        
        allMenus.append(savePresetAction)
        
        let menu = UIMenu(title: "Presets", image: nil, identifier: nil, options: .displayInline,
                          children: allMenus)
        btnPresets.menu = menu
        btnPresets.showsMenuAsPrimaryAction = true
    }
    
    private func promptForNewPresetName() {
        
        presentPrompt(withTitle: "Save EQ Preset", message: "Name the new preset",
                      placeholderText: "New EQ Preset") {[weak self] newPresetName in
            
            self?.eqUnit.savePreset(named: newPresetName)
            self?.createPresetsMenu()
        }
    }
    
    @IBAction func eqBypassAction(_ sender: UIButton) {
        
        _ = eqUnit.toggleState()
        btnBypass.tintColor = eqUnit.isActive ? .blue : .gray
    }
    
    @IBAction func eqGlobalGainAction(_ sender: UISlider) {
        eqUnit.globalGain = sender.value
    }
    
    @IBAction func eqBandAction(_ sender: UISlider) {
        eqUnit[sender.tag] = sender.value
    }
}
