//
//  RangeSlider.swift
//  RangeSlider
//
//  Created by Matt Reagan on 10/29/16.
//  Copyright © 2016 Matt Reagan.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
//  modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import Cocoa

let verticalGradientDegrees: CGFloat = -90.0
let verticalShadowPadding: CGFloat = 4.0
let barTrailingMargin: CGFloat = 1.0
let disabledControlDimmingRatio: CGFloat = 0.65

struct SelectionRange {
    var start: Double
    var end: Double
}

enum DraggedSlider {
    case start
    case end
}

enum RangeSliderColorStyle {
    case yellow
    case aqua
}

enum RangeSliderKnobStyle {
    case square
    case circular
}

@IBDesignable
class RangeSlider: NSView {
    
    //****************************************************************************//
    //****************************************************************************//
    /*
     RangeSlider is a general-purpose macOS control which is similar to NSSlider
     except that it allows for the selection of a span or range (it has two control
     points, a start and end, which can both be adjusted).
     */
    //****************************************************************************//
    //****************************************************************************//
    
    //MARK: - Public API -
    
    /** Whether the control is enabled. By default, if set to false, the control will
     render itself dimmed and ignores user interaction. */
    var enabled: Bool = true {
        didSet {
            recreateBarFillGradient()
            setNeedsDisplay(bounds)
        }
    }
    
    /** Optional action block, called when the control's start or end values change. */
    var onControlChanged : ((RangeSlider) -> Void)?
    
    /** The start of the selected span in the slider. */
    var start: Double {
        get {
            return (selection.start * (maxValue - minValue)) + minValue
        }
        
        set {
            let fractionalStart = (newValue - minValue) / (maxValue - minValue)
            selection = SelectionRange(start: fractionalStart, end: selection.end)
            setNeedsDisplay(bounds)
        }
    }
    
    /** The end of the selected span in the slider. */
    var end: Double {
        get {
            return (selection.end * (maxValue - minValue)) + minValue
        }
        
        set {
            let fractionalEnd = (newValue - minValue) / (maxValue - minValue)
            selection = SelectionRange(start: selection.start, end: fractionalEnd)
            setNeedsDisplay(bounds)
        }
    }
    
    /** The length of the selected span. Note that by default
     this length is inclusive when snapsToIntegers is true,
     which will be the expected/desired behavior in most such
     configurations. In scenarios where it may be weird to have
     a length of 1.0 when the start and end slider are at an
     identical value, you can disable this by setting
     inclusiveLengthForSnapTo to false. */
    var length: Double {
        get {
            let fractionalLength = (selection.end - selection.start)
            
            return (fractionalLength * (maxValue - minValue)) + (snapsToIntegers && inclusiveLengthForSnapTo ? 1.0 : 0.0)
        }
    }
    
