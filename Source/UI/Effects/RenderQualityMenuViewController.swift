//
//  RenderQualityMenuViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

@available(macOS 10.13, *)
class RenderQualityMenuViewController: NSViewController {
    
    override var nibName: String? {"RenderQualityMenu"}
    
    @IBOutlet weak var renderQualitySlider: EffectsUnitSlider!
    @IBOutlet weak var lblRenderQuality: NSTextField!
    
    var effectsUnit: EffectsUnitDelegateProtocol!
    
    @IBAction func renderQualityAction(_ sender: AnyObject) {
        
        effectsUnit.renderQuality = renderQualitySlider.integerValue
        lblRenderQuality.stringValue = "\(effectsUnit.renderQuality)"
    }
}

@available(macOS 10.13, *)
extension RenderQualityMenuViewController: NSMenuDelegate {
    
    func menuWillOpen(_ menu: NSMenu) {
        
        renderQualitySlider.integerValue = effectsUnit.renderQuality
        lblRenderQuality.stringValue = "\(effectsUnit.renderQuality)"
    }
}
