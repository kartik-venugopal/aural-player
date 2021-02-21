import Cocoa

class PlayerFontSetViewController: NSViewController, FontSetsViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var titleNormalSizeStepper: NSStepper!
    @IBOutlet weak var titleLargerSizeStepper: NSStepper!
    @IBOutlet weak var titleLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtTitleNormalSize: NSTextField!
    @IBOutlet weak var txtTitleLargerSize: NSTextField!
    @IBOutlet weak var txtTitleLargestSize: NSTextField!
    
    @IBOutlet weak var artistAlbumNormalSizeStepper: NSStepper!
    @IBOutlet weak var artistAlbumLargerSizeStepper: NSStepper!
    @IBOutlet weak var artistAlbumLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtArtistAlbumNormalSize: NSTextField!
    @IBOutlet weak var txtArtistAlbumLargerSize: NSTextField!
    @IBOutlet weak var txtArtistAlbumLargestSize: NSTextField!
    
    @IBOutlet weak var chapterTitleNormalSizeStepper: NSStepper!
    @IBOutlet weak var chapterTitleLargerSizeStepper: NSStepper!
    @IBOutlet weak var chapterTitleLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtChapterTitleNormalSize: NSTextField!
    @IBOutlet weak var txtChapterTitleLargerSize: NSTextField!
    @IBOutlet weak var txtChapterTitleLargestSize: NSTextField!
    
    @IBOutlet weak var seekPositionNormalSizeStepper: NSStepper!
    @IBOutlet weak var seekPositionLargerSizeStepper: NSStepper!
    @IBOutlet weak var seekPositionLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtSeekPositionNormalSize: NSTextField!
    @IBOutlet weak var txtSeekPositionLargerSize: NSTextField!
    @IBOutlet weak var txtSeekPositionLargestSize: NSTextField!
    
    @IBOutlet weak var feedbackTextNormalSizeStepper: NSStepper!
    @IBOutlet weak var feedbackTextLargerSizeStepper: NSStepper!
    @IBOutlet weak var feedbackTextLargestSizeStepper: NSStepper!
    
    @IBOutlet weak var txtFeedbackTextNormalSize: NSTextField!
    @IBOutlet weak var txtFeedbackTextLargerSize: NSTextField!
    @IBOutlet weak var txtFeedbackTextLargestSize: NSTextField!
    
    override var nibName: NSNib.Name? {return "PlayerFontSet"}
    
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
        
        titleNormalSizeStepper.floatValue = Float(fontSet.player.infoBoxTitleFont_normal.pointSize * 10)
        txtTitleNormalSize.stringValue = String(format: "%.1f", titleNormalSizeStepper.floatValue / 10.0)
        
        titleLargerSizeStepper.floatValue = Float(fontSet.player.infoBoxTitleFont_larger.pointSize * 10)
        txtTitleLargerSize.stringValue = String(format: "%.1f", titleLargerSizeStepper.floatValue / 10.0)
        
        titleLargestSizeStepper.floatValue = Float(fontSet.player.infoBoxTitleFont_largest.pointSize * 10)
        txtTitleLargestSize.stringValue = String(format: "%.1f", titleLargestSizeStepper.floatValue / 10.0)
        
        
        artistAlbumNormalSizeStepper.floatValue = Float(fontSet.player.infoBoxArtistAlbumFont_normal.pointSize * 10)
        txtArtistAlbumNormalSize.stringValue = String(format: "%.1f", artistAlbumNormalSizeStepper.floatValue / 10.0)
        
        artistAlbumLargerSizeStepper.floatValue = Float(fontSet.player.infoBoxArtistAlbumFont_larger.pointSize * 10)
        txtArtistAlbumLargerSize.stringValue = String(format: "%.1f", artistAlbumLargerSizeStepper.floatValue / 10.0)
        
        artistAlbumLargerSizeStepper.floatValue = Float(fontSet.player.infoBoxArtistAlbumFont_largest.pointSize * 10)
        txtArtistAlbumLargerSize.stringValue = String(format: "%.1f", artistAlbumNormalSizeStepper.floatValue / 10.0)
        
        
        chapterTitleNormalSizeStepper.floatValue = Float(fontSet.player.infoBoxChapterTitleFont_normal.pointSize * 10)
        txtChapterTitleNormalSize.stringValue = String(format: "%.1f", chapterTitleNormalSizeStepper.floatValue / 10.0)
        
        chapterTitleLargerSizeStepper.floatValue = Float(fontSet.player.infoBoxChapterTitleFont_larger.pointSize * 10)
        txtChapterTitleLargerSize.stringValue = String(format: "%.1f", chapterTitleLargerSizeStepper.floatValue / 10.0)
        
        chapterTitleLargestSizeStepper.floatValue = Float(fontSet.player.infoBoxChapterTitleFont_largest.pointSize * 10)
        txtChapterTitleLargestSize.stringValue = String(format: "%.1f", chapterTitleLargestSizeStepper.floatValue / 10.0)
        
        
        seekPositionNormalSizeStepper.floatValue = Float(fontSet.player.trackTimesFont_normal.pointSize * 10)
        txtSeekPositionNormalSize.stringValue = String(format: "%.1f", seekPositionNormalSizeStepper.floatValue / 10.0)
        
        seekPositionLargerSizeStepper.floatValue = Float(fontSet.player.trackTimesFont_larger.pointSize * 10)
        txtSeekPositionLargerSize.stringValue = String(format: "%.1f", seekPositionLargerSizeStepper.floatValue / 10.0)
        
        seekPositionLargestSizeStepper.floatValue = Float(fontSet.player.trackTimesFont_largest.pointSize * 10)
        txtSeekPositionLargestSize.stringValue = String(format: "%.1f", seekPositionLargestSizeStepper.floatValue / 10.0)
        
        
        feedbackTextNormalSizeStepper.floatValue = Float(fontSet.player.feedbackFont_normal.pointSize * 10)
        txtFeedbackTextNormalSize.stringValue = String(format: "%.1f", feedbackTextNormalSizeStepper.floatValue / 10.0)
        
        feedbackTextLargerSizeStepper.floatValue = Float(fontSet.player.feedbackFont_larger.pointSize * 10)
        txtFeedbackTextLargerSize.stringValue = String(format: "%.1f", feedbackTextLargerSizeStepper.floatValue / 10.0)
        
        feedbackTextLargestSizeStepper.floatValue = Float(fontSet.player.feedbackFont_largest.pointSize * 10)
        txtFeedbackTextLargestSize.stringValue = String(format: "%.1f", feedbackTextLargestSizeStepper.floatValue / 10.0)
    }
    
    @IBAction func titleNormalSizeStepperAction(_ sender: NSStepper) {
        txtTitleNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func titleLargerSizeStepperAction(_ sender: NSStepper) {
        txtTitleLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func titleLargestSizeStepperAction(_ sender: NSStepper) {
        txtTitleLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    
    
    @IBAction func artistAlbumNormalSizeStepperAction(_ sender: NSStepper) {
        txtArtistAlbumNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func artistAlbumLargerSizeStepperAction(_ sender: NSStepper) {
        txtArtistAlbumLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func artistAlbumLargestSizeStepperAction(_ sender: NSStepper) {
        txtArtistAlbumLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    
    
    @IBAction func chapterTitleNormalSizeStepperAction(_ sender: NSStepper) {
        txtChapterTitleNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func chapterTitleLargerSizeStepperAction(_ sender: NSStepper) {
        txtChapterTitleLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func chapterTitleLargestSizeStepperAction(_ sender: NSStepper) {
        txtChapterTitleLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    
    
    @IBAction func seekPositionNormalSizeStepperAction(_ sender: NSStepper) {
        txtSeekPositionNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func seekPositionLargerSizeStepperAction(_ sender: NSStepper) {
        txtSeekPositionLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func seekPositionLargestSizeStepperAction(_ sender: NSStepper) {
        txtSeekPositionLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    
    
    @IBAction func feedbackTextNormalSizeStepperAction(_ sender: NSStepper) {
        txtFeedbackTextNormalSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func feedbackTextLargerSizeStepperAction(_ sender: NSStepper) {
        txtFeedbackTextLargerSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func feedbackTextLargestSizeStepperAction(_ sender: NSStepper) {
        txtFeedbackTextLargestSize.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    func applyFontSet(_ context: FontSetChangeContext, to fontSet: FontSet) {
        
        let textFontName = context.textFontName
        
        fontSet.player.infoBoxTitleFont_normal = NSFont(name: textFontName, size: CGFloat(titleNormalSizeStepper.floatValue / 10.0))!
        fontSet.player.infoBoxTitleFont_larger = NSFont(name: textFontName, size: CGFloat(titleLargerSizeStepper.floatValue / 10.0))!
        fontSet.player.infoBoxTitleFont_largest = NSFont(name: textFontName, size: CGFloat(titleLargestSizeStepper.floatValue / 10.0))!
        
        fontSet.player.infoBoxArtistAlbumFont_normal = NSFont(name: textFontName, size: CGFloat(artistAlbumNormalSizeStepper.floatValue / 10.0))!
        fontSet.player.infoBoxArtistAlbumFont_larger = NSFont(name: textFontName, size: CGFloat(artistAlbumLargerSizeStepper.floatValue / 10.0))!
        fontSet.player.infoBoxArtistAlbumFont_largest = NSFont(name: textFontName, size: CGFloat(artistAlbumLargestSizeStepper.floatValue / 10.0))!
        
        fontSet.player.infoBoxChapterTitleFont_normal = NSFont(name: textFontName, size: CGFloat(chapterTitleNormalSizeStepper.floatValue / 10.0))!
        fontSet.player.infoBoxChapterTitleFont_larger = NSFont(name: textFontName, size: CGFloat(chapterTitleLargerSizeStepper.floatValue / 10.0))!
        fontSet.player.infoBoxChapterTitleFont_largest = NSFont(name: textFontName, size: CGFloat(chapterTitleLargestSizeStepper.floatValue / 10.0))!
        
        fontSet.player.trackTimesFont_normal = NSFont(name: textFontName, size: CGFloat(seekPositionNormalSizeStepper.floatValue / 10.0))!
        fontSet.player.trackTimesFont_larger = NSFont(name: textFontName, size: CGFloat(seekPositionLargerSizeStepper.floatValue / 10.0))!
        fontSet.player.trackTimesFont_largest = NSFont(name: textFontName, size: CGFloat(seekPositionLargestSizeStepper.floatValue / 10.0))!
        
        fontSet.player.feedbackFont_normal = NSFont(name: textFontName, size: CGFloat(feedbackTextNormalSizeStepper.floatValue / 10.0))!
        fontSet.player.feedbackFont_larger = NSFont(name: textFontName, size: CGFloat(feedbackTextLargerSizeStepper.floatValue / 10.0))!
        fontSet.player.feedbackFont_largest = NSFont(name: textFontName, size: CGFloat(feedbackTextLargestSizeStepper.floatValue / 10.0))!
    }
}
