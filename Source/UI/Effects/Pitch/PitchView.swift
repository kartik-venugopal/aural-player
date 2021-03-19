import Cocoa

class PitchView: NSView {

    @IBOutlet weak var pitchSlider: EffectsUnitSlider!
    @IBOutlet weak var pitchOverlapSlider: EffectsUnitSlider!
    @IBOutlet weak var lblPitchValue: NSTextField!
    @IBOutlet weak var lblPitchOverlapValue: NSTextField!
    
    private var sliders: [EffectsUnitSlider] = []
    
    var pitch: Float {
        return pitchSlider.floatValue
    }
    
    var overlap: Float {
        return pitchOverlapSlider.floatValue
    }
    
    override func awakeFromNib() {
        sliders = [pitchSlider, pitchOverlapSlider]
    }
    
    func initialize(_ stateFunction: @escaping () -> EffectsUnitState) {
        
        sliders.forEach({
            $0.stateFunction = stateFunction
            $0.updateState()
        })
    }
    
    func setState(_ pitch: Float, _ pitchString: String, _ overlap: Float, _ overlapString: String) {
        
        setPitch(pitch, pitchString)
        setPitchOverlap(overlap, overlapString)
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        sliders.forEach({$0.setUnitState(state)})
    }
    
    func setPitch(_ pitch: Float, _ pitchString: String) {
        
        pitchSlider.floatValue = pitch
        lblPitchValue.stringValue = pitchString
    }
    
    func setPitchOverlap(_ overlap: Float, _ overlapString: String) {
        
        pitchOverlapSlider.floatValue = overlap
        lblPitchOverlapValue.stringValue = overlapString
    }
    
    func stateChanged() {
        sliders.forEach({$0.updateState()})
    }
    
    func applyPreset(_ preset: PitchPreset) {
        
        let pitch = preset.pitch * AppConstants.ValueConversions.pitch_audioGraphToUI
        setPitch(pitch, ValueFormatter.formatPitch(pitch))
        setPitchOverlap(preset.overlap, ValueFormatter.formatOverlap(preset.overlap))
        setUnitState(preset.state)
    }
    
<<<<<<< HEAD:Aural/PitchView.swift
    func changeColorScheme() {
        sliders.forEach({$0.redraw()})
=======
    func redrawSliders() {
        [pitchSlider, pitchOverlapSlider].forEach({$0?.redraw()})
>>>>>>> upstream/master:Source/UI/Effects/Pitch/PitchView.swift
    }
}
