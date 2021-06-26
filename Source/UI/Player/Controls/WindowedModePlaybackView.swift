//
//  WindowedModePlaybackView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class WindowedModePlaybackView: PlaybackView, ColorSchemeable {
    
    private let fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
    override var offStateTintFunction: TintFunction {{Colors.toggleButtonOffStateColor}}

    // When the buttons are in an "On" state, they should be tinted according to the system color scheme's function button color.
    override var onStateTintFunction: TintFunction {{Colors.functionButtonColor}}
    
    private var functionButtons: [Tintable] = []
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        applyTheme()
        
        functionButtons = [btnLoop, btnPlayPause, btnPreviousTrack, btnNextTrack, btnSeekBackward, btnSeekForward]
    }
    
    func applyTheme() {
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        (sliderView as? WindowedModeSeekSliderView)?.applyFontScheme(fontScheme)
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        // This call will also take care of toggle buttons
        changeFunctionButtonColor(scheme.general.functionButtonColor)
        (sliderView as? WindowedModeSeekSliderView)?.applyColorScheme(scheme)
    }
    
    func changeSliderColors() {
        (sliderView as? WindowedModeSeekSliderView)?.changeSliderColors()
    }
    
    func changeSliderValueTextColor(_ color: NSColor) {
        (sliderView as? WindowedModeSeekSliderView)?.changeSliderValueTextColor(color)
    }
    
    func changeFunctionButtonColor(_ color: NSColor) {
        functionButtons.forEach {$0.reTint()}
    }
    
    func changeToggleButtonOffStateColor(_ color: NSColor) {
        
        // Only these buttons have off states that look different from their on states
        btnLoop.reTint()
    }
    
    // Positions the "seek position marker" view at the center of the seek slider knob.
    func positionSeekPositionMarkerView() {
        (sliderView as? WindowedModeSeekSliderView)?.positionSeekPositionMarkerView()
    }
    
    var seekPositionMarker: NSView! {(sliderView as? WindowedModeSeekSliderView)?.seekPositionMarker}
}
