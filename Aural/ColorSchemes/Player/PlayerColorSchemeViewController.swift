import Cocoa

class PlayerColorSchemeViewController: NSViewController, ColorSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var trackInfoPrimaryTextColorPicker: NSColorWell!
    @IBOutlet weak var trackInfoSecondaryTextColorPicker: NSColorWell!
    @IBOutlet weak var trackInfoTertiaryTextColorPicker: NSColorWell!
    
    @IBOutlet weak var sliderValueTextColorPicker: NSColorWell!
    
    @IBOutlet weak var sliderBackgroundColorPicker: NSColorWell!
    
    @IBOutlet weak var sliderForegroundColorPicker: NSColorWell!
    @IBOutlet weak var btnSliderForegroundGradientEnabled: NSButton!
    @IBOutlet weak var btnSliderForegroundGradientDarken: NSButton!
    @IBOutlet weak var btnSliderForegroundGradientBrighten: NSButton!
    @IBOutlet weak var sliderForegroundGradientAmountStepper: NSStepper!
    @IBOutlet weak var lblSliderForegroundGradientAmount: NSTextField!
    
    @IBOutlet weak var sliderKnobColorPicker: NSColorWell!
    @IBOutlet weak var btnSliderKnobColorSameAsForeground: NSButton!
    @IBOutlet weak var sliderLoopSegmentColorPicker: NSColorWell!
    
    override var nibName: NSNib.Name? {return "PlayerColorScheme"}
    
    var colorSchemeView: NSView {
        return self.view
    }
    
    func resetFields(_ scheme: ColorScheme) {
        
        trackInfoPrimaryTextColorPicker.color = scheme.player.trackInfoPrimaryTextColor
        trackInfoSecondaryTextColorPicker.color = scheme.player.trackInfoSecondaryTextColor
        trackInfoTertiaryTextColorPicker.color = scheme.player.trackInfoTertiaryTextColor
        
        sliderValueTextColorPicker.color = scheme.player.sliderValueTextColor
        
        sliderBackgroundColorPicker.color = scheme.player.sliderBackgroundColor
        
        sliderForegroundColorPicker.color = scheme.player.sliderForegroundColor
        
        btnSliderForegroundGradientEnabled.onIf(scheme.player.sliderForegroundGradientType != .none)
        
        btnSliderForegroundGradientDarken.enableIf(btnSliderForegroundGradientEnabled.isOn)
        btnSliderForegroundGradientDarken.onIf(scheme.player.sliderForegroundGradientType != .brighten)
        
        btnSliderForegroundGradientBrighten.enableIf(btnSliderForegroundGradientEnabled.isOn)
        btnSliderForegroundGradientBrighten.onIf(scheme.player.sliderForegroundGradientType == .brighten)
        
        sliderForegroundGradientAmountStepper.enableIf(btnSliderForegroundGradientEnabled.isOn)
        sliderForegroundGradientAmountStepper.integerValue = ColorSchemes.systemScheme.player.sliderForegroundGradientAmount
        lblSliderForegroundGradientAmount.stringValue = String(format: "%d%%", sliderForegroundGradientAmountStepper.integerValue)
        
        sliderKnobColorPicker.color = scheme.player.sliderKnobColor
        btnSliderKnobColorSameAsForeground.onIf(scheme.player.sliderKnobColorSameAsForeground)
        sliderLoopSegmentColorPicker.color = scheme.player.sliderLoopSegmentColor
        
        scrollToTop()
    }
    
    private func scrollToTop() {
        
        let contentView: NSClipView = scrollView.contentView
        contentView.scroll(NSMakePoint(0, contentView.documentView!.frame.height))
    }
    
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
    
    @IBAction func sliderValueTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.sliderValueTextColor = sliderValueTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderValueTextColor, sliderValueTextColorPicker.color))
    }
    
    @IBAction func sliderBackgroundColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.sliderBackgroundColor = sliderBackgroundColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderBackgroundColor, sliderBackgroundColorPicker.color))
    }
    
    @IBAction func sliderForegroundColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.sliderForegroundColor = sliderForegroundColorPicker.color
        sliderForegroundChanged()
    }
    
    @IBAction func enableSliderForegroundGradientAction(_ sender: Any) {
        
        if btnSliderForegroundGradientEnabled.isOn {
            ColorSchemes.systemScheme.player.sliderForegroundGradientType = btnSliderForegroundGradientDarken.isOn ? .darken : .brighten
        } else {
            ColorSchemes.systemScheme.player.sliderForegroundGradientType = .none
        }
        
        [btnSliderForegroundGradientDarken, btnSliderForegroundGradientBrighten, sliderForegroundGradientAmountStepper].forEach({$0?.enableIf(btnSliderForegroundGradientEnabled.isOn)})
        
        sliderForegroundChanged()
    }
    
    @IBAction func sliderForegroundGradientBrightenOrDarkenAction(_ sender: Any) {
        
//        print(btnSliderForegroundGradientDarken.isOn ? "Darkening by" : "Brightening by", lblSliderForegroundGradientAmount.stringValue)
        
        ColorSchemes.systemScheme.player.sliderForegroundGradientType = btnSliderForegroundGradientDarken.isOn ? .darken : .brighten
        sliderForegroundChanged()
    }
    
    @IBAction func sliderForegroundGradientAmountAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.sliderForegroundGradientAmount = sliderForegroundGradientAmountStepper.integerValue
        lblSliderForegroundGradientAmount.stringValue = String(format: "%d%%", sliderForegroundGradientAmountStepper.integerValue)
        
        sliderForegroundChanged()
    }
    
    private func sliderForegroundChanged() {
        
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderForegroundColor, sliderForegroundColorPicker.color))
    }
    
    @IBAction func sliderKnobColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.sliderKnobColor = sliderKnobColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderKnobColor, sliderKnobColorPicker.color))
    }
    
    @IBAction func sliderKnobColorSameAsForegroundAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.sliderKnobColorSameAsForeground = btnSliderKnobColorSameAsForeground.isOn
        
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderKnobColor, btnSliderKnobColorSameAsForeground.isOn ? sliderForegroundColorPicker.color : sliderKnobColorPicker.color))
    }
    
    @IBAction func sliderLoopSegmentColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.sliderLoopSegmentColor = sliderLoopSegmentColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderLoopSegmentColor, sliderLoopSegmentColorPicker.color))
    }
}
