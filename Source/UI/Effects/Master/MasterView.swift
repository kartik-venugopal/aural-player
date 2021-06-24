//
//  MasterView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MasterView: NSView {
    
    @IBOutlet weak var btnEQBypass: FXUnitTriStateBypassButton!
    @IBOutlet weak var btnPitchBypass: FXUnitTriStateBypassButton!
    @IBOutlet weak var btnTimeBypass: FXUnitTriStateBypassButton!
    @IBOutlet weak var btnReverbBypass: FXUnitTriStateBypassButton!
    @IBOutlet weak var btnDelayBypass: FXUnitTriStateBypassButton!
    @IBOutlet weak var btnFilterBypass: FXUnitTriStateBypassButton!
    
    @IBOutlet weak var imgEQBypass: FXUnitTriStateBypassImage!
    @IBOutlet weak var imgPitchBypass: FXUnitTriStateBypassImage!
    @IBOutlet weak var imgTimeBypass: FXUnitTriStateBypassImage!
    @IBOutlet weak var imgReverbBypass: FXUnitTriStateBypassImage!
    @IBOutlet weak var imgDelayBypass: FXUnitTriStateBypassImage!
    @IBOutlet weak var imgFilterBypass: FXUnitTriStateBypassImage!
    @IBOutlet weak var imgAUBypass: FXUnitTriStateBypassImage!
    
    @IBOutlet weak var lblEQ: FXUnitTriStateLabel!
    @IBOutlet weak var lblPitch: FXUnitTriStateLabel!
    @IBOutlet weak var lblTime: FXUnitTriStateLabel!
    @IBOutlet weak var lblReverb: FXUnitTriStateLabel!
    @IBOutlet weak var lblDelay: FXUnitTriStateLabel!
    @IBOutlet weak var lblFilter: FXUnitTriStateLabel!
    
    @IBOutlet weak var lblAudioUnits: FXUnitTriStateLabel!
    
    var buttons: [FXUnitTriStateBypassButton] = []
    var images: [FXUnitTriStateBypassImage] = []
    var labels: [FXUnitTriStateLabel] = []
    
    override func awakeFromNib() {
        buttons = [btnEQBypass, btnPitchBypass, btnTimeBypass, btnReverbBypass, btnDelayBypass, btnFilterBypass]
        images = [imgEQBypass, imgPitchBypass, imgTimeBypass, imgReverbBypass, imgDelayBypass, imgFilterBypass, imgAUBypass]
        labels = [lblEQ, lblPitch, lblTime, lblReverb, lblDelay, lblFilter, lblAudioUnits]
    }
    
    func initialize(_ eqStateFunction: @escaping FXUnitStateFunction, _ pitchStateFunction: @escaping FXUnitStateFunction, _ timeStateFunction: @escaping FXUnitStateFunction, _ reverbStateFunction: @escaping FXUnitStateFunction, _ delayStateFunction: @escaping FXUnitStateFunction, _ filterStateFunction: @escaping FXUnitStateFunction, _ auStateFunction: @escaping FXUnitStateFunction) {
        
        btnEQBypass.stateFunction = eqStateFunction
        btnPitchBypass.stateFunction = pitchStateFunction
        btnTimeBypass.stateFunction = timeStateFunction
        btnReverbBypass.stateFunction = reverbStateFunction
        btnDelayBypass.stateFunction = delayStateFunction
        btnFilterBypass.stateFunction = filterStateFunction
        
        imgEQBypass.stateFunction = eqStateFunction
        imgPitchBypass.stateFunction = pitchStateFunction
        imgTimeBypass.stateFunction = timeStateFunction
        imgReverbBypass.stateFunction = reverbStateFunction
        imgDelayBypass.stateFunction = delayStateFunction
        imgFilterBypass.stateFunction = filterStateFunction
        imgAUBypass.stateFunction = auStateFunction
        
        lblEQ.stateFunction = eqStateFunction
        lblPitch.stateFunction = pitchStateFunction
        lblTime.stateFunction = timeStateFunction
        lblReverb.stateFunction = reverbStateFunction
        lblDelay.stateFunction = delayStateFunction
        lblFilter.stateFunction = filterStateFunction
        lblAudioUnits.stateFunction = auStateFunction
        
        buttons.forEach({$0.updateState()})
        images.forEach({$0.updateState()})
        labels.forEach({$0.updateState()})
    }
    
    func stateChanged() {
        
        buttons.forEach({$0.updateState()})
        images.forEach({$0.updateState()})
        labels.forEach({$0.updateState()})
    }
    
    private func changeUnitStateColorForState(_ unitState: FXUnitState) {
        
        buttons.forEach({
            
            if $0.unitState == unitState {
                $0.reTint()
            }
        })
        
        images.forEach({
            
            if $0.unitState == unitState {
                $0.reTint()
            }
        })
        
        labels.forEach({
            
            if $0.unitState == unitState {
                $0.reTint()
            }
        })
    }
    
    func changeActiveUnitStateColor(_ color: NSColor) {
        changeUnitStateColorForState(.active)
    }
    
    func changeBypassedUnitStateColor(_ color: NSColor) {
        changeUnitStateColorForState(.bypassed)
    }
    
    func changeSuppressedUnitStateColor(_ color: NSColor) {
        changeUnitStateColorForState(.suppressed)
    }
    
    func applyPreset(_ preset: MasterPreset) {
        
        btnEQBypass.onIf(preset.eq.state == .active)
        btnPitchBypass.onIf(preset.pitch.state == .active)
        btnTimeBypass.onIf(preset.time.state == .active)
        btnReverbBypass.onIf(preset.reverb.state == .active)
        btnDelayBypass.onIf(preset.delay.state == .active)
        btnFilterBypass.onIf(preset.filter.state == .active)
        
        imgEQBypass.onIf(preset.eq.state == .active)
        imgPitchBypass.onIf(preset.pitch.state == .active)
        imgTimeBypass.onIf(preset.time.state == .active)
        imgReverbBypass.onIf(preset.reverb.state == .active)
        imgDelayBypass.onIf(preset.delay.state == .active)
        imgFilterBypass.onIf(preset.filter.state == .active)
        
        lblEQ.onIf(preset.eq.state == .active)
        lblPitch.onIf(preset.pitch.state == .active)
        lblTime.onIf(preset.time.state == .active)
        lblReverb.onIf(preset.reverb.state == .active)
        lblDelay.onIf(preset.delay.state == .active)
        lblFilter.onIf(preset.filter.state == .active)
    }
}
