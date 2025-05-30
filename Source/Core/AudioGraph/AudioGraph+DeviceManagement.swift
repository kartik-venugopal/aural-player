//
// AudioGraph+DeviceManagement.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension AudioGraph {
    
    private static let visualizationAnalysisBufferSize: Int = 2048
    
    var availableDevices: [AudioDevice] {deviceManager.allDevices}
    
    var numberOfDevices: Int {deviceManager.numberOfDevices}
    
    var systemDevice: AudioDevice {deviceManager.systemDevice}
    
    var outputDevice: AudioDevice {
        
        get {deviceManager.outputDevice}
        set(newDevice) {deviceManager.outputDevice = newDevice}
    }
    
    var indexOfOutputDevice: Int {
        deviceManager.indexOfOutputDevice
    }
    
    var outputDeviceSampleRate: Double {
        deviceManager.outputDeviceSampleRate
    }
    
    var outputDeviceBufferSize: Int {
        
        get {deviceManager.outputDeviceBufferSize}
        set {deviceManager.outputDeviceBufferSize = newValue}
    }
    
    func setInitialOutputDevice(persistentState: AudioGraphPersistentState?) {
        
        // Should just use the system device
        
        // Check if remembered device is available (based on name and UID).
//        if let prefDeviceUID = persistentState?.outputDevice?.uid,
//           let foundDevice = availableDevices.first(where: {$0.uid == prefDeviceUID}) {
//            
//            self.outputDevice = foundDevice
//        }
        
//        deviceManager.maxFramesPerSlice = Self.visualizationAnalysisBufferSize
    }
    
    var visualizationAnalysisBufferSize: Int {
        Self.visualizationAnalysisBufferSize
    }
    
    var isSetUpForVisualizationAnalysis: Bool {
        outputDeviceBufferSize == Self.visualizationAnalysisBufferSize
    }
    
    func setUpForVisualizationAnalysis() {
//        outputDeviceBufferSize = Self.visualizationAnalysisBufferSize
    }
    
    func outputDeviceChanged() {
        
//        deviceManager.maxFramesPerSlice = Self.visualizationAnalysisBufferSize
        engine.start()
        
        // Send out a notification
        messenger.publish(.AudioGraph.outputDeviceChanged)
    }
}
