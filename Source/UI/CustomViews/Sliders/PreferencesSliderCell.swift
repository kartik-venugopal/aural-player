import Cocoa

// Cell for sliders on the Preferences panel
class PreferencesSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {1.5}
    override var barInsetY: CGFloat {0.5}
    
    override var backgroundGradient: NSGradient {Colors.Effects.defaultSliderBackgroundGradient}
    override var foregroundGradient: NSGradient {Colors.Effects.defaultSliderBackgroundGradient}
    
    override var knobColor: NSColor {Colors.Constants.white80Percent}
}
