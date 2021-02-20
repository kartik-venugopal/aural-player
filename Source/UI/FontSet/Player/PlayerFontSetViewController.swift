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
}
