//
//  MasterUnitView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MasterUnitView: NSView {
    
    @IBOutlet weak var btnEQBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnPitchBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnTimeBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnReverbBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnDelayBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnFilterBypass: EffectsUnitTriStateBypassButton!
    
    @IBOutlet weak var imgEQBypass: EffectsUnitTriStateBypassImage!
    @IBOutlet weak var imgPitchBypass: EffectsUnitTriStateBypassImage!
    @IBOutlet weak var imgTimeBypass: EffectsUnitTriStateBypassImage!
    @IBOutlet weak var imgReverbBypass: EffectsUnitTriStateBypassImage!
    @IBOutlet weak var imgDelayBypass: EffectsUnitTriStateBypassImage!
    @IBOutlet weak var imgFilterBypass: EffectsUnitTriStateBypassImage!
    @IBOutlet weak var imgAUBypass: EffectsUnitTriStateBypassImage!
    
    @IBOutlet weak var lblEQ: EffectsUnitTriStateLabel!
    @IBOutlet weak var lblPitch: EffectsUnitTriStateLabel!
    @IBOutlet weak var lblTime: EffectsUnitTriStateLabel!
    @IBOutlet weak var lblReverb: EffectsUnitTriStateLabel!
    @IBOutlet weak var lblDelay: EffectsUnitTriStateLabel!
    @IBOutlet weak var lblFilter: EffectsUnitTriStateLabel!
    
    @IBOutlet weak var lblAudioUnits: EffectsUnitTriStateLabel!
    
    var buttons: [EffectsUnitTriStateBypassButton] = []
    var images: [EffectsUnitTriStateBypassImage] = []
    var labels: [EffectsUnitTriStateLabel] = []
    
    override func awakeFromNib() {
        
        let graph: AudioGraphDelegateProtocol = objectGraph.audioGraphDelegate
        
        buttons = [btnEQBypass, btnPitchBypass, btnTimeBypass, btnReverbBypass, btnDelayBypass, btnFilterBypass]
        images = [imgEQBypass, imgPitchBypass, imgTimeBypass, imgReverbBypass, imgDelayBypass, imgFilterBypass, imgAUBypass]
        labels = [lblEQ, lblPitch, lblTime, lblReverb, lblDelay, lblFilter, lblAudioUnits]
        
        btnEQBypass.stateFunction = graph.eqUnit.stateFunction
        btnPitchBypass.stateFunction = graph.pitchShiftUnit.stateFunction
        btnTimeBypass.stateFunction = graph.timeStretchUnit.stateFunction
        btnReverbBypass.stateFunction = graph.reverbUnit.stateFunction
        btnDelayBypass.stateFunction = graph.delayUnit.stateFunction
        btnFilterBypass.stateFunction = graph.filterUnit.stateFunction
        
        imgEQBypass.stateFunction = graph.eqUnit.stateFunction
        imgPitchBypass.stateFunction = graph.pitchShiftUnit.stateFunction
        imgTimeBypass.stateFunction = graph.timeStretchUnit.stateFunction
        imgReverbBypass.stateFunction = graph.reverbUnit.stateFunction
        imgDelayBypass.stateFunction = graph.delayUnit.stateFunction
        imgFilterBypass.stateFunction = graph.filterUnit.stateFunction
        imgAUBypass.stateFunction = graph.audioUnitsStateFunction
        
        lblEQ.stateFunction = graph.eqUnit.stateFunction
        lblPitch.stateFunction = graph.pitchShiftUnit.stateFunction
        lblTime.stateFunction = graph.timeStretchUnit.stateFunction
        lblReverb.stateFunction = graph.reverbUnit.stateFunction
        lblDelay.stateFunction = graph.delayUnit.stateFunction
        lblFilter.stateFunction = graph.filterUnit.stateFunction
        lblAudioUnits.stateFunction = graph.audioUnitsStateFunction
        
        buttons.forEach {$0.updateState()}
        images.forEach {$0.updateState()}
        labels.forEach {$0.updateState()}
    }
    
    func stateChanged() {
        
        buttons.forEach {$0.updateState()}
        images.forEach {$0.updateState()}
        labels.forEach {$0.updateState()}
    }
    
    private func changeUnitStateColor(forState unitState: EffectsUnitState) {
        
        buttons.filter {$0.unitState == unitState}.forEach {
            $0.reTint()
        }
        
        images.filter {$0.unitState == unitState}.forEach {
            $0.reTint()
        }
        
        labels.filter {$0.unitState == unitState}.forEach {
            $0.reTint()
        }
    }
    
    func changeActiveUnitStateColor(_ color: NSColor) {
        changeUnitStateColor(forState: .active)
    }
    
    func changeBypassedUnitStateColor(_ color: NSColor) {
        changeUnitStateColor(forState: .bypassed)
    }
    
    func changeSuppressedUnitStateColor(_ color: NSColor) {
        changeUnitStateColor(forState: .suppressed)
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
