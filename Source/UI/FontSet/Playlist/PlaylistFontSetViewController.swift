import Cocoa

class PlaylistFontSetViewController: NSViewController, FontSetsViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var trackTextStepper: NSStepper!
    @IBOutlet weak var txtTrackText: NSTextField!
    
    @IBOutlet weak var groupTextStepper: NSStepper!
    @IBOutlet weak var txtGroupText: NSTextField!
    
    @IBOutlet weak var summaryStepper: NSStepper!
    @IBOutlet weak var txtSummary: NSTextField!

    @IBOutlet weak var tabButtonTextStepper: NSStepper!
    @IBOutlet weak var txtTabButtonText: NSTextField!
    
    @IBOutlet weak var chaptersListHeadingStepper: NSStepper!
    @IBOutlet weak var txtChaptersListHeading: NSTextField!
    
    @IBOutlet weak var chaptersListHeaderStepper: NSStepper!
    @IBOutlet weak var txtChaptersListHeader: NSTextField!
    
    @IBOutlet weak var chaptersListSearchFieldStepper: NSStepper!
    @IBOutlet weak var txtChaptersListSearchField: NSTextField!
    
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
        
        trackTextStepper.floatValue = Float(fontSet.playlist.trackTextFont.pointSize * 10)
        txtTrackText.stringValue = String(format: "%.1f", trackTextStepper.floatValue / 10.0)
        
        groupTextStepper.floatValue = Float(fontSet.playlist.groupTextFont.pointSize * 10)
        txtGroupText.stringValue = String(format: "%.1f", groupTextStepper.floatValue / 10.0)
      
        summaryStepper.floatValue = Float(fontSet.playlist.summaryFont.pointSize * 10)
        txtSummary.stringValue = String(format: "%.1f", summaryStepper.floatValue / 10.0)
        
        tabButtonTextStepper.floatValue = Float(fontSet.playlist.tabButtonTextFont.pointSize * 10)
        txtTabButtonText.stringValue = String(format: "%.1f", tabButtonTextStepper.floatValue / 10.0)
        
        chaptersListHeadingStepper.floatValue = Float(fontSet.playlist.chaptersListCaptionFont.pointSize * 10)
        txtChaptersListHeading.stringValue = String(format: "%.1f", chaptersListHeadingStepper.floatValue / 10.0)
        
        chaptersListHeaderStepper.floatValue = Float(fontSet.playlist.chaptersListHeaderFont.pointSize * 10)
        txtChaptersListHeader.stringValue = String(format: "%.1f", chaptersListHeaderStepper.floatValue / 10.0)
        
        chaptersListSearchFieldStepper.floatValue = Float(fontSet.playlist.chaptersListSearchFont.pointSize * 10)
        txtChaptersListSearchField.stringValue = String(format: "%.1f", chaptersListSearchFieldStepper.floatValue / 10.0)
    }
    
    @IBAction func trackTextStepperAction(_ sender: NSStepper) {
        txtTrackText.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func groupTextStepperAction(_ sender: NSStepper) {
        txtGroupText.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func summaryStepperAction(_ sender: NSStepper) {
        txtSummary.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
   
    @IBAction func tabButtonTextStepperAction(_ sender: NSStepper) {
        txtTabButtonText.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func chaptersListHeadingStepperAction(_ sender: NSStepper) {
        txtChaptersListHeading.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func chaptersListHeaderStepperAction(_ sender: NSStepper) {
        txtChaptersListHeader.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func chaptersListSearchFieldStepperAction(_ sender: NSStepper) {
        txtChaptersListSearchField.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
   
    func applyFontSet(_ context: FontSetChangeContext, to fontSet: FontSet) {
        
        let textFontName = context.textFontName
        let headingFontName = context.headingFontName
        
        fontSet.playlist.trackTextFont = NSFont(name: textFontName, size: CGFloat(trackTextStepper.floatValue / 10.0))!
        fontSet.playlist.groupTextFont = NSFont(name: textFontName, size: CGFloat(groupTextStepper.floatValue / 10.0))!
        fontSet.playlist.summaryFont = NSFont(name: textFontName, size: CGFloat(summaryStepper.floatValue / 10.0))!
        fontSet.playlist.tabButtonTextFont = NSFont(name: headingFontName, size: CGFloat(tabButtonTextStepper.floatValue / 10.0))!
        fontSet.playlist.chaptersListHeaderFont = NSFont(name: headingFontName, size: CGFloat(chaptersListHeaderStepper.floatValue / 10.0))!
        fontSet.playlist.chaptersListCaptionFont = NSFont(name: headingFontName, size: CGFloat(chaptersListHeadingStepper.floatValue / 10.0))!
        fontSet.playlist.chaptersListSearchFont = NSFont(name: textFontName, size: CGFloat(chaptersListSearchFieldStepper.floatValue / 10.0))!
    }
}
