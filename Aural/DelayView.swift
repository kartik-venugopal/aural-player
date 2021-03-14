import Cocoa

class DelayView: NSView {
    
    @IBOutlet weak var timeSlider: EffectsUnitSlider!
    @IBOutlet weak var amountSlider: EffectsUnitSlider!
    @IBOutlet weak var cutoffSlider: CutoffFrequencySlider!
    @IBOutlet weak var feedbackSlider: EffectsUnitSlider!
    
    private var sliders: [EffectsUnitSlider] = []
    
    @IBOutlet weak var lblTime: NSTextField!
    @IBOutlet weak var lblAmount: NSTextField!
    @IBOutlet weak var lblFeedback: NSTextField!
    @IBOutlet weak var lblCutoff: NSTextField!
    
    var time: Double {
        return timeSlider.doubleValue
    }
    
    var amount: Float {
        return amountSlider.floatValue
    }
    
    var cutoff: Float {
        return cutoffSlider.frequency
    }
    
    var feedback: Float {
        return feedbackSlider.floatValue
    }
    
    override func awakeFromNib() {
        sliders = [timeSlider, amountSlider, cutoffSlider, feedbackSlider]
    }
    
    func initialize(_ stateFunction: (() -> EffectsUnitState)?) {
        
        sliders.forEach({
            $0.stateFunction = stateFunction
            $0.updateState()
        })
        
        (cutoffSlider.cell as? CutoffFrequencySliderCell)?.filterType = .lowPass
    }
    
    func setState(_ time: Double, _ timeString: String, _ amount: Float, _ amountString: String, _ feedback: Float, _ feedbackString: String, _ cutoff: Float, _ cutoffString: String) {
        
        setTime(time, timeString)
        setAmount(amount, amountString)
        setFeedback(feedback, feedbackString)
        setCutoff(cutoff, cutoffString)
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        sliders.forEach({$0.setUnitState(state)})
    }
    
    func setTime(_ time: Double, _ timeString: String) {
        
        timeSlider.doubleValue = time
        lblTime.stringValue = timeString
    }
    
    func setAmount(_ amount: Float, _ amountString: String) {
        
        amountSlider.floatValue = amount
        lblAmount.stringValue = amountString
    }
    
    func setFeedback(_ feedback: Float, _ feedbackString: String) {
        
        feedbackSlider.floatValue = feedback
        lblFeedback.stringValue = feedbackString
    }
    
    func setCutoff(_ cutoff: Float, _ cutoffString: String) {
        
        cutoffSlider.setFrequency(cutoff)
        lblCutoff.stringValue = cutoffString
    }
    
    func stateChanged() {
        sliders.forEach({$0.updateState()})
    }
    
    func applyPreset(_ preset: DelayPreset) {
        
        amountSlider.floatValue = preset.amount
        lblAmount.stringValue = ValueFormatter.formatDelayAmount(preset.amount)
        
        timeSlider.doubleValue = preset.time
        lblTime.stringValue = ValueFormatter.formatDelayTime(preset.time)
        
        feedbackSlider.floatValue = preset.feedback
        lblFeedback.stringValue = ValueFormatter.formatDelayFeedback(preset.feedback)
        
        cutoffSlider.setFrequency(preset.lowPassCutoff)
        lblCutoff.stringValue = ValueFormatter.formatDelayLowPassCutoff(preset.lowPassCutoff)
        
        sliders.forEach({$0.setUnitState(preset.state)})
    }
    
    func changeColorScheme() {
        sliders.forEach({$0.redraw()})
    }
}
