//
//  WaveformRenderData.swift
//  Periphony: Spatial Audio Player
//  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
//  Developed by Kartik Venugopal
//

import Foundation
import Accelerate

///
/// Container for all the necessary waveform data required for rendering an image.
///
struct WaveformRenderData {
    
    // MARK: Private state
    
    /// The raw results of downsampling as planar ``Float`` arrays.
    var inSamples: [[Float]]
    
    // --------------------------------------------------------------------------------

    // MARK: Exposed state
    
    /// Output samples (as planar ``CGFloat`` arrays).
    lazy var samples: [[CGFloat]] = inSamples.map {$0.map {CGFloat($0)}}
    
    /// The output sample with the maximum amplitude.
    lazy var sampleMax: CGFloat = {
       
        // Use Accelerate to compute the maximums for each channel efficiently.
        let allMaximums = inSamples.map {$0.fastMax()}
        
        // Return the maximum value within ``allMaximums``.
        return CGFloat(allMaximums.max() ?? 0)
    }()
    
    // --------------------------------------------------------------------------------

    // MARK: Initialization
    
    ///
    /// Initializes this object for a given output channel count.
    ///
    init(outputChannelCount: Int) {
        
        // For each output channel, allocate a ``Float`` array.
        // These samples will be stored in planar form.
        
        inSamples = [[Float]](repeating: [], count: outputChannelCount)
    }
    
    // --------------------------------------------------------------------------------

    // MARK: Functions
    
    ///
    /// Appends the given downsampling data, for the given channel, to the existing
    /// planar array of data for that channel.
    ///
    mutating func appendData(_ data: [Float], forChannel channel: Int) {
        inSamples[channel].append(contentsOf: data)
    }
}

// --------------------------------------------------------------------------------

// MARK: Utility

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
