import Cocoa

class EQView: NSView {
    
    @IBOutlet weak var container: NSBox!
    
    @IBOutlet weak var eq10BandView: EQSubview!
    @IBOutlet weak var eq15BandView: EQSubview!
    
    @IBOutlet weak var btn10Band: NSButton!
    @IBOutlet weak var btn15Band: NSButton!
    @IBOutlet weak var btnSync: NSButton!
    
    var type: EQType {
        return btn10Band.isOn() ? .tenBand : .fifteenBand
    }
    
    private var activeView: EQSubview {
        return btn10Band.isOn() ? eq10BandView : eq15BandView
    }
    
    private var inactiveView: EQSubview {
        return btn10Band.isOn() ? eq15BandView : eq10BandView
    }
    
    var globalGain: Float {
        return activeView.globalGainSlider.floatValue
    }
    
    override func awakeFromNib() {
        
        container.addSubviews(eq10BandView, eq15BandView)
        
        eq10BandView.positionAtZeroPoint()
        eq15BandView.positionAtZeroPoint()
    }
    
    func initialize(_ sliderAction: Selector?, _ sliderActionTarget: AnyObject?, _ eqStateFunction: @escaping () -> EffectsUnitState) {
        
        eq10BandView.initialize(eqStateFunction, sliderAction, sliderActionTarget)
        eq15BandView.initialize(eqStateFunction, sliderAction, sliderActionTarget)
    }
    
    func setState(_ eqType: EQType, _ bands: [Int: Float], _ globalGain: Float, _ sync: Bool) {

        chooseType(eqType)
        bandsUpdated(bands, globalGain)
        btnSync.onIf(sync)
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        activeView.setState(state)
    }
    
    func typeChanged(_ bands: [Int: Float], _ globalGain: Float) {
        
        activeView.stateChanged()
        activeView.updateBands(bands, globalGain)
        activeView.show()
        inactiveView.hide()
    }
    
    func bandsUpdated(_ bands: [Int: Float], _ globalGain: Float) {
        activeView.updateBands(bands, globalGain)
    }
    
    func stateChanged() {
        activeView.stateChanged()
    }
    
    func chooseType(_ eqType: EQType) {
        
        eqType == .tenBand ? btn10Band.on() : btn15Band.on()
        
        activeView.stateChanged()
        activeView.show()
        inactiveView.hide()
    }
}
