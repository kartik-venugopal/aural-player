import Cocoa

class EffectsFontSetViewController: NSViewController, FontSetsViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var unitCaptionStepper: NSStepper!
    @IBOutlet weak var txtUnitCaption: NSTextField!
    
    @IBOutlet weak var unitFunctionStepper: NSStepper!
    @IBOutlet weak var txtUnitFunction: NSTextField!
    
    @IBOutlet weak var masterUnitFunctionStepper: NSStepper!
    @IBOutlet weak var txtMasterUnitFunction: NSTextField!
    
    @IBOutlet weak var filterChartStepper: NSStepper!
    @IBOutlet weak var txtFilterChart: NSTextField!
    
    override var nibName: NSNib.Name? {return "EffectsFontSet"}
    
    var fontSetsView: NSView {
        self.view
    }
    
    // Scrolls the scroll view to the top
    private func scrollToTop() {
        
        let contentView: NSClipView = scrollView.contentView
        contentView.scroll(NSMakePoint(0, contentView.documentView!.frame.height))
    }
    
    func resetFields(_ fontSet: FontSet) {
        
        scrollToTop()
        
        unitCaptionStepper.floatValue = Float(fontSet.effects.unitCaptionFont.pointSize * 10)
        txtUnitCaption.stringValue = String(format: "%.1f", unitCaptionStepper.floatValue / 10.0)
        
        unitFunctionStepper.floatValue = Float(fontSet.effects.unitFunctionFont.pointSize * 10)
        txtUnitFunction.stringValue = String(format: "%.1f", unitFunctionStepper.floatValue / 10.0)
        
        masterUnitFunctionStepper.floatValue = Float(fontSet.effects.masterUnitFunctionFont.pointSize * 10)
        txtMasterUnitFunction.stringValue = String(format: "%.1f", masterUnitFunctionStepper.floatValue / 10.0)
        
        filterChartStepper.floatValue = Float(fontSet.effects.filterChartFont.pointSize * 10)
        txtFilterChart.stringValue = String(format: "%.1f", filterChartStepper.floatValue / 10.0)
    }
    
    @IBAction func unitCaptionStepperAction(_ sender: NSStepper) {
        txtUnitCaption.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func unitFunctionStepperAction(_ sender: NSStepper) {
        txtUnitFunction.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func masterUnitFunctionStepperAction(_ sender: NSStepper) {
        txtMasterUnitFunction.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func filterChartStepperAction(_ sender: NSStepper) {
        txtFilterChart.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    func applyFontSet(_ context: FontSetChangeContext, to fontSet: FontSet) {
        
        let textFontName = context.textFontName
        let headingFontName = context.headingFontName
        
        fontSet.effects.unitCaptionFont = NSFont(name: headingFontName, size: CGFloat(unitCaptionStepper.floatValue / 10.0))!
        fontSet.effects.unitFunctionFont = NSFont(name: textFontName, size: CGFloat(unitFunctionStepper.floatValue / 10.0))!
        fontSet.effects.masterUnitFunctionFont = NSFont(name: headingFontName, size: CGFloat(masterUnitFunctionStepper.floatValue / 10.0))!
        fontSet.effects.filterChartFont = NSFont(name: textFontName, size: CGFloat(filterChartStepper.floatValue / 10.0))!
    }
}
