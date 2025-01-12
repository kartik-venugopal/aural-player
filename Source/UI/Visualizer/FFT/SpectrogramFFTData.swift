//
//  SpectrogramFFTData.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation
import Accelerate

class SpectrogramFFTData {
    
    private var frequencyInterval: Float = 0
    private var lastBinIndex: Int = 0
    
    func setUp(fft: FFT, numberOfBands: Int) {
        
        self.frequencyInterval = fft.frequencyInterval
        self.lastBinIndex = fft.binCount - 1
        self.numberOfBands = numberOfBands
    }
    
    // Temp variable used by update()
    private var maxVal: Float = 0
    
    func update(with fft: FFT) {
        
        let alternateLogicForBand0: Bool = fft.bufferSize < audioGraph.visualizationAnalysisBufferSize
        
        for (index, band) in bands.enumerated() {
            
            if alternateLogicForBand0, index == 0 {
                maxVal = (fft.normalizedMagnitudes[0] + fft.normalizedMagnitudes[1]) / 2
                
            } else {
                vDSP_maxv(fft.normalizedMagnitudes.advanced(by: band.minIndex), 1, &maxVal, band.indexCount)
            }
            
            band.maxVal = maxVal.clamped(to: fft.magnitudeRange)
        }
    }
    
    var numberOfBands: Int = 10 {
        
        didSet {
            //            bands = numberOfBands == 10 ? bands_10 : bands_31
            bands = bands_10
        }
    }
    
    private(set) var bands: [Band] = []
    
    var bands_10: [Band] {
        
        let arr: [Float] = [31, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
        
        let tpb: Float = 2
        var bands: [Band] = []
        
        for index in 0..<arr.count {
            
            let f = arr[index]
            let minF: Float = index > 0 ? bands[index - 1].maxF : sqrt((f * f) / tpb)
            let maxF: Float = sqrt((f * f) / tpb) * tpb
            
            let minIndex: Int = (minF / frequencyInterval).roundedInt
            let maxIndex: Int = min((maxF / frequencyInterval).roundedInt - 1, lastBinIndex)
            
            bands.append(Band(minF: minF, maxF: maxF, minIndex: minIndex, maxIndex: maxIndex))
        }
        
        return bands
    }
    
}

class Band {
    
    let minF: Float
    let maxF: Float
    
    let minIndex: Int
    let maxIndex: Int
    let indexCount: UInt
    
    var maxVal: Float = 0
    
    init(minF: Float, maxF: Float, minIndex: Int, maxIndex: Int) {
        
        self.minF = minF
        self.maxF = maxF
        
        self.minIndex = minIndex
        self.maxIndex = maxIndex
        self.indexCount = UInt(maxIndex - minIndex + 1)
    }
}

//    var bands_31: [Band] {
//        
//        // 20/25/31.5/40/50/63/80/100/125/160/200/250/315/400/500/630/800/1K/1.25K/1.6K/ 2K/ 2.5K/3.15K/4K/5K/6.3K/8K/10K/12.5K/16K/20K
//        
//        let arr: [Float] = [20, 31.5, 63, 100, 125, 160, 200, 250, 315, 400, 500, 630, 800,
//                            1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000, 10000, 12500, 16000, 20000]
//        
//        var bands: [Band] = []
//        
//        let tpb: Float = pow(2, 1.0/3.0)
//
//        // NOTE: These bands assume a buffer size of 2048, i.e. 1024 FFT output data points, AND a sample rate of 48KHz.
//        
//        bands.append(Band(minF: sqrt((20 * 20) / tpb), maxF: sqrt((20 * 20) / tpb) * tpb, minIndex: 0, maxIndex: 0))            // 23
//        bands.append(Band(minF: sqrt((31.5 * 31.5) / tpb), maxF: sqrt((31.5 * 31.5) / tpb) * tpb, minIndex: 1, maxIndex: 2))    // 46
//        bands.append(Band(minF: bands[1].maxF, maxF: sqrt((63 * 63) / tpb) * tpb, minIndex: 3, maxIndex: 3))                    // 69
//        bands.append(Band(minF: bands[2].maxF, maxF: sqrt((100 * 100) / tpb) * tpb, minIndex: 4, maxIndex: 4))                  // 94
//        bands.append(Band(minF: bands[3].maxF, maxF: sqrt((125 * 125) / tpb) * tpb, minIndex: 5, maxIndex: 6))                  // 117 - 141
//        bands.append(Band(minF: bands[4].maxF, maxF: sqrt((160 * 160) / tpb) * tpb, minIndex: 7, maxIndex: 7))                  // 164
//        
//        for index in 6..<arr.count {
//            
//            let f = arr[index]
//            let minF: Float = bands[index - 1].maxF
//            let maxF: Float = sqrt((f * f) / tpb) * tpb
//            
//            var minIndex: Int = (minF / frequencyInterval).roundedInt
//            var maxIndex: Int = min((maxF / frequencyInterval).roundedInt - 1, lastBinIndex)
//            
//            if maxIndex < minIndex {
//                minIndex = 0
//                maxIndex = 0
//            }
//            
//            bands.append(Band(minF: minF, maxF: maxF, minIndex: minIndex, maxIndex: maxIndex))
//        }
//        
//        return bands
//    }
