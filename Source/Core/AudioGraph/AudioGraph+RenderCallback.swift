//
// AudioGraph+RenderCallback.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation
import CoreAudio
import AVFoundation

// Currently, only one observer can be registered. Otherwise, this var will be a collection.
fileprivate var renderObserver: AudioGraphRenderObserverProtocol?

fileprivate let callbackQueue: DispatchQueue = .global(qos: .userInteractive)

///
/// An **AudioGraph** extension providing functions to register / unregister observers in order to respond to audio graph render events,
/// i.e. every time an audio buffer has been rendered to the audio output hardware device.
///
/// Example - The **Visualizer** uses the render callback notifications to receive the rendered audio samples, in order to
/// render visualizations.
///
extension AudioGraph {
    
    var renderCallback: AURenderCallback {
        
        {
            (inRefCon : UnsafeMutableRawPointer,
             ioActionFlags : UnsafeMutablePointer<AudioUnitRenderActionFlags>,
             inTimeStamp : UnsafePointer<AudioTimeStamp>,
             inBusNumber : UInt32,
             inNumberFrames : UInt32,
             ioData : UnsafeMutablePointer<AudioBufferList>?) -> OSStatus in
           
            guard ioActionFlags.pointee == .unitRenderAction_PostRender,
                  let bufferList = ioData?.pointee else {return noErr}
            
            callbackQueue.async {
                renderObserver?.rendered(audioBuffer: bufferList)
            }
            
            return noErr
        }
    }
    
    var deviceChangeCallback: AudioUnitPropertyListenerProc {
        
        {
            (inRefCon: UnsafeMutableRawPointer,
             inUnit: AudioUnit,
             inID: AudioUnitPropertyID,
             inScope: AudioUnitScope,
             inElement: AudioUnitElement) -> Void in
            
            callbackQueue.async {
                renderObserver?.deviceChanged(newDeviceBufferSize: audioGraph.outputDeviceBufferSize,
                                              newDeviceSampleRate: audioGraph.outputDeviceSampleRate)
            }
        }
    }
    
    var sampleRateChangeCallback: AudioUnitPropertyListenerProc {
        
        {
            (inRefCon: UnsafeMutableRawPointer,
             inUnit: AudioUnit,
             inID: AudioUnitPropertyID,
             inScope: AudioUnitScope,
             inElement: AudioUnitElement) -> Void in
            
            callbackQueue.async {
                renderObserver?.deviceSampleRateChanged(newSampleRate: audioGraph.outputDeviceSampleRate)
            }
        }
    }
    
    func registerRenderObserver(_ observer: AudioGraphRenderObserverProtocol) {
        
        guard let outputAudioUnit: AudioUnit = outputNode.audioUnit else {return}
        
        let unmanagedReferenceToSelf: UnsafeMutableRawPointer = Unmanaged.passUnretained(self).toOpaque()
        renderObserver = observer
        
        outputAudioUnit.registerRenderCallback(inProc: renderCallback, inProcUserData: unmanagedReferenceToSelf)
        outputAudioUnit.registerDeviceChangeCallback(inProc: deviceChangeCallback, inProcUserData: unmanagedReferenceToSelf)
        outputAudioUnit.registerSampleRateChangeCallback(inProc: sampleRateChangeCallback, inProcUserData: unmanagedReferenceToSelf)
    }
    
    func removeRenderObserver(_ observer: AudioGraphRenderObserverProtocol) {
        
        guard let outputAudioUnit: AudioUnit = outputNode.audioUnit else {return}
        let unmanagedReferenceToSelf: UnsafeMutableRawPointer = Unmanaged.passUnretained(self).toOpaque()
        
        outputAudioUnit.removeRenderCallback(inProc: renderCallback, inProcUserData: unmanagedReferenceToSelf)
        outputAudioUnit.removeDeviceChangeCallback(inProc: deviceChangeCallback, inProcUserData: unmanagedReferenceToSelf)
        outputAudioUnit.removeSampleRateChangeCallback(inProc: sampleRateChangeCallback, inProcUserData: unmanagedReferenceToSelf)
        
        renderObserver = nil
    }
    
    func pauseRenderObserver(_ observer: AudioGraphRenderObserverProtocol) {
        
        guard let outputAudioUnit: AudioUnit = outputNode.audioUnit else {return}
        let unmanagedReferenceToSelf: UnsafeMutableRawPointer = Unmanaged.passUnretained(self).toOpaque()
        
        outputAudioUnit.removeRenderCallback(inProc: renderCallback, inProcUserData: unmanagedReferenceToSelf)
    }
    
    func resumeRenderObserver(_ observer: AudioGraphRenderObserverProtocol) {
        
        guard let outputAudioUnit: AudioUnit = outputNode.audioUnit else {return}
        let unmanagedReferenceToSelf: UnsafeMutableRawPointer = Unmanaged.passUnretained(self).toOpaque()
        
        outputAudioUnit.registerRenderCallback(inProc: renderCallback, inProcUserData: unmanagedReferenceToSelf)
    }
}
