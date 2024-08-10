//
//  WaveformView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
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
class WaveformView: NSView, SampleReceiver, Destroyable {
    
    static let noiseFloor: Float = -50
    
    var eventMonitor: EventMonitor!
    var clickRecognizer: NSClickGestureRecognizer!
    
    var _audioFile: URL?
    var renderOp: WaveformRenderOperation?
    
    var waveformSize: NSSize = .zero
    
    override var frame: NSRect {
        
        get {super.frame}
        
        set {
            super.frame = newValue
            waveformSize = bounds.size
        }
    }
    
    required init?(coder: NSCoder) {

        super.init(coder: coder)
        
        self.waveformSize = self.bounds.size
        self.wantsLayer = true
        
        prepareToAppear()
    }
    
    func prepareToAppear() {
        
        setUpGestureHandling()
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.activeControlColor, handler: activeControlColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.inactiveControlColor, handler: inactiveControlColorChanged(_:))
    }
    
    func prepareToDisappear() {
        
        destroy()
        
        colorSchemesManager.removeSchemeObserver(self)
        colorSchemesManager.removePropertyObservers(self, forProperties: \.activeControlColor, \.inactiveControlColor)
    }
    
    func destroy() {
        
        renderOp?.cancel()
        renderOp = nil
        
        _audioFile = nil
        samples = [[],[]]
        
        deactivateGestureHandling()
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
        
        renderOp?.cancel()
        renderOp = nil
        
        samples = [[],[]]
        progress = 0
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
    
    var loopStartProgress: CGFloat? = nil {
        
        didSet {
            
            if let loopStartProgress = self.loopStartProgress {
                maskLayerStartX = loopStartProgress * self.width
            } else {
                maskLayerStartX = nil
            }

            redraw()
        }
    }
    
    var maskLayerStartX: CGFloat? = nil
    
    var baseLayerComplete: Bool = false
    
    var maskLayer: CALayer? {
        
        if let subLayers = layer?.sublayers, subLayers.count >= 2 {
            return subLayers[1].mask
        }
        
        return nil
    }
    
    var baseLayer: CAShapeLayer? {
        layer?.sublayers?.first as? CAShapeLayer
    }
    
    var progressLayer: CAShapeLayer? {
        
        if let subLayers = layer?.sublayers, subLayers.count >= 2 {
            return subLayers[1] as? CAShapeLayer
        }
        
        return nil
    }
    
    override func viewDidEndLiveResize() {
        
        super.viewDidEndLiveResize()
        
        resetState()
        analyzeAudioFile()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        
        let samplesToDraw = self.samples
        
//        let scaleFactor: CGFloat = window?.screen?.backingScaleFactor ?? NSScreen.main!.backingScaleFactor
        let scaleFactor: CGFloat = 1
        let scaledImageSize = bounds
        
        let scaledWidth = scaledImageSize.width
        let scaledHeight = scaledImageSize.height
        
        guard !baseLayerComplete else {
            
            if let maskLayer = self.maskLayer {
                
                let frameX = maskLayerStartX ?? 0
                maskLayer.frame = CGRect(x: frameX, y: 0, width: max(2, (scaledWidth * progress)) - frameX, height: scaledHeight)
                maskLayer.removeAllAnimations()
            }
            return
        }
        
        layer?.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Create and configure a CALayer to do the drawing.
        
        let baseLayer = CAShapeLayer()
        baseLayer.frame = CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight)
        baseLayer.strokeColor = systemColorScheme.inactiveControlColor.cgColor
        baseLayer.fillColor = NSColor.clear.cgColor
        baseLayer.lineWidth = 1.0
        
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
                
                // TODO: Print out such invalid values and fix the scaling.
                if height.isZero || height.isNaN {continue}
                
                // TODO: Clamp values to prevent zero or negative height lines
                path.line(from: (x_CGFloat, verticalMiddle - height), to: (x_CGFloat, verticalMiddle + height))
            }
        }
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Set up the mask layer (for progress)
        
        baseLayer.path = path.cgPath
        self.layer?.addSublayer(baseLayer)
        
        if let progressLayer = baseLayer.deepCopy() as? CAShapeLayer {
            
            progressLayer.strokeColor = systemColorScheme.activeControlColor.cgColor
            self.layer?.addSublayer(progressLayer)
            
            let mask = CAShapeLayer()
            
            let frameX = maskLayerStartX ?? 0
            mask.frame = CGRect(x: frameX, y: 0, width: max(2, (scaledWidth * progress)) - frameX, height: scaledHeight)
            mask.backgroundColor = progressLayer.strokeColor
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
        
        baseLayer?.strokeColor = systemColorScheme.inactiveControlColor.cgColor
        progressLayer?.strokeColor = systemColorScheme.activeControlColor.cgColor
        maskLayer?.backgroundColor = progressLayer?.strokeColor
        
        redraw()
    }
    
    func activeControlColorChanged(_ newColor: NSColor) {
        
        progressLayer?.strokeColor = newColor.cgColor
        maskLayer?.backgroundColor = progressLayer?.strokeColor
    }
    
    func inactiveControlColorChanged(_ newColor: NSColor) {
        baseLayer?.strokeColor = newColor.cgColor
    }
}

extension [[Float]] {
    
    var sampleMax: Float {
       (self.map {$0.fastMax}).max() ?? 0
    }
}
