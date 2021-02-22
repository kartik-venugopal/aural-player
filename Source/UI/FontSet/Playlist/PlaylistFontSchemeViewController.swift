import Cocoa

class PlaylistFontSchemeViewController: NSViewController, FontSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var trackTextStepper: NSStepper!
    @IBOutlet weak var txtTrackText: NSTextField!
    
    @IBOutlet weak var trackTextYOffsetStepper: NSStepper!
    @IBOutlet weak var txtTrackTextYOffset: NSTextField!
    
    @IBOutlet weak var groupTextStepper: NSStepper!
    @IBOutlet weak var txtGroupText: NSTextField!
    
    @IBOutlet weak var groupTextYOffsetStepper: NSStepper!
    @IBOutlet weak var txtGroupTextYOffset: NSTextField!
    
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
    
    override var nibName: NSNib.Name? {return "PlaylistFontScheme"}
    
    var fontSchemesView: NSView {
        self.view
    }
    
    // Scrolls the scroll view to the top
    private func scrollToTop() {
        
        let contentView: NSClipView = scrollView.contentView
        contentView.scroll(NSMakePoint(0, contentView.documentView!.frame.height))
    }
    
    func resetFields(_ fontScheme: FontScheme) {
        
        scrollToTop()
        
        trackTextStepper.floatValue = Float(fontScheme.playlist.trackTextFont.pointSize * 10)
        txtTrackText.stringValue = String(format: "%.1f", trackTextStepper.floatValue / 10.0)
        
        trackTextYOffsetStepper.integerValue = roundedInt(fontScheme.playlist.trackTextYOffset)
        txtTrackTextYOffset.stringValue = String(format: "%d px", trackTextYOffsetStepper.integerValue)
        
        groupTextStepper.floatValue = Float(fontScheme.playlist.groupTextFont.pointSize * 10)
        txtGroupText.stringValue = String(format: "%.1f", groupTextStepper.floatValue / 10.0)
        
        groupTextYOffsetStepper.integerValue = roundedInt(fontScheme.playlist.groupTextYOffset)
        txtGroupTextYOffset.stringValue = String(format: "%d px", groupTextYOffsetStepper.integerValue)
      
        summaryStepper.floatValue = Float(fontScheme.playlist.summaryFont.pointSize * 10)
        txtSummary.stringValue = String(format: "%.1f", summaryStepper.floatValue / 10.0)
        
        tabButtonTextStepper.floatValue = Float(fontScheme.playlist.tabButtonTextFont.pointSize * 10)
        txtTabButtonText.stringValue = String(format: "%.1f", tabButtonTextStepper.floatValue / 10.0)
        
        chaptersListHeadingStepper.floatValue = Float(fontScheme.playlist.chaptersListCaptionFont.pointSize * 10)
        txtChaptersListHeading.stringValue = String(format: "%.1f", chaptersListHeadingStepper.floatValue / 10.0)
        
        chaptersListHeaderStepper.floatValue = Float(fontScheme.playlist.chaptersListHeaderFont.pointSize * 10)
        txtChaptersListHeader.stringValue = String(format: "%.1f", chaptersListHeaderStepper.floatValue / 10.0)
        
        chaptersListSearchFieldStepper.floatValue = Float(fontScheme.playlist.chaptersListSearchFont.pointSize * 10)
        txtChaptersListSearchField.stringValue = String(format: "%.1f", chaptersListSearchFieldStepper.floatValue / 10.0)
    }
    
    @IBAction func trackTextStepperAction(_ sender: NSStepper) {
        txtTrackText.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func trackTextYOffsetStepperAction(_ sender: NSStepper) {
        txtTrackTextYOffset.stringValue = String(format: "%d px", trackTextYOffsetStepper.integerValue)
    }
    
    @IBAction func groupTextStepperAction(_ sender: NSStepper) {
        txtGroupText.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func groupTextYOffsetStepperAction(_ sender: NSStepper) {
        txtGroupTextYOffset.stringValue = String(format: "%d px", groupTextYOffsetStepper.integerValue)
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
   
    func applyFontScheme(_ context: FontSchemeChangeContext, to fontScheme: FontScheme) {
        
        let textFontName = context.textFontName
        let headingFontName = context.headingFontName
        
        fontScheme.playlist.trackTextFont = NSFont(name: textFontName, size: CGFloat(trackTextStepper.floatValue / 10.0))!
        fontScheme.playlist.trackTextYOffset = CGFloat(trackTextYOffsetStepper.integerValue)
        
        fontScheme.playlist.groupTextFont = NSFont(name: textFontName, size: CGFloat(groupTextStepper.floatValue / 10.0))!
        fontScheme.playlist.groupTextYOffset = CGFloat(groupTextYOffsetStepper.integerValue)
        
        fontScheme.playlist.summaryFont = NSFont(name: textFontName, size: CGFloat(summaryStepper.floatValue / 10.0))!
        fontScheme.playlist.tabButtonTextFont = NSFont(name: headingFontName, size: CGFloat(tabButtonTextStepper.floatValue / 10.0))!
        
        fontScheme.playlist.chaptersListHeaderFont = NSFont(name: headingFontName, size: CGFloat(chaptersListHeaderStepper.floatValue / 10.0))!
        fontScheme.playlist.chaptersListCaptionFont = NSFont(name: headingFontName, size: CGFloat(chaptersListHeadingStepper.floatValue / 10.0))!
        fontScheme.playlist.chaptersListSearchFont = NSFont(name: textFontName, size: CGFloat(chaptersListSearchFieldStepper.floatValue / 10.0))!
    }
}
