//
//  BufferCache.swift
//  Aural
//
//  Created by Kay Ven on 9/18/17.
//  Copyright © 2017 Anonymous. All rights reserved.
//

import AVFoundation

class BufferCache {
    
    private static var buffers: [TrackAwareBuffer] = [TrackAwareBuffer]()
    
    static func addBuffer(_ buffer: TrackAwareBuffer) {
        buffers.append(buffer)
    }
    
    static func endPos() -> Double {
        let lastBuffer = buffers.last!
        return lastBuffer.endPos
    }
    
    static func bufferForPos(_ pos: Double) -> TrackAwareBuffer? {
        
        var index = buffers.count - 1
        
        while (index >= 0) {
            
            let buffer = buffers[index]
            if (pos >= buffer.startPos && pos <= buffer.endPos) {
                return buffer
            }
            
            index -= 1
        }
        
        return nil
    }
    
    static func clear() {
        buffers.removeAll()
    }
}
