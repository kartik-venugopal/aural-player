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

struct SelectionRange {
    var start: Double
    var end: Double
}

enum DraggedSlider {
    case start
    case end
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
    
    private let verticalShadowPadding: CGFloat = 4.0
    private let barTrailingMargin: CGFloat = 1.0
    private let disabledControlDimmingRatio: CGFloat = 0.65
    
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
            
            return (fractionalLength * (maxValue - minValue))
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
    
    private lazy var barBackgroundGradient: NSGradient = Colors.sliderBarGradient
    
    private lazy var sliderGradient: NSGradient = {
        let backgroundStart = NSColor(white: 0.92, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.80, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        assert(barBackgroundGradient != nil, "Couldn't generate gradient.")
        
        return barBackgroundGradient!
    }()

    private var barFillGradient: NSGradient {
        
//        let fillStart: NSColor = NSColor.red
//        let fillEnd: NSColor = NSColor(deviceRed: CGFloat(0.5), green: CGFloat(0), blue: CGFloat(0), alpha: CGFloat(1))
//        
//        let barFillGradient = NSGradient(starting: fillStart, ending: fillEnd)
//        assert(barFillGradient != nil, "Couldn't generate gradient.")
//        
//        return barFillGradient!
        return Colors.sliderBarColoredGradient
    }
    
    func initialize(_ min: Double, _ max: Double, _ start: Double, _ end: Double, _ changeHandler: ((RangeSlider) -> Void)?) {
        self.minValue = min
        self.maxValue = max
        self.start = start
        self.end = end
        self.onControlChanged = changeHandler
    }
    
    private let barStrokeColor: NSColor = NSColor(white: 0.0, alpha: 0.25)
    
    private var barFillStrokeColor: NSColor = NSColor(deviceRed: CGFloat(0.7), green: CGFloat(0.7), blue: CGFloat(0.7), alpha: CGFloat(1))
    
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
    
    private let sliderWidth: CGFloat = 8
    private let sliderHeight: CGFloat = 4.5
    
    private let minSliderX: CGFloat = 0
    private var maxSliderX: CGFloat { return NSWidth(bounds) - sliderWidth - barTrailingMargin }
    
    //MARK: - Event -
    
    override func mouseDown(with event: NSEvent) {

        let point = convert(event.locationInWindow, from: nil)
        let startSlider = frameForStartSlider()
        let endSlider = frameForEndSlider()
        
        if NSPointInRect(point, startSlider) {
            currentSliderDragging = .start
        } else if NSPointInRect(point, endSlider) {
            currentSliderDragging = .end
        } else {
            
            let startDist = abs(NSMidX(startSlider) - point.x)
            let endDist = abs(NSMidX(endSlider) - point.x)
            
            if (startDist < endDist) {
                currentSliderDragging = .start
            } else {
                currentSliderDragging = .end
            }
            
            updateForClick(atPoint: point)
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        updateForClick(atPoint: point)
    }
    
    private func updateForClick(atPoint point: NSPoint) {
        
        if currentSliderDragging != nil {
            
            var x = Double(point.x / NSWidth(bounds))
            x = max(min(1.0, x), 0.0)
            
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
        
        let barHeight: CGFloat = 4
        let barY = floor((height - barHeight) / 2.0)
        
        let startSliderFrame = frameForStartSlider()
        let endSliderFrame = frameForEndSlider()
        
        let barRect = crispLineRect(NSMakeRect(0, barY, width, barHeight))
        let selectedRect = crispLineRect(NSMakeRect(CGFloat(selection.start) * width, barY,
                                                    width * CGFloat(selection.end - selection.start), barHeight))
        
        /*  Create bezier paths */
        let framePath = NSBezierPath(roundedRect: barRect, xRadius: 1.5, yRadius: 1.5)
        let selectedPath = NSBezierPath(roundedRect: selectedRect, xRadius: 1.5, yRadius: 1.5)
        
        let startSliderPath = NSBezierPath(rect: startSliderFrame)
        let endSliderPath = NSBezierPath(rect: endSliderFrame)
        
        /*  Draw bar background */
        barBackgroundGradient.draw(in: framePath, angle: -UIConstants.horizontalGradientDegrees)
        
        /*  Draw bar fill */
        if NSWidth(selectedRect) > 0.0 {
            barFillGradient.draw(in: selectedPath, angle: UIConstants.horizontalGradientDegrees)
            barFillStrokeColor.setStroke()
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
        sliderGradient.draw(in: endSliderPath, angle: UIConstants.horizontalGradientDegrees)
        endSliderPath.stroke()
        
        sliderGradient.draw(in: startSliderPath, angle: UIConstants.horizontalGradientDegrees)
        startSliderPath.stroke()
        
        let knobColor = Colors.sliderKnobColor
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
