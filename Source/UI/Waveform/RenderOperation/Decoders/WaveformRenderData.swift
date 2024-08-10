//
//  WaveformRenderData.swift
//  Periphony: Spatial Audio Player
//  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
//  Developed by Kartik Venugopal
//

import AVFoundation
import Accelerate

///
/// Container for all the necessary waveform data required for rendering an image.
///
struct WaveformRenderData {
    
    // MARK: Private state
    
    /// The raw results of downsampling as planar ``Float`` arrays.
    var samples: [[Float]]
    
    // --------------------------------------------------------------------------------

    // MARK: Initialization
    
    ///
    /// Initializes this object for a given output channel count.
    ///
    init(outputChannelCount: AVAudioChannelCount) {
        
        // For each output channel, allocate a ``Float`` array.
        // These samples will be stored in planar form.
        
        samples = [[Float]](repeating: [], count: Int(outputChannelCount))
    }
    
    // --------------------------------------------------------------------------------

    // MARK: Functions
    
    ///
    /// Appends the given downsampling data, for the given channel, to the existing
    /// planar array of data for that channel.
    ///
    mutating func appendData(_ data: [Float], forChannel channel: Int) {
        samples[channel].append(contentsOf: data)
    }
}
