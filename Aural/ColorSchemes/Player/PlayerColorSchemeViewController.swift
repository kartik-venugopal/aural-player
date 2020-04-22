import Cocoa

class PlayerColorSchemeViewController: NSViewController, ColorSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var trackInfoPrimaryTextColorPicker: NSColorWell!
    @IBOutlet weak var trackInfoSecondaryTextColorPicker: NSColorWell!
    @IBOutlet weak var trackInfoTertiaryTextColorPicker: NSColorWell!
    
    @IBOutlet weak var controlTextColorPicker: NSColorWell!
    
    @IBOutlet weak var sliderBackgroundColorPicker: NSColorWell!
    @IBOutlet weak var sliderForegroundColorPicker: NSColorWell!
    @IBOutlet weak var sliderKnobColorPicker: NSColorWell!
    @IBOutlet weak var sliderLoopSegmentColorPicker: NSColorWell!
    
    override var nibName: NSNib.Name? {return "PlayerColorScheme"}
    
    @IBAction func primaryTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.trackInfoPrimaryTextColor = trackInfoPrimaryTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerTrackInfoPrimaryTextColor, trackInfoPrimaryTextColorPicker.color))
    }
    
    @IBAction func secondaryTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.trackInfoSecondaryTextColor = trackInfoSecondaryTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerTrackInfoSecondaryTextColor, trackInfoSecondaryTextColorPicker.color))
    }
    
    @IBAction func tertiaryTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.trackInfoTertiaryTextColor = trackInfoTertiaryTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerTrackInfoTertiaryTextColor, trackInfoTertiaryTextColorPicker.color))
    }
    
    @IBAction func controlTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.controlTextColor = controlTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerControlTextColor, controlTextColorPicker.color))
    }
    
    @IBAction func sliderBackgroundColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.sliderBackgroundColor = sliderBackgroundColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderBackgroundColor, sliderBackgroundColorPicker.color))
    }
    
    @IBAction func sliderForegroundColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.sliderForegroundColor = sliderForegroundColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderForegroundColor, sliderForegroundColorPicker.color))
    }
    
    @IBAction func sliderKnobColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.sliderKnobColor = sliderKnobColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderKnobColor, sliderKnobColorPicker.color))
    }
    
    @IBAction func sliderLoopSegmentColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.sliderLoopSegmentColor = sliderLoopSegmentColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderLoopSegmentColor, sliderLoopSegmentColorPicker.color))
    }
    
    var colorSchemeView: NSView {
        return self.view
    }
    
    func resetFields(_ scheme: ColorScheme) {
        
        trackInfoPrimaryTextColorPicker.color = scheme.player.trackInfoPrimaryTextColor
        trackInfoSecondaryTextColorPicker.color = scheme.player.trackInfoSecondaryTextColor
        trackInfoTertiaryTextColorPicker.color = scheme.player.trackInfoTertiaryTextColor
        
        controlTextColorPicker.color = scheme.player.controlTextColor
        
        sliderBackgroundColorPicker.color = scheme.player.sliderBackgroundColor
        sliderForegroundColorPicker.color = scheme.player.sliderForegroundColor
        sliderKnobColorPicker.color = scheme.player.sliderKnobColor
        sliderLoopSegmentColorPicker.color = scheme.player.sliderLoopSegmentColor
        
        scrollToTop()
    }
    
    private func scrollToTop() {
        
        let contentView: NSClipView = scrollView.contentView
        contentView.scroll(NSMakePoint(0, contentView.documentView!.frame.height))
    }
}
