//
//  RangeSlider.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
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

fileprivate let bandPassColor: NSColor = NSColor(red: 0, green: 0.45, blue: 0)
fileprivate let bypassedColor: NSColor = .white35Percent
fileprivate let suppressedColor: NSColor = NSColor(red: 0.53, green: 0.4, blue: 0)

@IBDesignable
class RangeSlider: NSControl, EffectsUnitSliderProtocol {
    
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
    
    @IBInspectable var index: Int = 0
    
    private(set) var unitState: EffectsUnitState = .bypassed {
        didSet {redraw()}
    }
    
    var stateFunction: EffectsUnitStateFunction?
    
    func updateState() {
        
        if let function = stateFunction {
            
            unitState = function()
            redraw()
        }
    }
    
    private let barTrailingMargin: CGFloat = 1.0
    
    var shouldTriggerHandler: Bool = true
    
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
            redraw()
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
            redraw()
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
    @IBInspectable var minValue: Double = 0.0 {
        didSet {
            redraw()
        }
    }
    
    /** The maximum value of the slider. */
    @IBInspectable var maxValue: Double = 1.0 {
        didSet {
            redraw()
        }
    }
    
    //****************************************************************************//
    //****************************************************************************//
    
    //MARK: - Properties -
    
    var selection: SelectionRange = SelectionRange(start: 0.0, end: 1.0) {
        
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
                if shouldTriggerHandler, let block = onControlChanged {
                    block(self)
                }
            }
        }
    }
    
    private var currentSliderDragging: DraggedSlider? = nil
    
    //MARK: - Appearance -
    
    let _barBackgroundColor: NSColor = NSColor(white: 0.2, alpha: 1.0)
    
    var barBackgroundColor: NSColor {_barBackgroundColor}
    
    private lazy var sliderGradient: NSGradient = {
        let backgroundStart = NSColor(white: 0.92, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.80, alpha: 1.0)
        let barBackgroundColor = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        assert(barBackgroundColor != nil, "Couldn't generate gradient.")
        
        return barBackgroundColor!
    }()
    
    // TODO: Change this to a computed color
    var knobColor: NSColor {.white50Percent}
    
    var barFillColor: NSColor {
        
        switch unitState {
            
        case .active:   return bandPassColor
            
        case .bypassed: return bypassedColor
            
        case .suppressed:   return suppressedColor
            
        }
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
    
    private let sliderWidth: CGFloat = 10
    private let sliderHeight: CGFloat = 5
    
    private let minSliderX: CGFloat = 0
    private var maxSliderX: CGFloat { return NSWidth(bounds) - sliderWidth - barTrailingMargin }
    
    //MARK: - Event -
    
    override func mouseDown(with event: NSEvent) {
        
        if !isEnabled {return}

        let point = convert(event.locationInWindow, from: nil)
        let startSlider = startKnobFrame()
        let endSlider = endKnobFrame()
        
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
        
        if isEnabled {
        
            let point = convert(event.locationInWindow, from: nil)
            updateForClick(atPoint: point)
        }
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
            
            redraw()
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
    
    private func startKnobFrame() -> NSRect {
        var x = max(CGFloat(selection.start) * NSWidth(bounds) - (sliderWidth / 2.0), minSliderX)
        x = min(x, maxSliderX)
        
        return crispLineRect(NSMakeRect(x, (NSHeight(bounds) - sliderHeight) / 2.0, sliderWidth, sliderHeight))
    }
    
    private func endKnobFrame() -> NSRect {
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
        
        let barHeight: CGFloat = 5
        let barY = floor((height - barHeight) / 2.0)
        
        let startSliderFrame = startKnobFrame()
        let endSliderFrame = endKnobFrame()
        
        let barRect = crispLineRect(NSMakeRect(0, barY, width, barHeight))
        let selectedRect = crispLineRect(NSMakeRect(CGFloat(selection.start) * width, barY,
                                                    width * CGFloat(selection.end - selection.start), barHeight))
        
        /*  Create bezier paths */
        let framePath = NSBezierPath(roundedRect: barRect, xRadius: 1.5, yRadius: 1.5)
        let selectedPath = NSBezierPath(roundedRect: selectedRect, xRadius: 1.5, yRadius: 1.5)
        
        let startSliderPath = NSBezierPath(rect: startSliderFrame)
        let endSliderPath = NSBezierPath(rect: endSliderFrame)
        framePath.fill(withColor: barBackgroundColor)
        
        /*  Draw bar fill */
        if NSWidth(selectedRect) > 0.0 {

            selectedPath.fill(withColor: barFillColor)
            barFillStrokeColor.setStroke()
        }
        
        framePath.stroke(withColor: barStrokeColor)
        
        /*  Draw slider shadows */
        if let shadow = sliderShadow() {
            
            NSGraphicsContext.saveGraphicsState()
            shadow.set()

            startSliderPath.fill(withColor: .black)
            endSliderPath.fill(withColor: .black)
            
            NSGraphicsContext.restoreGraphicsState()
        }
        
        /*  Draw slider knobs */
        sliderGradient.draw(in: endSliderPath, angle: .horizontalGradientDegrees)
        endSliderPath.stroke()
        
        sliderGradient.draw(in: startSliderPath, angle: .horizontalGradientDegrees)
        startSliderPath.stroke()
        
        startSliderPath.fill(withColor: knobColor)
        endSliderPath.fill(withColor: knobColor)
    }
}