    /** The minimum value of the slider. */
    var minValue: Double = 0.0 {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    /** The maximum value of the slider. */
    var maxValue: Double = 1.0 {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    /** Defaults is false (off). If set to true, the slider
     will snap to whole integer values for both sliders. */
    var snapsToIntegers: Bool = false
    
    /** Defaults to true, and makes the length property
     inclusive when snapsToIntegers is enabled. */
    var inclusiveLengthForSnapTo: Bool = true
    
    /** Defaults to true, allows clicks off of the slider knobs
     to reposition the bars. */
    var allowClicksOnBarToMoveSliders: Bool = true
    
    /** The color style of the slider. */
    var colorStyle: RangeSliderColorStyle = .yellow {
        didSet {
            recreateBarFillGradient()
            setNeedsDisplay(bounds)
        }
    }
    
    /** The shape style of the slider knobs. Defaults to square. */
    var knobStyle: RangeSliderKnobStyle = .square {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    //****************************************************************************//
    //****************************************************************************//
    
    //MARK: - Properties -
    
    private var selection: SelectionRange = SelectionRange(start: 0.0, end: 1.0) {
        willSet {
            if newValue.start != selection.start {
                self.willChangeValue(forKey: "start")
            }
            
            if newValue.end != selection.end {
                self.willChangeValue(forKey: "end")
            }
            
            if (newValue.end - newValue.start) != (selection.end - selection.start) {
                self.willChangeValue(forKey: "length")
            }
        }
        
        didSet {
            var valuesChanged: Bool = false
            
            if oldValue.start != selection.start {
                self.didChangeValue(forKey: "start")
                valuesChanged = true
            }
            
            if oldValue.end != selection.end {
                self.didChangeValue(forKey: "end")
                valuesChanged = true
            }
            
            if (oldValue.end - oldValue.start) != (selection.end - selection.start) {
                self.didChangeValue(forKey: "length")
            }
            
            if valuesChanged {
                if let block = onControlChanged {
                    block(self)
                }
            }
        }
    }
    
    private var currentSliderDragging: DraggedSlider? = nil
    
    //MARK: - Appearance -
    
    private lazy var sliderGradient: NSGradient = {
        let backgroundStart = NSColor(white: 0.92, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.80, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        assert(barBackgroundGradient != nil, "Couldn't generate gradient.")
        
        return barBackgroundGradient!
    }()
    
    private lazy var barBackgroundGradient: NSGradient = {
        let backgroundStart = NSColor(deviceRed: CGFloat(0.25), green: CGFloat(0.25), blue: CGFloat(0.25), alpha: CGFloat(1))
        let backgroundEnd =  NSColor(deviceRed: CGFloat(0.25), green: CGFloat(0.25), blue: CGFloat(0.25), alpha: CGFloat(1))
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        assert(barBackgroundGradient != nil, "Couldn't generate gradient.")
        
        return barBackgroundGradient!
    }()
    
    private var barFillGradient: NSGradient? = nil
    
    private func recreateBarFillGradient() {
        barFillGradient = createBarFillGradientBasedOnCurrentStyle()
    }
    
    private func createBarFillGradientBasedOnCurrentStyle() -> NSGradient {
        var fillStart: NSColor? = nil
        var fillEnd: NSColor? = nil
        
        if colorStyle == .yellow {
            
            fillStart = NSColor.red
            fillEnd = NSColor(deviceRed: CGFloat(0.7), green: CGFloat(0.7), blue: CGFloat(0.7), alpha: CGFloat(1))
            
        } else {
            fillStart = NSColor(red: 76/255.0, green: 187/255.0, blue: 251/255.0, alpha: 1.0)
            fillEnd = NSColor(red: 20/255.0, green: 133/255.0, blue: 243/255.0, alpha: 1.0)
        }
        
        if (!enabled) {
            fillStart = fillStart?.colorByDesaturating(disabledControlDimmingRatio).withAlphaComponent(disabledControlDimmingRatio)
            fillEnd = fillEnd?.colorByDesaturating(disabledControlDimmingRatio).withAlphaComponent(disabledControlDimmingRatio)
        }
        
        let barFillGradient = NSGradient(starting: fillStart!, ending: fillEnd!)
        assert(barFillGradient != nil, "Couldn't generate gradient.")
        
        return barFillGradient!
    }
    
    private var barStrokeColor: NSColor {
        get {
            return NSColor(white: 0.0, alpha: 0.25)
        }
    }
    
    private var barFillStrokeColor: NSColor {
        get {
            var colorForStyle: NSColor
            
            if colorStyle == .yellow {
                //                colorForStyle = NSColor(red: 1.0, green: 170/255.0, blue: 16/255.0, alpha: 0.70)
                colorForStyle = NSColor(deviceRed: CGFloat(0.7), green: CGFloat(0.7), blue: CGFloat(0.7), alpha: CGFloat(1))
            } else {
                colorForStyle = NSColor(red: 12/255.0, green: 118/255.0, blue: 227/255.0, alpha: 0.70)
            }
            
            if (!enabled) {
                colorForStyle = colorForStyle.colorByDesaturating(disabledControlDimmingRatio)
            }
            
            return colorForStyle
        }
    }
    
    private var _sliderShadow: NSShadow? = nil
    private func sliderShadow() -> NSShadow? {
        if (_sliderShadow == nil) {
            let shadowOffset = NSMakeSize(2.0, -2.0)
            let shadowBlurRadius: CGFloat = 2.0
            let shadowColor = NSColor(white: 0.0, alpha: 0.12)
            
            let shadow = NSShadow()
            shadow.shadowOffset = shadowOffset
            shadow.shadowBlurRadius = shadowBlurRadius
            shadow.shadowColor = shadowColor
            
            _sliderShadow = shadow
        }
        
        return _sliderShadow
    }
    
    //MARK: - UI Sizing -
    
    private var sliderWidth: CGFloat {
        get {
            if knobStyle == .square {
                //                return 8.0
                return 12
            } else {
                return NSHeight(bounds) - verticalShadowPadding
            }
        }
    }
    
    private var sliderHeight: CGFloat {
        get {
            //            return NSHeight(bounds) - verticalShadowPadding
            return 8
        }
    }
    
    private var minSliderX: CGFloat {
        get {
            return 0.0
        }
    }
    
    private var maxSliderX: CGFloat {
        get {
            return NSWidth(bounds) - sliderWidth - barTrailingMargin
        }
    }
    
    //MARK: - Event -
    
    override func mouseDown(with event: NSEvent) {
        if (enabled) {
            let point = convert(event.locationInWindow, from: nil)
            let startSlider = frameForStartSlider()
            let endSlider = frameForEndSlider()
            
            if NSPointInRect(point, startSlider) {
                currentSliderDragging = .start
            } else if NSPointInRect(point, endSlider) {
                currentSliderDragging = .end
            } else {
                if allowClicksOnBarToMoveSliders {
                    let startDist = abs(NSMidX(startSlider) - point.x)
                    let endDist = abs(NSMidX(endSlider) - point.x)
                    
                    if (startDist < endDist) {
                        currentSliderDragging = .start
                    } else {
                        currentSliderDragging = .end
                    }
                    
                    updateForClick(atPoint: point)
                } else {
                    currentSliderDragging = nil
                }
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        if (enabled) {
            let point = convert(event.locationInWindow, from: nil)
            updateForClick(atPoint: point)
        }
    }
    
    private func updateForClick(atPoint point: NSPoint) {
        if currentSliderDragging != nil {
            var x = Double(point.x / NSWidth(bounds))
            x = max(min(1.0, x), 0.0)
            
            if snapsToIntegers {
                let steps = maxValue - minValue
                x = round(x * steps) / steps
            }
            
            if currentSliderDragging! == .start {
                selection = SelectionRange(start: x, end: max(selection.end, x))
            } else {
                selection = SelectionRange(start: min(selection.start, x), end: x)
            }
            
            setNeedsDisplay(bounds)
        }
    }
    
    //MARK: - Utility -
    
    private func crispLineRect(_ rect: NSRect) -> NSRect {
        /*  Floor the rect values here, rather than use NSIntegralRect etc. */
        var newRect = NSMakeRect(floor(rect.origin.x),
                                 floor(rect.origin.y),
                                 floor(rect.size.width),
                                 floor(rect.size.height))
        newRect.origin.x += 0.5
        newRect.origin.y += 0.5
        
        return newRect
    }
    
    private func frameForStartSlider() -> NSRect {
        var x = max(CGFloat(selection.start) * NSWidth(bounds) - (sliderWidth / 2.0), minSliderX)
        x = min(x, maxSliderX)
        
        return crispLineRect(NSMakeRect(x, (NSHeight(bounds) - sliderHeight) / 2.0, sliderWidth, sliderHeight))
    }
    
    private func frameForEndSlider() -> NSRect {
        let width = NSWidth(bounds)
        var x = CGFloat(selection.end) * width
        x -= (sliderWidth / 2.0)
        x = min(x, maxSliderX)
        x = max(x, minSliderX)
        
        return crispLineRect(NSMakeRect(x, (NSHeight(bounds) - sliderHeight) / 2.0, sliderWidth, sliderHeight))
    }
    
    //MARK: - Layout
    
    override func layout() {
        super.layout()
        
        assert(NSWidth(bounds) >= (NSHeight(bounds) * 2), "Range control expects a reasonable width to height ratio, width should be greater than twice the height at least.");
        assert(NSWidth(bounds) >= (sliderWidth * 2.0), "Width must be able to accommodate two range sliders.")
        assert(NSHeight(bounds) >= sliderHeight, "Expects minimum height of at least \(sliderHeight)")
    }
    
    //MARK: - Drawing -
    
    override func draw(_ dirtyRect: NSRect) {
        
        /*  Setup, calculations */
        let width = NSWidth(bounds) - barTrailingMargin
        let height = NSHeight(bounds)
        
        let barHeight: CGFloat = 3
        let barY = floor((height - barHeight) / 2.0)
        
        let startSliderFrame = frameForStartSlider()
        let endSliderFrame = frameForEndSlider()
        
        let barRect = crispLineRect(NSMakeRect(0, barY, width, barHeight))
        let selectedRect = crispLineRect(NSMakeRect(CGFloat(selection.start) * width, barY,
                                                    width * CGFloat(selection.end - selection.start), barHeight))
        let radius = barHeight / 3.0;
        let isSquareSlider = (knobStyle == .square)
        
        /*  Create bezier paths */
        let framePath = NSBezierPath(roundedRect: barRect, xRadius: radius, yRadius: radius)
        let selectedPath = NSBezierPath(roundedRect: selectedRect, xRadius: radius, yRadius: radius)
        
        let startSliderPath = isSquareSlider ? NSBezierPath(roundedRect: startSliderFrame, xRadius: 2.0, yRadius: 2.0) : NSBezierPath(ovalIn: startSliderFrame)
        let endSliderPath = isSquareSlider ? NSBezierPath(roundedRect: endSliderFrame, xRadius: 2.0, yRadius: 2.0) : NSBezierPath(ovalIn: endSliderFrame)
        
        /*  Draw bar background */
        barBackgroundGradient.draw(in: framePath, angle: -verticalGradientDegrees)
        
        /*  Draw bar fill */
        if NSWidth(selectedRect) > 0.0 {
            if barFillGradient == nil {
                barFillGradient = createBarFillGradientBasedOnCurrentStyle()
            }
            
            if let fillGradient = barFillGradient {
                fillGradient.draw(in: selectedPath, angle: verticalGradientDegrees)
                barFillStrokeColor.setStroke()
                //                selectedPath.stroke()
            }
        }
        
        barStrokeColor.setStroke()
        framePath.stroke()
        
        /*  Draw slider shadows */
        if let shadow = sliderShadow() {
            NSGraphicsContext.saveGraphicsState()
            shadow.set()
            
            NSColor.white.set()
            startSliderPath.fill()
            endSliderPath.fill()
            NSGraphicsContext.restoreGraphicsState()
        }
        
        /*  Draw slider knobs */
        sliderGradient.draw(in: endSliderPath, angle: verticalGradientDegrees)
        endSliderPath.stroke()
        
        sliderGradient.draw(in: startSliderPath, angle: verticalGradientDegrees)
        startSliderPath.stroke()
        
        let knobColor = NSColor(deviceRed: CGFloat(0.3), green: CGFloat(0.3), blue: CGFloat(0.3), alpha: CGFloat(1))
        knobColor.setFill()
        
        startSliderPath.fill()
        endSliderPath.fill()
    }
}


extension NSColor {
    func colorByDesaturating(_ desaturationRatio: CGFloat) -> NSColor {
        return NSColor(hue: self.hueComponent,
                       saturation: self.saturationComponent * desaturationRatio,
                       brightness: self.brightnessComponent,
                       alpha: self.alphaComponent);
    }
}
