import Cocoa

class PlaylistFontSetViewController: NSViewController, FontSetsViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var trackTextNormalSizeStepper: NSStepper!
    @IBOutlet weak var trackTextLargerSizeStepper: NSStepper!
    @IBOutlet weak var trackTextLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtTrackTextNormalSize: NSTextField!
    @IBOutlet weak var txtTrackTextLargerSize: NSTextField!
    @IBOutlet weak var txtTrackTextLargestSize: NSTextField!
    
    @IBOutlet weak var groupTextNormalSizeStepper: NSStepper!
    @IBOutlet weak var groupTextLargerSizeStepper: NSStepper!
    @IBOutlet weak var groupTextLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtGroupTextNormalSize: NSTextField!
    @IBOutlet weak var txtGroupTextLargerSize: NSTextField!
    @IBOutlet weak var txtGroupTextLargestSize: NSTextField!
    
    @IBOutlet weak var summaryNormalSizeStepper: NSStepper!
    @IBOutlet weak var summaryLargerSizeStepper: NSStepper!
    @IBOutlet weak var summaryLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtSummaryNormalSize: NSTextField!
    @IBOutlet weak var txtSummaryLargerSize: NSTextField!
    @IBOutlet weak var txtSummaryLargestSize: NSTextField!
    
    @IBOutlet weak var tabButtonTextNormalSizeStepper: NSStepper!
    @IBOutlet weak var tabButtonTextLargerSizeStepper: NSStepper!
    @IBOutlet weak var tabButtonTextLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtTabButtonTextNormalSize: NSTextField!
    @IBOutlet weak var txtTabButtonTextLargerSize: NSTextField!
    @IBOutlet weak var txtTabButtonTextLargestSize: NSTextField!
    
    @IBOutlet weak var chaptersListHeadingNormalSizeStepper: NSStepper!
    @IBOutlet weak var chaptersListHeadingLargerSizeStepper: NSStepper!
    @IBOutlet weak var chaptersListHeadingLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtChaptersListHeadingNormalSize: NSTextField!
    @IBOutlet weak var txtChaptersListHeadingLargerSize: NSTextField!
    @IBOutlet weak var txtChaptersListHeadingLargestSize: NSTextField!
    
    @IBOutlet weak var chaptersListTableHeaderNormalSizeStepper: NSStepper!
    @IBOutlet weak var chaptersListTableHeaderLargerSizeStepper: NSStepper!
    @IBOutlet weak var chaptersListTableHeaderLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtChaptersListTableHeaderNormalSize: NSTextField!
    @IBOutlet weak var txtChaptersListTableHeaderLargerSize: NSTextField!
    @IBOutlet weak var txtChaptersListTableHeaderLargestSize: NSTextField!
    
    @IBOutlet weak var chaptersListSearchFieldNormalSizeStepper: NSStepper!
    @IBOutlet weak var chaptersListSearchFieldLargerSizeStepper: NSStepper!
    @IBOutlet weak var chaptersListSearchFieldLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtChaptersListSearchFieldNormalSize: NSTextField!
    @IBOutlet weak var txtChaptersListSearchFieldLargerSize: NSTextField!
    @IBOutlet weak var txtChaptersListSearchFieldLargestSize: NSTextField!
    
    override var nibName: NSNib.Name? {return "PlaylistFontSet"}
    
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
    
    @IBAction func trackTextNormalSizeStepperAction(_ sender: NSStepper) {
        txtTrackTextNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func trackTextLargerSizeStepperAction(_ sender: NSStepper) {
        txtTrackTextLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func trackTextLargestSizeStepperAction(_ sender: NSStepper) {
        txtTrackTextLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    
    
    @IBAction func groupTextNormalSizeStepperAction(_ sender: NSStepper) {
        txtGroupTextNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func groupTextLargerSizeStepperAction(_ sender: NSStepper) {
        txtGroupTextLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func groupTextLargestSizeStepperAction(_ sender: NSStepper) {
        txtGroupTextLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    
    
    @IBAction func summaryNormalSizeStepperAction(_ sender: NSStepper) {
        txtSummaryNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func summaryLargerSizeStepperAction(_ sender: NSStepper) {
        txtSummaryLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func summaryLargestSizeStepperAction(_ sender: NSStepper) {
        txtSummaryLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    
    
    @IBAction func tabButtonTextNormalSizeStepperAction(_ sender: NSStepper) {
        txtTabButtonTextNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func tabButtonTextLargerSizeStepperAction(_ sender: NSStepper) {
        txtTabButtonTextLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func tabButtonTextLargestSizeStepperAction(_ sender: NSStepper) {
        txtTabButtonTextLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    
    
    @IBAction func chaptersListHeadingNormalSizeStepperAction(_ sender: NSStepper) {
        txtChaptersListHeadingNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func chaptersListHeadingLargerSizeStepperAction(_ sender: NSStepper) {
        txtChaptersListHeadingLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func chaptersListHeadingLargestSizeStepperAction(_ sender: NSStepper) {
        txtChaptersListHeadingLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    
    
    @IBAction func chaptersListTableHeaderNormalSizeStepperAction(_ sender: NSStepper) {
        txtChaptersListTableHeaderNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func chaptersListTableHeaderLargerSizeStepperAction(_ sender: NSStepper) {
        txtChaptersListTableHeaderLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func chaptersListTableHeaderLargestSizeStepperAction(_ sender: NSStepper) {
        txtChaptersListTableHeaderLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    
    
    @IBAction func chaptersListSearchFieldNormalSizeStepperAction(_ sender: NSStepper) {
        txtChaptersListSearchFieldNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func chaptersListSearchFieldLargerSizeStepperAction(_ sender: NSStepper) {
        txtChaptersListSearchFieldLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func chaptersListSearchFieldLargestSizeStepperAction(_ sender: NSStepper) {
        txtChaptersListSearchFieldLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
}
