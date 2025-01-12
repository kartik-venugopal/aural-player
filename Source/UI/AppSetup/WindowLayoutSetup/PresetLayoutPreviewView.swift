//
//  PresetLayoutPreviewView.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PresetLayoutPreviewView: NSView {
    
    private var layout: WindowLayout?
    private let idealImgSize: CGFloat = 15
    
    private var screen: NSRect {
        return NSScreen.main!.frame
    }
    
    private var screenVisibleFrame: NSRect {
        NSScreen.main!.visibleFrame
    }
    
    private var scale: CGFloat {
       self.width / screen.width
    }
    
    private var gapBetweenWindows: CGFloat {
        CGFloat(preferences.viewPreferences.windowGap.value)
    }
    
    func drawPreviewForPreset(_ preset: WindowLayoutPresets) {
        
        self.layout = preset.layout(on: .main!, withGap: gapBetweenWindows)
        redraw()
    }
    
    func clear() {
        
        self.layout = nil
        redraw()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        let visibleFrame = screenVisibleFrame
        let drawRatio = scale
        
        // Draw screen
        let vx = visibleFrame.minX * drawRatio
        let vy = visibleFrame.minY * drawRatio
        let vw = visibleFrame.width * drawRatio
        let vh = visibleFrame.height * drawRatio
        
        // Draw visible frame
        let vRect = NSRect(x: vx, y: vy, width: vw, height: vh)
        let path = NSBezierPath.init(rect: vRect)
        path.fill(withColor: .white)
        
        // Draw window frames
        guard let layout = self.layout else {return}

        // Main Window
        renderPreview(layout.mainWindowFrame?.origin ?? .zero, 440, 200, .imgPlay.tintedWithColor(.white))
        
        // Effects Window
        if let effectsWindowOrigin = layout.effectsWindowFrame?.origin {
            renderPreview(effectsWindowOrigin, WindowLayoutPresets.effectsWindowWidth, WindowLayoutPresets.effectsWindowHeight, .imgEffects.tintedWithColor(.white))
        }
        
        // Play Queue Window
        if let playQueueWindowFrame = layout.playQueueWindowFrame {
            renderPreview(playQueueWindowFrame, .imgPlayQueue.tintedWithColor(.white))
        }
    }
    
    private func renderPreview(_ origin: NSPoint, _ width: CGFloat, _ height: CGFloat, _ image: NSImage) {
        renderPreview(NSRect(x: origin.x, y: origin.y, width: width, height: height), image)
    }
    
    private func renderPreview(_ frame: NSRect, _ image: NSImage) {
        
        let drawRect = frame.shrink(scale)
        let path = NSBezierPath.init(roundedRect: drawRect, xRadius: 3, yRadius: 3)
        
        path.fill(withColor: .black)
        path.stroke(withColor: .lightGray, lineWidth: 2)
        
        let imgWidth = drawRect.width > (idealImgSize * 1.2) ? idealImgSize : idealImgSize * 0.67
        let imgHeight = drawRect.height > (idealImgSize * 1.2) ? idealImgSize : idealImgSize * 0.67
        
        let imgSize = min(imgWidth, imgHeight)
        
        let xPadding = drawRect.width - imgSize
        let yPadding = drawRect.height - imgSize
        
        let imgRect = NSRect(x: drawRect.minX + xPadding / 2, y: drawRect.minY + yPadding / 2, width: imgSize, height: imgSize)
        image.draw(in: imgRect)
    }
}
