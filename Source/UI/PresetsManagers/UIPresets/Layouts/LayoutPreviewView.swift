//
//  LayoutPreviewView.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class LayoutPreviewView: NSView {
    
    private var layout: WindowLayout?
    private let idealImgSize: CGFloat = 15
    
    private var screen: NSRect {
        return NSScreen.main!.frame
    }
    
    private var screenVisibleFrame: NSRect {
        return NSScreen.main!.visibleFrame
    }
    
    private var scale: CGFloat {
       return self.width / screen.width
    }
    
    func drawPreviewForLayout(_ layout: WindowLayout) {
        
        self.layout = layout
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
        var path = NSBezierPath.init(rect: dirtyRect)
        path.fill(withColor: .darkGray)
        
        let vx = visibleFrame.minX * drawRatio
        let vy = visibleFrame.minY * drawRatio
        let vw = visibleFrame.width * drawRatio
        let vh = visibleFrame.height * drawRatio
        
        // Draw visible frame
        let vRect = NSRect(x: vx, y: vy, width: vw, height: vh)
        path = NSBezierPath.init(rect: vRect)
        path.fill(withColor: .white)
        
        // Draw window frames
//        if let layout = self.layout {
//            
//            let mainWindowFrame = windowLayoutsManager.mainWindowFrame
//            renderPreview(layout.mainWindowOrigin, mainWindowFrame.width, mainWindowFrame.height, .imgPlayerPreview)
//            
//            if layout.showEffects, let effectsWindowOrigin = layout.effectsWindowOrigin {
//                renderPreview(effectsWindowOrigin, WindowLayoutPresets.effectsWindowWidth, WindowLayoutPresets.effectsWindowHeight, .imgEffectsPreview)
//            }
//            
//            if layout.showPlaylist, let playlistWindowFrame = layout.playlistWindowFrame {
//                renderPreview(playlistWindowFrame, .imgPlaylistPreview)
//            }
//        }
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
