//
//  ProgressArc.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Cocoa
//import CoreGraphics
//import QuartzCore
//
//@IBDesignable
//class ProgressArc: NSView {
//    
//    /// Color of the background arc.
//    let backgroundArcColor: NSColor = .white15Percent
//    
//    /// Color of the background arc.
//    let foregroundArcColor: NSColor = ColorScheme.lava.activeControlColor
//    
//    /// Thickness of the background arc.
//    lazy var backgroundArcLineWidth: CGFloat = 16
//    
//    /// Thickness of the foreground arc.
//    lazy var foregroundArcLineWidth: CGFloat = 6
//    
//    /// Font to be used for rendered text.
//    let textFont: NSFont = fontSchemesManager.systemScheme.prominentFont
//    
//    /// Center of the rendered arcs.
//    lazy var arcCenter: CGPoint = CGPoint(x: bounds.centerX, y: bounds.centerY)
//    
//    @IBOutlet weak var lblPercentage: NSTextField!
//    
//    /// Radius of the rendered arcs.
//    lazy var arcRadius: CGFloat = {
//        
//        let minOfHalfWidthAndHeight = min(self.convert(bounds, to: nil).width / 2, self.convert(bounds, to: nil).height)
//        return minOfHalfWidthAndHeight - (backgroundArcLineWidth / 2)
//    }()
//    
//    var percentage: Double = 0 {
//        
//        didSet {
//            redraw()
//        }
//    }
//    
//    ///
//    /// Removes all sublayers from the root layer of this view.
//    ///
//    /// This is typically done immediately prior to a fresh view redraw
//    /// that will add fresh sublayers.
//    ///
//    func removeAllSublayers() {
//        layer?.sublayers?.removeAll()
//    }
//    
//    ///
//    /// Draws the CPU meter as a semicircular arc that is colored so as to
//    /// indicate the current level of CPU usage.
//    ///
//    override func draw(_ dirtyRect: NSRect) {
//        
//        // Clear any previously added sublayers.
//        removeAllSublayers()
//        
//        // ------------------------------------------------------------------------------------
//        
//        // Background arc
//        
//        let conv = self.convert(dirtyRect, to: nil)
//        
//        addArcLayer(havingFrame: conv, endAngle: 90.1, strokeColor: backgroundArcColor,
//                    andLineWidth: backgroundArcLineWidth)
//        
//        // ------------------------------------------------------------------------------------
//        
//        // Foreground arc
//        
//        let angleDelta = angleForPercentage(CGFloat(percentage))
//        let endAngle = 180 - angleDelta
//        addArcLayer(havingFrame: conv, endAngle: endAngle, strokeColor: foregroundArcColor,
//                    andLineWidth: foregroundArcLineWidth)
//        
//        // ------------------------------------------------------------------------------------
//        
//        // Text
//        
//        let text = "\(percentage.clamped(to: 0...100).roundedInt)%"
//        lblPercentage.stringValue = text
//        lblPercentage.font = systemFontScheme.prominentFont
//        lblPercentage.textColor = systemColorScheme.primaryTextColor
//        lblPercentage.bringToFront()
////        let textSize = text.size(withAttributes: [.font: textFont])
////        
//////        let textFrame = CGRect(x: arcCenter.x - (textSize.width / 2), y: arcCenter.y - (textSize.height / 2), width: textSize.width, height: textSize.height)
////        let textFrame = CGRect(x: dirtyRect.centerX, y: dirtyRect.centerY, width: textSize.width, height: textSize.height)
////        addTextLayer(text: text, alignment: .center, frame: textFrame)
//    }
//    
//    // --------------------------------------------------------------
//    
//    // MARK: Utility methods
//    
//    ///
//    /// Helper function to add a layer having an arc-shaped path.
//    ///
//    /// The path will be stroked according to the specified color parameter.
//    ///
//    private func addArcLayer(havingFrame frame: NSRect, endAngle: CGFloat, strokeColor: NSColor,
//                             andLineWidth lineWidth: CGFloat) {
//        
//        let arcPath = NSBezierPath()
//        arcPath.appendArc(withCenter: arcCenter, radius: arcRadius, startAngle: 90, endAngle: endAngle, clockwise: true)
//        
//        let arcLayer = CAShapeLayer()
//        arcLayer.frame = frame
//        
//        arcLayer.lineWidth = lineWidth
//        arcLayer.strokeColor = strokeColor.cgColor
//        arcLayer.fillColor = NSColor.clear.cgColor
//        
//        arcLayer.path = arcPath.cgPath
//        
//        layer?.addSublayer(arcLayer)
//    }
//    
//    ///
//    /// Helper function to add a text layer with the given text, within the given frame.
//    ///
//    /// - Parameter alignment:      Horizontal text alignment mode (left / right / center).
//    ///
//    func addTextLayer(text: String, alignment: CATextLayerAlignmentMode, frame: NSRect) {
//        
//        let textLayer = CATextLayer()
//        
//        textLayer.string = text.attributed(withFont: textFont, andColor: .white)
//        textLayer.frame = frame
//        textLayer.alignmentMode = alignment
//        textLayer.isWrapped = true
//        textLayer.contentsScale = NSScreen.main!.backingScaleFactor
//        
//        layer?.addSublayer(textLayer)
//    }
//    
//    ///
//    /// Helper function that computes an angle corresponding to the given CPU usage percentage.
//    ///
//    private func angleForPercentage(_ percentage: CGFloat) -> CGFloat {
//        90 + (percentage * 360 / 100)
//    }
//}
