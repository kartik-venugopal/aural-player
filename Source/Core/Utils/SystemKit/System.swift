//
// System.swift
// SystemKit
//
// The MIT License
//
// Copyright (C) 2014-2017  beltex <https://github.com/beltex>

import Darwin
import Foundation

public class System {
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC PROPERTIES
    //--------------------------------------------------------------------------
    
    /// Number of physical cores on this machine.
    public static var physicalCores: Int {
        Int(hostBasicInfo.physical_cpu)
    }
    
    ///
    /// Number of logical cores on this machine. Will be equal to physicalCores()
    /// unless it has hyper-threading, in which case it will be double.
    ///
    /// Source: https://en.wikipedia.org/wiki/Hyper-threading
    ///
    public static var logicalCores: Int {
        Int(hostBasicInfo.logical_cpu)
    }
    
    static var numberOfActiveCores: Int {
        ProcessInfo.processInfo.activeProcessorCount
    }
    
    static var osVersion: OperatingSystemVersion {
        ProcessInfo.processInfo.operatingSystemVersion
    }
    
    static var openFilesLimit: UInt64 {
        
        get {
            
            var limit: rlimit = rlimit()
            getrlimit(RLIMIT_NOFILE, &limit);
            return limit.rlim_cur
        }
        
        set(newLimit) {
            
            var limit: rlimit = rlimit()
            
            getrlimit(RLIMIT_NOFILE, &limit);
            limit.rlim_cur = newLimit
            
            setrlimit(RLIMIT_NOFILE, &limit);
        }
    }
    
    static let primaryVolumeName: String? = {
        
        let url = URL(fileURLWithPath: "/Users")
        
        do {
            return try url.resourceValues(forKeys: [.volumeNameKey]).allValues[.volumeNameKey] as? String
        } catch {
            return nil
        }
    }()
    
    static var secondaryVolumes: [URL] {
        
        FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [URLResourceKey.volumeNameKey],
                                      options: [])?.filter{$0.path.hasPrefix("/Volumes")} ?? []
    }
    
    //--------------------------------------------------------------------------
    // MARK: INITIALIZERS
    //--------------------------------------------------------------------------
    
    /// Prevent instantiation.
    private init() {}
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS
    //--------------------------------------------------------------------------
    
    fileprivate static let hostBasicInfo: host_basic_info = {
        
        // As defined in <mach/tash_info.h>
        var size     = UInt32(MemoryLayout<host_basic_info_data_t>.size / MemoryLayout<integer_t>.size)
        
        let hostInfo = host_basic_info_t.allocate(capacity: 1)
        defer {hostInfo.deallocate()}

        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_info(mach_host_self(), HOST_BASIC_INFO, $0, &size)
        }

        return hostInfo.move()
    }()
}
