import Cocoa

class FilterBandEditorController: NSWindowController, ModalDialogDelegate {
    
    override var windowNibName: String? {return "FilterBandEditor"}
    @IBOutlet weak var lblTitle: NSTextField!
    
    @IBOutlet weak var freqRangeSlider: FilterBandSlider!
    @IBOutlet weak var cutoffSlider: CutoffFrequencySlider!
    @IBOutlet weak var cutoffSliderCell: CutoffFrequencySliderCell!
    
    @IBOutlet weak var lblRangeCaption: NSTextField!
    @IBOutlet weak var lblCutoffCaption: NSTextField!
    
    @IBOutlet weak var lblFreqRange: NSTextField!
    
    @IBOutlet weak var filterTypeMenu: NSPopUpButton!
    
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
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
        lblFreqRange.stringValue = String(format: "[%dHz - %dHz]", roundedInt(freqRangeSlider.startFrequency), roundedInt(freqRangeSlider.endFrequency))
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
    }
    
    @IBAction func cutoffSliderAction(_ sender: Any) {
        lblFreqRange.stringValue = String(format: "%dHz", roundedInt(cutoffSlider.frequency))
    }
    
    @IBAction func bandTypeAction(_ sender: Any) {
        
        let filterType = FilterBandType(rawValue: filterTypeMenu.titleOfSelectedItem!)!
        
        if filterType == .bandPass || filterType == .bandStop {

            freqRangeSlider.filterType = filterType
            freqRangeSlider.show()
            lblRangeCaption.show()
            
            lblCutoffCaption.hide()
            cutoffSlider.hide()
            
            freqRangeChanged()
            
        } else {
            
            freqRangeSlider.hide()
            lblRangeCaption.hide()
            
            lblCutoffCaption.show()
            cutoffSliderCell.filterType = filterType
            cutoffSlider.redraw()
            cutoffSlider.show()
            
            cutoffSliderAction(self)
        }
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
        
            _ = graph.addFilterBand(band)
            
        } else {
            
            graph.updateFilterBand(editBandIndex, band)
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
            
            freqRangeSlider.setStartFrequency(band.minFreq!)
            freqRangeSlider.setEndFrequency(band.maxFreq!)
            
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
