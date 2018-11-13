import Cocoa

class FilterBandEditorController: NSWindowController, ModalDialogDelegate {
    
    override var windowNibName: String? {return "FilterBandEditor"}
    @IBOutlet weak var lblTitle: NSTextField!
    
    @IBOutlet weak var freqRangeSlider: FilterBandSlider!
    @IBOutlet weak var cutoffSlider: CutoffFrequencySlider!
    @IBOutlet weak var cutoffSliderCell: CutoffFrequencySliderCell!
    
    @IBOutlet weak var lblRangeCaption: NSTextField!
    @IBOutlet weak var lblPresetRangesCaption: NSTextField!
    @IBOutlet weak var presetRangesMenu: NSPopUpButton!
    @IBOutlet weak var lblCutoffCaption: NSTextField!
    @IBOutlet weak var lblPresetCutoffsCaption: NSTextField!
    @IBOutlet weak var presetCutoffsMenu: NSPopUpButton!
    
    @IBOutlet weak var lblFreqRange: NSTextField!
    
    @IBOutlet weak var filterTypeMenu: NSPopUpButton!
    
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    private let filterUnit: FilterUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.filterUnit
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    private enum EditorAction {
        
        case add
        case edit
    }
    
    private var action: EditorAction = .add
    private var editBandIndex: Int = -1
    
    override func awakeFromNib() {
        
        freqRangeSlider.onControlChanged = {
            (slider: RangeSlider) -> Void in
            self.freqRangeChanged()
        }
    }
    
    private func freqRangeChanged() {
        lblFreqRange.stringValue = String(format: "[%@ - %@]", formatFrequency(freqRangeSlider.startFrequency), formatFrequency(freqRangeSlider.endFrequency))
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if (!self.isWindowLoaded) {
            _ = self.window!
        }
        
        action = .add
        
        resetFields()
        
        UIUtils.showModalDialog(self.window!)
        
        return .ok
    }
    
    func resetFields() {
        lblTitle.stringValue = action == .add ? "Add filter band" : "Edit filter band"
        bandTypeAction(self)
        presetCutoffsMenu.selectItem(at: -1)
        presetRangesMenu.selectItem(at: -1)
    }
    
    @IBAction func cutoffSliderAction(_ sender: Any) {
        lblFreqRange.stringValue = formatFrequency(cutoffSlider.frequency)
    }
    
    private func formatFrequency(_ freq: Float) -> String {
        
        let rounded = roundedInt(freq)
        
        if rounded % 1000 == 0 {
            return String(format: "%dKHz", rounded / 1000)
        } else {
            return String(format: "%dHz", rounded)
        }
    }
    
    @IBAction func bandTypeAction(_ sender: Any) {
        
        let filterType = FilterBandType(rawValue: filterTypeMenu.titleOfSelectedItem!)!
        
        [freqRangeSlider, lblRangeCaption, lblPresetRangesCaption, presetRangesMenu].forEach({$0?.showIf_elseHide(filterType == .bandPass || filterType == .bandStop)})
        [cutoffSlider, lblCutoffCaption, lblPresetCutoffsCaption, presetCutoffsMenu].forEach({$0?.hideIf_elseShow(filterType == .bandPass || filterType == .bandStop)})
        
        if filterType == .bandPass || filterType == .bandStop {

            freqRangeSlider.filterType = filterType
            freqRangeChanged()
            
        } else {
            
            cutoffSliderCell.filterType = filterType
            cutoffSlider.redraw()
            cutoffSliderAction(self)
        }
    }
    
    @IBAction func presetRangeAction(_ sender: NSPopUpButton) {
        
        if let range = sender.selectedItem as? FrequencyRangeMenuItem {
        
            freqRangeSlider.setFrequencyRange(range.minFreq, range.maxFreq)
            freqRangeChanged()
        }
        
        presetRangesMenu.selectItem(at: -1)
    }
    
    @IBAction func presetCutoffAction(_ sender: NSPopUpButton) {
        
        cutoffSlider.setFrequency(Float(sender.selectedItem!.tag))
        cutoffSliderAction(self)
        presetCutoffsMenu.selectItem(at: -1)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        let filterType = FilterBandType(rawValue: filterTypeMenu.titleOfSelectedItem!)!
        var band: FilterBand
        
        switch filterType {
            
        case .bandPass, .bandStop:
            
            let minFreq = freqRangeSlider.startFrequency
            let maxFreq = freqRangeSlider.endFrequency
            
            band = FilterBand(filterType).withMinFreq(minFreq).withMaxFreq(maxFreq)
            
        case .lowPass:
            
            band = FilterBand(filterType).withMaxFreq(cutoffSlider.frequency)
            
        case .highPass:
            
            band = FilterBand(filterType).withMinFreq(cutoffSlider.frequency)
        }
        
        if action == .add {
            _ = filterUnit.addBand(band)
        } else {
            filterUnit.updateBand(editBandIndex, band)
        }
        
        modalDialogResponse = .ok
        UIUtils.dismissModalDialog()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        modalDialogResponse = .cancel
        UIUtils.dismissModalDialog()
    }
    
    func editBand(_ index: Int, _ band: FilterBand) {
        
        action = .edit
        editBandIndex = index
        
        if (!self.isWindowLoaded) {
            _ = self.window!
        }

        filterTypeMenu.selectItem(withTitle: band.type.rawValue)
        
        let filterType = band.type
        if filterType == .bandPass || filterType == .bandStop {
            
            freqRangeSlider.setFrequencyRange(band.minFreq!, band.maxFreq!)
            
        } else {
            
            cutoffSlider.setFrequency(filterType == .lowPass ? band.maxFreq! : band.minFreq!)
        }
        
        resetFields()
        UIUtils.showModalDialog(self.window!)
    }
}

func roundedInt(_ float: Float) -> Int {
    return Int(roundf(float))
}

@IBDesignable
class FrequencyRangeMenuItem: NSMenuItem {
    
    @IBInspectable var minFreq: Float = AppConstants.audibleRangeMin
    @IBInspectable var maxFreq: Float = AppConstants.audibleRangeMax
}
