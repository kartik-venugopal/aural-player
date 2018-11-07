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
    
    func initialize(_ stateFunction: (() -> EffectsUnitState)?) {
        
        sliders.forEach({
            $0.stateFunction = stateFunction
            $0.updateState()
        })
    }
    
    func setState(_ pitchInfo: (pitch: Float, pitchString: String), _ overlapInfo: (overlap: Float, overlapString: String)) {
        
        setPitch(pitchInfo)
        setPitchOverlap(overlapInfo)
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        sliders.forEach({$0.setUnitState(state)})
    }
    
    func setPitch(_ pitchInfo: (pitch: Float, pitchString: String)) {
        
        pitchSlider.floatValue = pitchInfo.pitch
        lblPitchValue.stringValue = pitchInfo.pitchString
    }
    
    func setPitchOverlap(_ overlapInfo: (overlap: Float, overlapString: String)) {
        
        pitchOverlapSlider.floatValue = overlapInfo.overlap
        lblPitchOverlapValue.stringValue = overlapInfo.overlapString
    }
    
    func stateChanged() {
        sliders.forEach({$0.updateState()})
    }
    
    func applyPreset(_ preset: PitchPreset) {
        
        let pitch = preset.pitch * AppConstants.pitchConversion_audioGraphToUI
        setPitch((pitch, ValueFormatter.formatPitch(pitch)))
        setPitchOverlap((preset.overlap, ValueFormatter.formatOverlap(preset.overlap)))
        setUnitState(preset.state)
    }
}
