//
//  AudioGraphCallbacks.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

fileprivate var renderObserver: AudioGraphRenderObserverProtocol?

fileprivate func renderCallback(inRefCon: UnsafeMutableRawPointer,
                                ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                                inTimeStamp: UnsafePointer<AudioTimeStamp>,
                                inBusNumber: UInt32,
                                inNumberFrames: UInt32,
                                ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
    
    if ioActionFlags.pointee == .unitRenderAction_PostRender {
    
        if let bufferList = ioData?.pointee, let observer = renderObserver {
            
            DispatchQueue.global(qos: .userInteractive).async {
                observer.rendered(timeStamp: inTimeStamp.pointee, frameCount: inNumberFrames, audioBuffer: bufferList)
            }
        }
    }
    
    return noErr
}

func deviceChanged(inRefCon: UnsafeMutableRawPointer,
                   inUnit: AudioUnit,
                   inID: AudioUnitPropertyID,
                   inScope: AudioUnitScope,
                   inElement: AudioUnitElement) {
    
    if let observer = renderObserver {
        
        let graph = unsafeBitCast(inRefCon, to: AudioGraph.self)
        
        DispatchQueue.global(qos: .userInteractive).async {
            observer.deviceChanged(newDeviceBufferSize: graph.outputDeviceBufferSize, newDeviceSampleRate: graph.outputDeviceSampleRate)
        }
    }
}

func sampleRateChanged(inRefCon: UnsafeMutableRawPointer,
                       inUnit: AudioUnit,
                       inID: AudioUnitPropertyID,
                       inScope: AudioUnitScope,
                       inElement: AudioUnitElement) {
    
    if let observer = renderObserver {
        
        let graph = unsafeBitCast(inRefCon, to: AudioGraph.self)
        
        DispatchQueue.global(qos: .userInteractive).async {
            observer.deviceSampleRateChanged(newSampleRate: graph.outputDeviceSampleRate)
        }
    }
}

extension AudioGraph {
    
    var outputAudioUnit: AudioUnit {outputNode.audioUnit!}
    
    var unmanagedReferenceToSelf: UnsafeMutableRawPointer {Unmanaged.passUnretained(self).toOpaque()}
    
    func registerRenderObserver(_ observer: AudioGraphRenderObserverProtocol) {
        
        renderObserver = observer
        
        outputAudioUnit.registerRenderCallback(inProc: renderCallback, inProcUserData: unmanagedReferenceToSelf)
        outputAudioUnit.registerDeviceChangeCallback(inProc: deviceChanged, inProcUserData: unmanagedReferenceToSelf)
        outputAudioUnit.registerSampleRateChangeCallback(inProc: sampleRateChanged, inProcUserData: unmanagedReferenceToSelf)
    }
    
    func removeRenderObserver(_ observer: AudioGraphRenderObserverProtocol) {
        
        renderObserver = nil
        
        outputAudioUnit.removeRenderCallback(inProc: renderCallback, inProcUserData: unmanagedReferenceToSelf)
        outputAudioUnit.removeDeviceChangeCallback(inProc: deviceChanged, inProcUserData: unmanagedReferenceToSelf)
        outputAudioUnit.removeSampleRateChangeCallback(inProc: sampleRateChanged, inProcUserData: unmanagedReferenceToSelf)
    }
}
