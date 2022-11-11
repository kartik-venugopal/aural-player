//
//  FFT.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation
import Accelerate
import AVFoundation

///
/// Performs Fast Fourier Transform computations on rendered audio samples, that can be used for
/// analysis / visualization.
///
class FFT: Destroyable {
    
    let magnitudeRange: ClosedRange<Float> = 0...1
    
    init() {}
    
    private var fftSetup: FFTSetup!
    
    private var log2n: UInt = 9
    
    private(set) var bufferSize: Int = 512
    private var bufferSizePOT: Int = 512
    private var bufferSizePOT_Float: Float = 512
    
    private var halfBufferSize: Int = 256
    private var halfBufferSize_Int32: Int32 = 256
    private var halfBufferSize_UInt: UInt = 256
    private var halfBufferSize_Float: Float = 256
    
    private(set) var frequencies: [Float] = []
    
    var frequencyInterval: Float {frequencies[1]}
    var binCount: Int {halfBufferSize}
    
    private(set) var sampleRate: Float = 44100
    var nyquistFrequency: Float {sampleRate / 2}
    
    private let vsMulScalar: [Float] = [Float(1.0) / Float(150.0)]
    
    private var realp: [Float] = []
    private var imagp: [Float] = []
    
    private var transferBuffer: UnsafeMutablePointer<Float> = .allocate(capacity: 0)
    private var window: [Float] = []
    private var windowSize: Int = 512
    private var windowSize_vDSPLength: vDSP_Length = 512
    
    private let fftRadix: Int32 = Int32(kFFTRadix2)
    private let vDSP_HANN_NORM_Int32: Int32 = Int32(vDSP_HANN_NORM)
    private let fftDirection: FFTDirection = FFTDirection(FFT_FORWARD)
    private var zeroDBReference: Float = 0.1
    
    private var magnitudes: [Float] = []
    private(set) var normalizedMagnitudes: UnsafeMutablePointer<Float> = .allocate(capacity: 0)
    
    func setUp(sampleRate: Float, bufferSize: Int) {
        
        self.sampleRate = sampleRate
        self.bufferSize = bufferSize
        
        log2n = log2(Double(bufferSize)).roundedUInt
        
        bufferSizePOT = Int(1 << log2n)
        bufferSizePOT_Float = Float(bufferSizePOT)
        
        halfBufferSize = bufferSizePOT / 2
        halfBufferSize_Int32 = Int32(halfBufferSize)
        halfBufferSize_UInt = UInt(halfBufferSize)
        halfBufferSize_Float = Float(halfBufferSize)
        
        frequencies = (0..<halfBufferSize).map {Float($0) * nyquistFrequency / halfBufferSize_Float}
        
        fftSetup = vDSP_create_fftsetup(log2n, fftRadix)!
        
        realp = [Float](repeating: 0, count: halfBufferSize)
        imagp = [Float](repeating: 0, count: halfBufferSize)
        
        windowSize = bufferSizePOT
        windowSize_vDSPLength = vDSP_Length(windowSize)
        
        transferBuffer = UnsafeMutablePointer<Float>.allocate(capacity: windowSize)
        window = [Float](repeating: 0, count: windowSize)
        
        magnitudes = [Float](repeating: 0, count: halfBufferSize)
        normalizedMagnitudes = UnsafeMutablePointer<Float>.allocate(capacity: halfBufferSize)
    }
    
    func analyze(buffer: AudioBufferList) {
        
        let bufferPtr: UnsafePointer<Float> = UnsafePointer(buffer.mBuffers.mData!.assumingMemoryBound(to: Float.self))
        
        // Hann windowing to reduce frequency leakage
        vDSP_hann_window(&window, windowSize_vDSPLength, vDSP_HANN_NORM_Int32)
        vDSP_vmul(bufferPtr, 1, window, 1, transferBuffer, 1, windowSize_vDSPLength)
        
        realp.withUnsafeMutableBufferPointer {realPtr in
            
            imagp.withUnsafeMutableBufferPointer {imagPtr in
                
                var output: DSPSplitComplex = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                
                transferBuffer.withMemoryRebound(to: DSPComplex.self, capacity: windowSize) {dspComplexStream in
                    vDSP_ctoz(dspComplexStream, 2, &output, 1, halfBufferSize_UInt)
                }
                
                // Perform the FFT
                vDSP_fft_zrip(fftSetup, &output, 1, log2n, fftDirection)
                
                // Convert FFT output to magnitudes
                vDSP_zvmags(&output, 1, &magnitudes, 1, halfBufferSize_UInt)
                
                // Convert to dB and scale.
                vDSP_vdbcon(&magnitudes, 1, &zeroDBReference, normalizedMagnitudes, 1, halfBufferSize_UInt, 1)
                vDSP_vsmul(normalizedMagnitudes, 1, vsMulScalar, normalizedMagnitudes, 1, halfBufferSize_UInt)
            }
        }
    }
    
    func destroy() {
        
        if fftSetup != nil {
            vDSP_destroy_fftsetup(fftSetup)
        }
        
        realp.removeAll()
        imagp.removeAll()
        
        transferBuffer.deallocate()
        window.removeAll()
        
        magnitudes.removeAll()
        normalizedMagnitudes.deallocate()
    }
}
