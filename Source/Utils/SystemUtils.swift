//
//  SystemUtils.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class SystemUtils {
    
    static var numberOfActiveCores: Int {
        return ProcessInfo.processInfo.activeProcessorCount
    }
    
    static var numberOfPhysicalCores: Int {
        
        var cores: Int = 1
        sysctlbyname("hw.physicalcpu", nil, &cores, nil, 0)
        return max(cores, 1)
    }
    
    static var osVersion: OperatingSystemVersion {
        return ProcessInfo.processInfo.operatingSystemVersion
    }
    
    static var isBigSur: Bool {
        
        let os = osVersion
        return os.majorVersion > 10 || os.minorVersion > 15
    }
}
