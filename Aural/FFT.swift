//
//  FFT.swift
//  TestFFT
//
//  Created by Kartik Venugopal on 7/16/17.
//  Copyright © 2017 Kartik Venugopal. All rights reserved.
//

import Cocoa
import AVFoundation
import Accelerate

class FFT {
    
    let frameCount = 1024
    var log2n: UInt
    let bufferSizePOT: Int
    let halfBufferSize: Int
    let fftSetup: FFTSetup
    
    var realp: [Float]
    var imagp: [Float]
    var output: DSPSplitComplex
    let windowSize: Int
    
    var transferBuffer: [Float]
    var window: [Float]
    
    var magnitudes: [Float]
    var normalizedMagnitudes: [Float]
    
    init() {
        
        log2n = UInt(round(log2(Double(frameCount))))
        bufferSizePOT = Int(1 << log2n)
        halfBufferSize = bufferSizePOT / 2
        
        fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
        
        realp = [Float](count: halfBufferSize, repeatedValue: 0)
        imagp = [Float](count: halfBufferSize, repeatedValue: 0)
        output = DSPSplitComplex(realp: &realp, imagp: &imagp)
        windowSize = bufferSizePOT
        
        transferBuffer = [Float](count: windowSize, repeatedValue: 0)
        window = [Float](count: windowSize, repeatedValue: 0)
        
        magnitudes = [Float](count: halfBufferSize, repeatedValue: 0)
        normalizedMagnitudes = [Float](count: halfBufferSize, repeatedValue: 0)
    }
    
    func fft1(buffer: AVAudioPCMBuffer) -> [Float] {
        
        // Hann windowing to reduce the frequency leakage
        vDSP_hann_window(&window, vDSP_Length(windowSize), Int32(vDSP_HANN_NORM))
        vDSP_vmul(buffer.floatChannelData.memory, 1, window,
            1, &transferBuffer, 1, vDSP_Length(windowSize))
        
        vDSP_ctoz(UnsafePointer<DSPComplex>(buffer.floatChannelData.memory), 2, &output, 1, UInt(halfBufferSize))
        
        // Perform the FFT
        vDSP_fft_zrip(fftSetup, &output, 1, log2n, FFTDirection(FFT_FORWARD))
        
        vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(halfBufferSize))
        
        // Normalizing
        vDSP_vsmul(self.sqrtq(magnitudes), 1, [2.0 / Float(halfBufferSize)],
            &normalizedMagnitudes, 1, vDSP_Length(halfBufferSize))
        
        //        vDSP_destroy_fftsetup(fftSetup)
        
        return normalizedMagnitudes
    }
    
    func fft2(buffer: AVAudioPCMBuffer) -> [Float] {
        
        vDSP_ctoz(UnsafePointer<DSPComplex>(buffer.floatChannelData.memory), 2, &output, 1, UInt(halfBufferSize))
        
        vDSP_fft_zrip(fftSetup, &output, 1, log2n, Int32(FFT_FORWARD))
        
        var fft = [Float](count:Int(halfBufferSize), repeatedValue:0.0)
        let bufferOver2: vDSP_Length = vDSP_Length(halfBufferSize)
        vDSP_zvmags(&output, 1, &fft, 1, bufferOver2)
        
        for var i = 0; i < bufferSizePOT/2; ++i {
            let imag = output.imagp[i]
            let real = output.realp[i]
            let magnitude = sqrt(pow(real,2)+pow(imag,2))
            magnitudes.append(magnitude)
        }
        
        // Normalising
        vDSP_vsmul(self.sqrtq(magnitudes), 1, [2.0 / Float(halfBufferSize)],
            &normalizedMagnitudes, 1, vDSP_Length(halfBufferSize))
        
        //        vDSP_destroy_fftsetup(fftSetup)
        
        return normalizedMagnitudes
    }
    
    func sqrtq(x: [Float]) -> [Float] {
        var results = [Float](count: x.count, repeatedValue: 0)
        vvsqrtf(&results, x, [Int32(x.count)])
        
        return results
    }
}
