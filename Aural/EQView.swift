import Cocoa

class EQView: NSView {
    
    @IBOutlet weak var globalGainSlider: EffectsUnitSlider!
    
    var bandSliders: [EffectsUnitSlider] = []
    var allSliders: [EffectsUnitSlider] = []
    
    func initialize(_ stateFunction: @escaping (() -> EffectsUnitState)) {
        
        for subView in self.subviews {
            
            if let slider = subView as? EffectsUnitSlider {
                
                if slider.tag >= 0 {bandSliders.append(slider)}
                allSliders.append(slider)
                slider.stateFunction = stateFunction
            }
        }
    }
    
    func stateChanged() {
        allSliders.forEach({$0.updateState()})
    }
    
    func updateBands(_ bands: [Int: Float], _ globalGain: Float) {
        
        // Slider tag = index. Default gain value, if bands array doesn't contain gain for index, is 0
        bandSliders.forEach({
            $0.floatValue = bands[$0.tag] ?? 0
        })
        
        globalGainSlider.floatValue = globalGain
    }
}
