import Cocoa

class MasterView: NSView {
    
    @IBOutlet weak var btnEQBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnPitchBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnTimeBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnReverbBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnDelayBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnFilterBypass: EffectsUnitTriStateBypassButton!
    
    private var buttons: [EffectsUnitTriStateBypassButton] = []
    
    @IBOutlet weak var imgEQ: ColorSensitiveImage! {
        
        didSet {
            imgEQ.imageMappings[.darkBackground_lightText] = NSImage(named: "EQUnit")
            imgEQ.imageMappings[.lightBackground_darkText] = NSImage(named: "EQUnit_1")
        }
    }
    
    @IBOutlet weak var imgPitch: ColorSensitiveImage! {
        
        didSet {
            imgPitch.imageMappings[.darkBackground_lightText] = NSImage(named: "PitchUnit")
            imgPitch.imageMappings[.lightBackground_darkText] = NSImage(named: "PitchUnit_1")
        }
    }
    
    @IBOutlet weak var imgTime: ColorSensitiveImage! {
        
        didSet {
            imgTime.imageMappings[.darkBackground_lightText] = NSImage(named: "TimeUnit")
            imgTime.imageMappings[.lightBackground_darkText] = NSImage(named: "TimeUnit_1")
        }
    }
    
    @IBOutlet weak var imgReverb: ColorSensitiveImage! {
        
        didSet {
            imgReverb.imageMappings[.darkBackground_lightText] = NSImage(named: "ReverbUnit")
            imgReverb.imageMappings[.lightBackground_darkText] = NSImage(named: "ReverbUnit_1")
        }
    }
    
    @IBOutlet weak var imgDelay: ColorSensitiveImage! {
        
        didSet {
            imgDelay.imageMappings[.darkBackground_lightText] = NSImage(named: "DelayUnit")
            imgDelay.imageMappings[.lightBackground_darkText] = NSImage(named: "DelayUnit_1")
        }
    }
    
    @IBOutlet weak var imgFilter: ColorSensitiveImage! {
        
        didSet {
            imgFilter.imageMappings[.darkBackground_lightText] = NSImage(named: "FilterUnit")
            imgFilter.imageMappings[.lightBackground_darkText] = NSImage(named: "FilterUnit_1")
        }
    }
    
    private var images: [ColorSensitiveImage] = []
    
    override func awakeFromNib() {
        
        buttons = [btnEQBypass, btnPitchBypass, btnTimeBypass, btnReverbBypass, btnDelayBypass, btnFilterBypass]
        
        images = [imgEQ, imgPitch, imgTime, imgReverb, imgDelay, imgFilter]
    }
    
    func initialize(_ eqStateFunction: @escaping EffectsUnitStateFunction, _ pitchStateFunction: @escaping EffectsUnitStateFunction, _ timeStateFunction: @escaping EffectsUnitStateFunction, _ reverbStateFunction: @escaping EffectsUnitStateFunction, _ delayStateFunction: @escaping EffectsUnitStateFunction, _ filterStateFunction: @escaping EffectsUnitStateFunction) {
        
        btnEQBypass.stateFunction = eqStateFunction
        btnPitchBypass.stateFunction = pitchStateFunction
        btnTimeBypass.stateFunction = timeStateFunction
        btnReverbBypass.stateFunction = reverbStateFunction
        btnDelayBypass.stateFunction = delayStateFunction
        btnFilterBypass.stateFunction = filterStateFunction
        
        buttons.forEach({$0.updateState()})
    }
    
    func stateChanged() {
        buttons.forEach({$0.updateState()})
    }
    
    func applyPreset(_ preset: MasterPreset) {
        
        btnEQBypass.onIf(preset.eq.state == .active)
        btnPitchBypass.onIf(preset.pitch.state == .active)
        btnTimeBypass.onIf(preset.time.state == .active)
        btnReverbBypass.onIf(preset.reverb.state == .active)
        btnDelayBypass.onIf(preset.delay.state == .active)
        btnFilterBypass.onIf(preset.filter.state == .active)
    }
    
    func changeColorScheme() {
        buttons.forEach({$0.colorSchemeChanged()})
        images.forEach({$0.colorSchemeChanged()})
    }
}
