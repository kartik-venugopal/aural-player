import Cocoa

class PlayerFontSetViewController: NSViewController, FontSetsViewProtocol {
    
    @IBOutlet weak var titleStepper: NSStepper!
    @IBOutlet weak var txtTitle: NSTextField!
    
    @IBOutlet weak var artistAlbumStepper: NSStepper!
    @IBOutlet weak var txtArtistAlbum: NSTextField!
    
    @IBOutlet weak var chapterTitleStepper: NSStepper!
    @IBOutlet weak var txtChapterTitle: NSTextField!
    
    @IBOutlet weak var seekPositionStepper: NSStepper!
    @IBOutlet weak var txtSeekPosition: NSTextField!
    
    @IBOutlet weak var feedbackTextStepper: NSStepper!
    @IBOutlet weak var txtFeedbackText: NSTextField!
    
    override var nibName: NSNib.Name? {return "PlayerFontSet"}
    
    var fontSetsView: NSView {
        self.view
    }
    
    func resetFields(_ fontSet: FontSet) {
        
        titleStepper.floatValue = Float(fontSet.player.infoBoxTitleFont.pointSize * 10)
        txtTitle.stringValue = String(format: "%.1f", titleStepper.floatValue / 10.0)
        
        artistAlbumStepper.floatValue = Float(fontSet.player.infoBoxArtistAlbumFont.pointSize * 10)
        txtArtistAlbum.stringValue = String(format: "%.1f", artistAlbumStepper.floatValue / 10.0)
        
        chapterTitleStepper.floatValue = Float(fontSet.player.infoBoxChapterTitleFont.pointSize * 10)
        txtChapterTitle.stringValue = String(format: "%.1f", chapterTitleStepper.floatValue / 10.0)
        
        seekPositionStepper.floatValue = Float(fontSet.player.trackTimesFont.pointSize * 10)
        txtSeekPosition.stringValue = String(format: "%.1f", seekPositionStepper.floatValue / 10.0)
        
        feedbackTextStepper.floatValue = Float(fontSet.player.feedbackFont.pointSize * 10)
        txtFeedbackText.stringValue = String(format: "%.1f", feedbackTextStepper.floatValue / 10.0)
    }
    
    @IBAction func titleStepperAction(_ sender: NSStepper) {
        txtTitle.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func artistAlbumStepperAction(_ sender: NSStepper) {
        txtArtistAlbum.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func chapterTitleStepperAction(_ sender: NSStepper) {
        txtChapterTitle.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func seekPositionStepperAction(_ sender: NSStepper) {
        txtSeekPosition.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
  
    @IBAction func feedbackTextStepperAction(_ sender: NSStepper) {
        txtFeedbackText.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    func applyFontSet(_ context: FontSetChangeContext, to fontSet: FontSet) {
        
        let textFontName = context.textFontName
        
        fontSet.player.infoBoxTitleFont = NSFont(name: textFontName, size: CGFloat(titleStepper.floatValue / 10.0))!
        fontSet.player.infoBoxArtistAlbumFont = NSFont(name: textFontName, size: CGFloat(artistAlbumStepper.floatValue / 10.0))!
        fontSet.player.infoBoxChapterTitleFont = NSFont(name: textFontName, size: CGFloat(chapterTitleStepper.floatValue / 10.0))!
        fontSet.player.trackTimesFont = NSFont(name: textFontName, size: CGFloat(seekPositionStepper.floatValue / 10.0))!
        fontSet.player.feedbackFont = NSFont(name: textFontName, size: CGFloat(feedbackTextStepper.floatValue / 10.0))!
    }
}
