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
    
    @IBOutlet weak var chaptersListHeaderNormalSizeStepper: NSStepper!
    @IBOutlet weak var chaptersListHeaderLargerSizeStepper: NSStepper!
    @IBOutlet weak var chaptersListHeaderLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtChaptersListHeaderNormalSize: NSTextField!
    @IBOutlet weak var txtChaptersListHeaderLargerSize: NSTextField!
    @IBOutlet weak var txtChaptersListHeaderLargestSize: NSTextField!
    
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
        
        trackTextNormalSizeStepper.floatValue = Float(fontSet.playlist.trackTextFont_normal.pointSize * 10)
        txtTrackTextNormalSize.stringValue = String(format: "%.1f", trackTextNormalSizeStepper.floatValue / 10.0)
        
        trackTextLargerSizeStepper.floatValue = Float(fontSet.playlist.trackTextFont_larger.pointSize * 10)
        txtTrackTextLargerSize.stringValue = String(format: "%.1f", trackTextLargerSizeStepper.floatValue / 10.0)
        
        trackTextLargestSizeStepper.floatValue = Float(fontSet.playlist.trackTextFont_largest.pointSize * 10)
        txtTrackTextLargestSize.stringValue = String(format: "%.1f", trackTextLargestSizeStepper.floatValue / 10.0)
        
        
        groupTextNormalSizeStepper.floatValue = Float(fontSet.playlist.groupTextFont_normal.pointSize * 10)
        txtGroupTextNormalSize.stringValue = String(format: "%.1f", groupTextNormalSizeStepper.floatValue / 10.0)
        
        groupTextLargerSizeStepper.floatValue = Float(fontSet.playlist.groupTextFont_larger.pointSize * 10)
        txtGroupTextLargerSize.stringValue = String(format: "%.1f", groupTextLargerSizeStepper.floatValue / 10.0)
        
        groupTextLargestSizeStepper.floatValue = Float(fontSet.playlist.groupTextFont_largest.pointSize * 10)
        txtGroupTextLargestSize.stringValue = String(format: "%.1f", groupTextLargestSizeStepper.floatValue / 10.0)
        
        
        summaryNormalSizeStepper.floatValue = Float(fontSet.playlist.summaryFont_normal.pointSize * 10)
        txtSummaryNormalSize.stringValue = String(format: "%.1f", summaryNormalSizeStepper.floatValue / 10.0)
        
        summaryLargerSizeStepper.floatValue = Float(fontSet.playlist.summaryFont_larger.pointSize * 10)
        txtSummaryLargerSize.stringValue = String(format: "%.1f", summaryLargerSizeStepper.floatValue / 10.0)
        
        summaryLargestSizeStepper.floatValue = Float(fontSet.playlist.summaryFont_largest.pointSize * 10)
        txtSummaryLargestSize.stringValue = String(format: "%.1f", summaryLargestSizeStepper.floatValue / 10.0)
        
        
        tabButtonTextNormalSizeStepper.floatValue = Float(fontSet.playlist.tabButtonTextFont_normal.pointSize * 10)
        txtTabButtonTextNormalSize.stringValue = String(format: "%.1f", tabButtonTextNormalSizeStepper.floatValue / 10.0)
        
        tabButtonTextLargerSizeStepper.floatValue = Float(fontSet.playlist.tabButtonTextFont_larger.pointSize * 10)
        txtTabButtonTextLargerSize.stringValue = String(format: "%.1f", tabButtonTextLargerSizeStepper.floatValue / 10.0)
        
        tabButtonTextLargestSizeStepper.floatValue = Float(fontSet.playlist.tabButtonTextFont_largest.pointSize * 10)
        txtTabButtonTextLargestSize.stringValue = String(format: "%.1f", tabButtonTextLargestSizeStepper.floatValue / 10.0)
        
        
        chaptersListHeadingNormalSizeStepper.floatValue = Float(fontSet.playlist.chaptersListCaptionFont_normal.pointSize * 10)
        txtChaptersListHeadingNormalSize.stringValue = String(format: "%.1f", chaptersListHeadingNormalSizeStepper.floatValue / 10.0)
        
        chaptersListHeadingLargerSizeStepper.floatValue = Float(fontSet.playlist.chaptersListCaptionFont_larger.pointSize * 10)
        txtChaptersListHeadingLargerSize.stringValue = String(format: "%.1f", chaptersListHeadingLargerSizeStepper.floatValue / 10.0)
        
        chaptersListHeadingLargestSizeStepper.floatValue = Float(fontSet.playlist.chaptersListCaptionFont_largest.pointSize * 10)
        txtChaptersListHeadingLargestSize.stringValue = String(format: "%.1f", chaptersListHeadingLargestSizeStepper.floatValue / 10.0)
        
        
        chaptersListHeaderNormalSizeStepper.floatValue = Float(fontSet.playlist.chaptersListHeaderFont_normal.pointSize * 10)
        txtChaptersListHeaderNormalSize.stringValue = String(format: "%.1f", chaptersListHeaderNormalSizeStepper.floatValue / 10.0)
        
        chaptersListHeaderLargerSizeStepper.floatValue = Float(fontSet.playlist.chaptersListHeaderFont_larger.pointSize * 10)
        txtChaptersListHeaderLargerSize.stringValue = String(format: "%.1f", chaptersListHeaderLargerSizeStepper.floatValue / 10.0)
        
        chaptersListHeaderLargestSizeStepper.floatValue = Float(fontSet.playlist.chaptersListHeaderFont_largest.pointSize * 10)
        txtChaptersListHeaderLargestSize.stringValue = String(format: "%.1f", chaptersListHeaderLargestSizeStepper.floatValue / 10.0)
        
        
        chaptersListSearchFieldNormalSizeStepper.floatValue = Float(fontSet.playlist.chaptersListSearchFont_normal.pointSize * 10)
        txtChaptersListSearchFieldNormalSize.stringValue = String(format: "%.1f", chaptersListSearchFieldNormalSizeStepper.floatValue / 10.0)
        
        chaptersListSearchFieldLargerSizeStepper.floatValue = Float(fontSet.playlist.chaptersListSearchFont_larger.pointSize * 10)
        txtChaptersListSearchFieldLargerSize.stringValue = String(format: "%.1f", chaptersListSearchFieldLargerSizeStepper.floatValue / 10.0)
        
        chaptersListSearchFieldLargestSizeStepper.floatValue = Float(fontSet.playlist.chaptersListSearchFont_largest.pointSize * 10)
        txtChaptersListSearchFieldLargestSize.stringValue = String(format: "%.1f", chaptersListSearchFieldLargestSizeStepper.floatValue / 10.0)
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
    
    
    
    @IBAction func chaptersListHeaderNormalSizeStepperAction(_ sender: NSStepper) {
        txtChaptersListHeaderNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func chaptersListHeaderLargerSizeStepperAction(_ sender: NSStepper) {
        txtChaptersListHeaderLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func chaptersListHeaderLargestSizeStepperAction(_ sender: NSStepper) {
        txtChaptersListHeaderLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
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
    
    func applyFontSet(_ context: FontSetChangeContext, to fontSet: FontSet) {
        
        let textFontName = context.textFontName
        let headingFontName = context.headingFontName
        
        fontSet.playlist.trackTextFont_normal = NSFont(name: textFontName, size: CGFloat(trackTextNormalSizeStepper.floatValue / 10.0))!
        fontSet.playlist.trackTextFont_larger = NSFont(name: textFontName, size: CGFloat(trackTextLargerSizeStepper.floatValue / 10.0))!
        fontSet.playlist.trackTextFont_largest = NSFont(name: textFontName, size: CGFloat(trackTextLargestSizeStepper.floatValue / 10.0))!
        
        fontSet.playlist.groupTextFont_normal = NSFont(name: textFontName, size: CGFloat(groupTextNormalSizeStepper.floatValue / 10.0))!
        fontSet.playlist.groupTextFont_larger = NSFont(name: textFontName, size: CGFloat(groupTextLargerSizeStepper.floatValue / 10.0))!
        fontSet.playlist.groupTextFont_largest = NSFont(name: textFontName, size: CGFloat(groupTextLargestSizeStepper.floatValue / 10.0))!
        
        fontSet.playlist.summaryFont_normal = NSFont(name: textFontName, size: CGFloat(summaryNormalSizeStepper.floatValue / 10.0))!
        fontSet.playlist.summaryFont_larger = NSFont(name: textFontName, size: CGFloat(summaryLargerSizeStepper.floatValue / 10.0))!
        fontSet.playlist.summaryFont_largest = NSFont(name: textFontName, size: CGFloat(summaryLargestSizeStepper.floatValue / 10.0))!
        
        fontSet.playlist.tabButtonTextFont_normal = NSFont(name: headingFontName, size: CGFloat(tabButtonTextNormalSizeStepper.floatValue / 10.0))!
        fontSet.playlist.tabButtonTextFont_larger = NSFont(name: headingFontName, size: CGFloat(tabButtonTextLargerSizeStepper.floatValue / 10.0))!
        fontSet.playlist.tabButtonTextFont_largest = NSFont(name: headingFontName, size: CGFloat(tabButtonTextLargestSizeStepper.floatValue / 10.0))!
        
        fontSet.playlist.chaptersListHeaderFont_normal = NSFont(name: headingFontName, size: CGFloat(chaptersListHeaderNormalSizeStepper.floatValue / 10.0))!
        fontSet.playlist.chaptersListHeaderFont_larger = NSFont(name: headingFontName, size: CGFloat(chaptersListHeaderLargerSizeStepper.floatValue / 10.0))!
        fontSet.playlist.chaptersListHeaderFont_largest = NSFont(name: headingFontName, size: CGFloat(chaptersListHeaderLargestSizeStepper.floatValue / 10.0))!
        
        fontSet.playlist.chaptersListCaptionFont_normal = NSFont(name: headingFontName, size: CGFloat(chaptersListHeadingNormalSizeStepper.floatValue / 10.0))!
        fontSet.playlist.chaptersListCaptionFont_larger = NSFont(name: headingFontName, size: CGFloat(chaptersListHeadingLargerSizeStepper.floatValue / 10.0))!
        fontSet.playlist.chaptersListCaptionFont_largest = NSFont(name: headingFontName, size: CGFloat(chaptersListHeadingLargestSizeStepper.floatValue / 10.0))!
        
        fontSet.playlist.chaptersListSearchFont_normal = NSFont(name: textFontName, size: CGFloat(chaptersListSearchFieldNormalSizeStepper.floatValue / 10.0))!
        fontSet.playlist.chaptersListSearchFont_larger = NSFont(name: textFontName, size: CGFloat(chaptersListSearchFieldLargerSizeStepper.floatValue / 10.0))!
        fontSet.playlist.chaptersListSearchFont_largest = NSFont(name: textFontName, size: CGFloat(chaptersListSearchFieldLargestSizeStepper.floatValue / 10.0))!
    }
}
