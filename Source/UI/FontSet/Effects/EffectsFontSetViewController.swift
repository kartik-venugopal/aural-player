import Cocoa

class EffectsFontSetViewController: NSViewController, FontSetsViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var unitCaptionNormalSizeStepper: NSStepper!
    @IBOutlet weak var unitCaptionLargerSizeStepper: NSStepper!
    @IBOutlet weak var unitCaptionLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtUnitCaptionNormalSize: NSTextField!
    @IBOutlet weak var txtUnitCaptionLargerSize: NSTextField!
    @IBOutlet weak var txtUnitCaptionLargestSize: NSTextField!
    
    @IBOutlet weak var unitFunctionNormalSizeStepper: NSStepper!
    @IBOutlet weak var unitFunctionLargerSizeStepper: NSStepper!
    @IBOutlet weak var unitFunctionLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtUnitFunctionNormalSize: NSTextField!
    @IBOutlet weak var txtUnitFunctionLargerSize: NSTextField!
    @IBOutlet weak var txtUnitFunctionLargestSize: NSTextField!
    
    @IBOutlet weak var masterUnitFunctionNormalSizeStepper: NSStepper!
    @IBOutlet weak var masterUnitFunctionLargerSizeStepper: NSStepper!
    @IBOutlet weak var masterUnitFunctionLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtMasterUnitFunctionNormalSize: NSTextField!
    @IBOutlet weak var txtMasterUnitFunctionLargerSize: NSTextField!
    @IBOutlet weak var txtMasterUnitFunctionLargestSize: NSTextField!
    
    @IBOutlet weak var filterChartNormalSizeStepper: NSStepper!
    @IBOutlet weak var filterChartLargerSizeStepper: NSStepper!
    @IBOutlet weak var filterChartLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtFilterChartNormalSize: NSTextField!
    @IBOutlet weak var txtFilterChartLargerSize: NSTextField!
    @IBOutlet weak var txtFilterChartLargestSize: NSTextField!
    
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
    }
    
    @IBAction func unitCaptionNormalSizeStepperAction(_ sender: NSStepper) {
        txtUnitCaptionNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func unitCaptionLargerSizeStepperAction(_ sender: NSStepper) {
        txtUnitCaptionLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func unitCaptionLargestSizeStepperAction(_ sender: NSStepper) {
        txtUnitCaptionLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    
    
    @IBAction func unitFunctionNormalSizeStepperAction(_ sender: NSStepper) {
        txtUnitFunctionNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func unitFunctionLargerSizeStepperAction(_ sender: NSStepper) {
        txtUnitFunctionLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func unitFunctionLargestSizeStepperAction(_ sender: NSStepper) {
        txtUnitFunctionLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    
    
    @IBAction func masterUnitFunctionNormalSizeStepperAction(_ sender: NSStepper) {
        txtMasterUnitFunctionNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func masterUnitFunctionLargerSizeStepperAction(_ sender: NSStepper) {
        txtMasterUnitFunctionLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func masterUnitFunctionLargestSizeStepperAction(_ sender: NSStepper) {
        txtMasterUnitFunctionLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    
    
    @IBAction func filterChartNormalSizeStepperAction(_ sender: NSStepper) {
        txtFilterChartNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func filterChartLargerSizeStepperAction(_ sender: NSStepper) {
        txtFilterChartLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func filterChartLargestSizeStepperAction(_ sender: NSStepper) {
        txtFilterChartLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    func applyFontSet(_ context: FontSetChangeContext, to fontSet: FontSet) {
        
        let textFontName = context.textFontName
        let headingFontName = context.headingFontName
        
        fontSet.effects.unitCaptionFont_normal = NSFont(name: headingFontName, size: CGFloat(unitCaptionNormalSizeStepper.floatValue / 10.0))!
        fontSet.effects.unitCaptionFont_larger = NSFont(name: headingFontName, size: CGFloat(unitCaptionLargerSizeStepper.floatValue / 10.0))!
        fontSet.effects.unitCaptionFont_largest = NSFont(name: headingFontName, size: CGFloat(unitCaptionLargestSizeStepper.floatValue / 10.0))!
        
        fontSet.effects.unitFunctionFont_normal = NSFont(name: textFontName, size: CGFloat(unitFunctionNormalSizeStepper.floatValue / 10.0))!
        fontSet.effects.unitFunctionFont_larger = NSFont(name: textFontName, size: CGFloat(unitFunctionLargerSizeStepper.floatValue / 10.0))!
        fontSet.effects.unitFunctionFont_largest = NSFont(name: textFontName, size: CGFloat(unitFunctionLargestSizeStepper.floatValue / 10.0))!
        
        fontSet.effects.masterUnitFunctionFont_normal = NSFont(name: headingFontName, size: CGFloat(masterUnitFunctionNormalSizeStepper.floatValue / 10.0))!
        fontSet.effects.masterUnitFunctionFont_larger = NSFont(name: headingFontName, size: CGFloat(masterUnitFunctionLargerSizeStepper.floatValue / 10.0))!
        fontSet.effects.masterUnitFunctionFont_largest = NSFont(name: headingFontName, size: CGFloat(masterUnitFunctionLargestSizeStepper.floatValue / 10.0))!
        
        fontSet.effects.filterChartFont_normal = NSFont(name: textFontName, size: CGFloat(filterChartNormalSizeStepper.floatValue / 10.0))!
        fontSet.effects.filterChartFont_larger = NSFont(name: textFontName, size: CGFloat(filterChartLargerSizeStepper.floatValue / 10.0))!
        fontSet.effects.filterChartFont_largest = NSFont(name: textFontName, size: CGFloat(filterChartLargestSizeStepper.floatValue / 10.0))!
    }
}
