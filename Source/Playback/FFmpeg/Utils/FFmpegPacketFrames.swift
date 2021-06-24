//
//  FFmpegPacketFrames.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A container for frames decoded from a single packet.
///
/// Performs operations such as truncation (discarding unwanted frames / samples)
/// on the frames together as a single unit.
///
class FFmpegPacketFrames {
    
    /// The individual constituent frames.
    var frames: [FFmpegFrame] = []
    
    /// The total number of samples (i.e. from all frames).
    var sampleCount: Int32 = 0
    
    ///
    /// Appends a new frame to this container.
    ///
    /// - Parameter frame: The new frame to append.
    ///
    func appendFrame(_ frame: FFmpegFrame) {
            
        // Update the sample count, and append the frame.
        self.sampleCount += frame.sampleCount
        frames.append(frame)
    }
    
    ///
    /// Truncates from the beginning of this container's frame samples,
    /// ensuring that only the given number of **total** samples remains as a
    /// result.
    ///
    /// ```
    /// This operation may be performed after a seek, in order
    /// to correct the seek by getting closer to the target
    /// seek position.
    ///
    /// Example: 5 existing frames, with a sampleCount of 6700.
    ///
    /// Frame 0: 1000 frames
    /// Frame 1: 1200 frames
    /// Frame 2: 1100 frames
    /// Frame 3: 1800 frames
    /// Frame 4: 1600 frames
    ///
    /// Truncate to keep only the last 3500 samples.
    /// keepLastNSamples(3500)
    ///
    /// Result:
    ///
    /// Frame 0: (Removed)
    /// Frame 1: (Removed)
    /// Frame 2: Truncated to 100 samples
    /// Frame 3: (Unmodified) 1800 frames
    /// Frame 4: (Unmodified) 1600 frames
    ///
    /// Now, sampleCount = 3500.
    /// ```
    ///
    func keepLastNSamples(sampleCount: Int32) {
        
        // Desired sample count must be less than existing sample count.
        if sampleCount < self.sampleCount {
            
            // Counter to keep track of samples accounted for so far.
            var samplesSoFar: Int32 = 0
            
            // Index of the first frame in the array that will not be removed.
            var firstFrameToKeep: Int = 0

            // Iterate the frames in reverse, counting the accumulated samples till we have enough.
            for (index, frame) in frames.enumerated().reversed() {
                
                if samplesSoFar + frame.sampleCount <= sampleCount {
                    
                    // This frame fits in its entirety.
                    samplesSoFar += frame.sampleCount
                    
                } else {
                    
                    // This frame fits partially. Need to truncate it.
                    let samplesToKeep = sampleCount - samplesSoFar
                    samplesSoFar += samplesToKeep
                    frame.keepLastNSamples(sampleCount: samplesToKeep)
                }
                
                if samplesSoFar == sampleCount {
                    
                    // We have enough samples. Note down the index of this frame,
                    // and exit the loop.
                    firstFrameToKeep = index
                    break
                }
            }
            
            // Discard any surplus frames from the beginning of the array.
            if firstFrameToKeep > 0 {
                frames.removeFirst(firstFrameToKeep)
            }
            
            // Update the sample count.
            self.sampleCount = sampleCount
        }
    }
}
