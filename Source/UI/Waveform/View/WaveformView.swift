//
//  WaveformView.swift
//  Periphony: Spatial Audio Player
//  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
//  Developed by Kartik Venugopal
//

import Accelerate
import Cocoa
import os

protocol SampleReceiver {
    
    func setSamples(_ samples: [[Float]])
}

///
/// A view that renders and displays waveforms for audio files.
///
/// **Notes**
///
/// This is based on ``FDWaveformView``.
///
/// - SeeAlso:      https://github.com/fulldecent/FDWaveformView
///
class WaveformView: NSView, SampleReceiver {
    
    static let noiseFloor: CGFloat = -50
    
    var clickRecognizer: NSClickGestureRecognizer!
    
    var _audioFile: URL?
    var renderOp: WaveformRenderOperation?
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        self.wantsLayer = true
        addGestureRecognizers()
    }
    
    var samples: [[Float]] = [[],[]]
    
    func setSamples(_ samples: [[Float]]) {
        
        self.samples = samples
        
        DispatchQueue.main.async {
            self.redraw()
        }
    }
    
    var samplesProgress: CGFloat {
        CGFloat(samples[0].count) / bounds.width
    }
    
    func resetState() {
        
        samples = [[],[]]
        baseLayerComplete = false
        redraw()
    }
    
    // Between 0 and 1
    var progress: CGFloat = 0 {
        
        didSet(newValue) {
            
            if newValue < 0 {
                self.progress = 0
                
            } else if newValue > 1 {
                self.progress = 1
            }
            
            redraw()
        }
    }
    
    var baseLayerComplete: Bool = false
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        
        let samplesToDraw = self.samples
        
//        let scaleFactor: CGFloat = window?.screen?.backingScaleFactor ?? NSScreen.main!.backingScaleFactor
        let scaleFactor: CGFloat = 1
        let scaledImageSize = bounds
        
        let scaledWidth = scaledImageSize.width
        let scaledHeight = scaledImageSize.height
        
        guard !baseLayerComplete else {
            
            if let subLayers = layer?.sublayers, subLayers.count >= 2 {
                
                let mask = subLayers[1].mask
                mask?.frame = CGRect(x: 0, y: 0, width: scaledWidth * progress, height: scaledHeight)
                mask?.removeAllAnimations()
            }
            return
        }
        
        layer?.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Create and configure a CALayer to do the drawing.
        
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight)
        layer.strokeColor = systemColorScheme.inactiveControlColor.cgColor
        layer.fillColor = NSColor.clear.cgColor
        layer.lineWidth = 1.0
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Compute some parameters for the drawing.
        
        /// Number of audio channels (i.e. number of waveforms) being rendered.
        let channelCount = samplesToDraw.count
        
        /// The minimum of all sample (amplitude) values.
        let minVal: Float = -50
        
        /// The maximum of all sample (amplitude) values.
        let maxVal: Float = samplesToDraw.sampleMax
        
        /// The height of the waveform for each individual audio channel.
        let channelHeight = scaledHeight / CGFloat(channelCount)
        
        /// Half of ``channelHeight``.
        let halfChannelHeight = channelHeight / 2
        
        /// A factor / multiplier for the height of each sample.
        let sampleDrawingScale: CGFloat
        
        if maxVal == minVal {
            sampleDrawingScale = 0
        } else {
            sampleDrawingScale = (channelHeight * scaleFactor) / 2 / CGFloat(maxVal - minVal)
        }
        
        /// This bezier path will contain all our data points (lines).
        let path = NSBezierPath()
        
        let samplesDrawn = samplesToDraw[0].count

        // ------------------------------------------------------------------------------------------
        
        // MARK: Iterate through all the audio channels.
        
        for (index, channelSamples) in samplesToDraw.enumerated() {
            
            // ------------------------------------------------------------------------------------------
            
            // MARK: Draw a zero amplitude line across the vertical center of the waveform.

            /// The halfway point along the Y axis.
            let verticalMiddle = (CGFloat(channelCount - index - 1) * channelHeight + halfChannelHeight) * scaleFactor
            
            // Draw 3 lines, to prevent the zero amplitude indicator from disappearing.
            
            let lineEndX = scaledWidth * scaleFactor
            
            path.line(from: (x: 0, y: verticalMiddle), to: (x: lineEndX, y: verticalMiddle))
            
            // ------------------------------------------------------------------------------------------
            
            // MARK: Draw the samples.
            
            for (x, sample) in channelSamples.enumerated() {
                
                let height = CGFloat(CGFloat(sample - minVal) * sampleDrawingScale)
                let x_CGFloat = CGFloat(x)
                
                if height.isZero || height.isNaN {
                    
                    print("WTF!")
                    continue
                }
                
                // TODO: Clamp values to prevent zero or negative height lines
                path.line(from: (x_CGFloat, verticalMiddle - height), to: (x_CGFloat, verticalMiddle + height))
            }
        }
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Render the layer's contents in the graphics context.
        
        layer.path = path.cgPath
        self.layer?.addSublayer(layer)
        
        if let progressLayer = layer.deepCopy() as? CAShapeLayer {
            
            progressLayer.strokeColor = systemColorScheme.activeControlColor.cgColor
            self.layer?.addSublayer(progressLayer)
            
            let mask = CAShapeLayer()
            mask.frame = CGRect(x: 0, y: 0, width: scaledWidth * progress, height: scaledHeight)
            mask.removeAllAnimations()
            progressLayer.mask = mask
        }
        
        if samplesDrawn >= Int(bounds.width) {
            baseLayerComplete = true
        }
    }
}

extension WaveformView: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        baseLayerComplete = false
        redraw()
    }
    
    // TODO: Respond to activeControlColor + inactiveControlColor changes
}

fileprivate extension Array where Element == Float {

    ///
    /// An efficient way to find the maximum value in a ``Float`` array
    /// using Accelerate.
    ///
    func fastMax() -> Float {

        var max: Float = 0
        vDSP_maxv(self, 1, &max, UInt(count))
        return max
    }
}

extension [[Float]] {
    
    var sampleMax: Float {
       
        // Use Accelerate to compute the maximums for each channel efficiently.
        let allMaximums = self.map {$0.fastMax()}
        
        // Return the maximum value within ``allMaximums``.
        return Float(allMaximums.max() ?? 0)
    }
}

import Cocoa

extension CALayer {
    
    func deepCopy() -> CALayer? {
        
        try? NSKeyedUnarchiver.unarchivedObject(
                ofClass: CALayer.self,
                from: try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false))
    }
}

extension NSBezierPath {
    
    /// Unified logger.
//    private static let logger: Logger = Logger(subsystem: "Aural", category: "NSBezierPath")
    
    // MARK: Properties
    
    // ------------------------------------------------------------------------------

    // MARK: Initializers / functions
    
    ///
    /// A convenience function to draw a line between 2 points specified as tuples of ``CGFloat``.
    ///
    /// Performs 2 distinct steps:
    ///
    /// - Move to the ``from`` point.
    /// - Draw a line to the ``to`` point.
    ///
    func line(from: (x: CGFloat, y: CGFloat), to: (x: CGFloat, y: CGFloat)) {
        
        move(to: CGPoint(x: from.x, y: from.y))
        line(to: CGPoint(x: to.x, y: to.y))
    }
}
