import Foundation
import Accelerate
import AVFoundation

class FFT {
    
    let frameCount: Int = 1024
    let sampleRate: Float
    
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
    
    init(sampleRate: Float) {
        
        self.sampleRate = sampleRate
        
        log2n = UInt(round(log2(Double(frameCount))))
        bufferSizePOT = Int(1 << log2n)
        halfBufferSize = bufferSizePOT / 2
        
        //        print("half", halfBufferSize, frameCount)
        
        fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))!
        
        realp = [Float](repeating: 0, count: halfBufferSize)
        imagp = [Float](repeating: 0, count: halfBufferSize)
        output = DSPSplitComplex(realp: &realp, imagp: &imagp)
        windowSize = bufferSizePOT
        
        transferBuffer = [Float](repeating: 0, count: windowSize)
        window = [Float](repeating: 0, count: windowSize)
        
        magnitudes = [Float](repeating: 0, count: halfBufferSize)
        normalizedMagnitudes = [Float](repeating: 0, count: halfBufferSize)
    }
    
    func fft1(_ buffer: AVAudioPCMBuffer) -> FrequencyData {
        
        // Hann windowing to reduce the frequency leakage
        vDSP_hann_window(&window, vDSP_Length(windowSize), Int32(vDSP_HANN_NORM))
        vDSP_vmul((buffer.floatChannelData?.pointee)!, 1, window,
                  1, &transferBuffer, 1, vDSP_Length(windowSize))
        
        //        vDSP_ctoz(UnsafePointer<DSPComplex>(), 2, &output, 1, UInt(halfBufferSize))
        //
        let stream = (buffer.floatChannelData?.pointee)!
        stream.withMemoryRebound(to: DSPComplex.self, capacity: bufferSizePOT / 2) {dspComplexStream in
            vDSP_ctoz(dspComplexStream, 2, &output, 1, UInt(bufferSizePOT / 2))
        }
        
        // Perform the FFT
        vDSP_fft_zrip(fftSetup, &output, 1, log2n, FFTDirection(FFT_FORWARD))
        
        vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(halfBufferSize))
        
        // Normalizing
        vDSP_vsmul(self.sqrtq(magnitudes), 1, [2.0 / Float(halfBufferSize)],
                   &normalizedMagnitudes, 1, vDSP_Length(halfBufferSize))
        
        //        vDSP_destroy_fftsetup(fftSetup)
        
        var freqs = [Float](repeating: 0, count: halfBufferSize)
        var mags = [Float](repeating: 0, count: halfBufferSize)
        
        let frameCount_f = Float(frameCount)
        
        //        print("\nNM has " + String(normalizedMagnitudes.count))
        
        for i in 0...(normalizedMagnitudes.count) - 1 {
            freqs[i] = Float(i) * sampleRate / frameCount_f
            mags[i] = normalizedMagnitudes[i]
        }
        
        let data = FrequencyData(sampleRate: sampleRate, frequencies: freqs, magnitudes: mags)
        
        return data
    }
    
    func sqrtq(_ x: [Float]) -> [Float] {
        var results = [Float](repeating: 0, count: x.count)
        vvsqrtf(&results, x, [Int32(x.count)])
        
        return results
    }
}

class FrequencyData {
    
    var sampleRate: Float
    var frequencies: [Float]
    var magnitudes: [Float]
    
    var bands: [Band]
    
    init(sampleRate: Float, frequencies: [Float], magnitudes: [Float]) {
        
        self.sampleRate = sampleRate
        self.frequencies = frequencies
        self.magnitudes = magnitudes
        
        var minF = 0
        let firstFreq = frequencies[1]
        self.bands = [Band]()
        
        for power in 5...14 {
            
            let maxF = Int(pow(Double(2), Double(power)))
            
            let band = Band(minF: minF, maxF: maxF)
            bands.append(band)
            
            let minI = Int(round(Float(minF) / firstFreq))
            let maxI = Int(round(Float(maxF) / firstFreq))
            
            let maxAvg = findMaxAndAverageForFrequencies(minI, maxI: maxI)
            band.maxVal = maxAvg.max
            band.avgVal = maxAvg.avg
            
            minF = maxF
        }
    }
    
    func findMagnitudeForFrequency(_ freq: Int) -> Float {
        
        // TODO: Use interpolation
        
        let firstFreq = frequencies[1]
        
        let index = Int(round(Float(freq) / firstFreq))
        
        //        Swift.print("forFreq:", freq, index, frequencies[index], magnitudes[index])
        
        return magnitudes[index]
    }
    
    func findMaxAndAverageForFrequencies(_ minI: Int, maxI: Int) -> (max: Float, avg: Float) {
        
        var max = 0 - Float.infinity
        var sum: Float = 0
        
        for i in minI...maxI {
            if (magnitudes[i]) > max {
                max = magnitudes[i]
            }
            sum += magnitudes[i]
        }
        
        return (max, sum / Float(maxI - minI + 1))
    }
}

class Band {
    
    var minF: Int
    var maxF: Int
    
    var avgVal: Float = 0
    var maxVal: Float = 0
    
    init(minF: Int, maxF: Int) {
        
        self.minF = minF
        self.maxF = maxF
    }
}

