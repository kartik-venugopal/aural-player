import Cocoa

class EQView: NSView {
    
    @IBOutlet weak var container: NSBox!
    
    @IBOutlet weak var eq10BandView: EQSubview!
    @IBOutlet weak var eq15BandView: EQSubview!
    
    @IBOutlet weak var btn10Band: NSButton!
    @IBOutlet weak var btn15Band: NSButton!
    
    var type: EQType {
        return btn10Band.isOn ? .tenBand : .fifteenBand
    }
    
    private var activeView: EQSubview {
        return btn10Band.isOn ? eq10BandView : eq15BandView
    }
    
    private var inactiveView: EQSubview {
        return btn10Band.isOn ? eq15BandView : eq10BandView
    }
    
    var globalGain: Float {
        return activeView.globalGainSlider.floatValue
    }
    
    override func awakeFromNib() {
        
        container.addSubviews(eq10BandView, eq15BandView)
        
        eq10BandView.positionAtZeroPoint()
        eq15BandView.positionAtZeroPoint()
    }
    
    func initialize(_ sliderAction: Selector?, _ sliderActionTarget: AnyObject?, _ eqStateFunction: @escaping EffectsUnitStateFunction) {
        
        eq10BandView.initialize(eqStateFunction, sliderAction, sliderActionTarget)
        eq15BandView.initialize(eqStateFunction, sliderAction, sliderActionTarget)
    }
    
    func setState(_ eqType: EQType, _ bands: [Float], _ globalGain: Float) {

        chooseType(eqType)
        bandsUpdated(bands, globalGain)
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        activeView.setState(state)
    }
    
    func typeChanged(_ bands: [Float], _ globalGain: Float) {
        
        activeView.stateChanged()
        activeView.updateBands(bands, globalGain)
        activeView.show()
        inactiveView.hide()
    }
    
    func bandsUpdated(_ bands: [Float], _ globalGain: Float) {
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
    
    func applyPreset(_ preset: EQPreset) {
    
        setUnitState(preset.state)
        bandsUpdated(preset.bands, preset.globalGain)
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
        btn10Band.redraw()
        btn15Band.redraw()
    }
    
    func changeActiveUnitStateColor(_ color: NSColor) {
        
        eq10BandView.changeActiveUnitStateColor(color)
        eq15BandView.changeActiveUnitStateColor(color)
    }
    
    func changeBypassedUnitStateColor(_ color: NSColor) {
        
        eq10BandView.changeBypassedUnitStateColor(color)
        eq15BandView.changeBypassedUnitStateColor(color)
    }
    
    func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        eq10BandView.changeSuppressedUnitStateColor(color)
        eq15BandView.changeSuppressedUnitStateColor(color)
    }
    
    func changeSelectedTabButtonColor() {
        btn10Band.isOn ? btn10Band.redraw() : btn15Band.redraw()
    }
    
    func changeTabButtonTextColor() {
        btn10Band.isOff ? btn10Band.redraw() : btn15Band.redraw()
    }
    
    func changeSelectedTabButtonTextColor() {
        btn10Band.isOn ? btn10Band.redraw() : btn15Band.redraw()
    }
    
    func changeSliderColor() {
        
        eq10BandView.changeSliderColor()
        eq15BandView.changeSliderColor()
    }
}
