//
// System.swift
// SystemKit
//
// The MIT License
//
// Copyright (C) 2014-2017  beltex <https://github.com/beltex>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Darwin
import Foundation

//------------------------------------------------------------------------------
// MARK: PRIVATE PROPERTIES
//------------------------------------------------------------------------------


// As defined in <mach/tash_info.h>

private let HOST_BASIC_INFO_COUNT         : mach_msg_type_number_t =
                      UInt32(MemoryLayout<host_basic_info_data_t>.size / MemoryLayout<integer_t>.size)
private let HOST_CPU_LOAD_INFO_COUNT      : mach_msg_type_number_t =
                   UInt32(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)

public class System {
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC PROPERTIES
    //--------------------------------------------------------------------------
    
    static var numberOfActiveCores: Int {
        ProcessInfo.processInfo.activeProcessorCount
    }
    
    static var osVersion: OperatingSystemVersion {
        ProcessInfo.processInfo.operatingSystemVersion
    }
    
    static var isBigSur: Bool {
        
        let os = osVersion
        return os.majorVersion > 10 || os.minorVersion > 15
    }
    
    /// Size of physical memory on this machine
    public static var physicalMemory: UInt64 {
        hostBasicInfo.max_mem
    }
    
    /// Number of physical cores on this machine.
    public static var physicalCores: Int {
        
        #if os(macOS)
        
        Int(hostBasicInfo.physical_cpu)
        
        #elseif os(iOS)
        
        var cores: Int = 1
        sysctlbyname("hw.physicalcpu", nil, &cores, nil, 0)
        return max(cores, 1)
        
        #endif
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
    
    ///
    /// Whether or not this machine's CPU has the hyperthreading feature, allowing
    /// it to process 2 threads per physical core.
    ///
    /// **Notes**
    ///
    /// This will be true for all modern Intel processors and false for current generation
    /// M1 processors.
    ///
    public static var isHyperthreadingAvailable: Bool {
        logicalCores == 2 * physicalCores
    }
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTIES
    //--------------------------------------------------------------------------
    

    private static let machHost = mach_host_self()
    private static var loadPrevious = host_cpu_load_info()
    
    //--------------------------------------------------------------------------
    // MARK: INITIALIZERS
    //--------------------------------------------------------------------------
    
    /// Prevent instantiation.
    private init() {}
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------
    
    /**
    Get CPU usage (system, user, idle, nice). Determined by the delta between
    the current and last call. Thus, first call will always be inaccurate.
    */
    public static var usageCPU: (system : Double,
                          user   : Double,
                          app    : Double,
                          noDelta: Bool) {
        
        let load = hostCPULoadInfo
        
        let userDiff = Double(load.cpu_ticks.0 - loadPrevious.cpu_ticks.0)
        let sysDiff  = Double(load.cpu_ticks.1 - loadPrevious.cpu_ticks.1)
        let idleDiff = Double(load.cpu_ticks.2 - loadPrevious.cpu_ticks.2)
        let niceDiff = Double(load.cpu_ticks.3 - loadPrevious.cpu_ticks.3)
        
        let totalTicks = sysDiff + userDiff + niceDiff + idleDiff

        if totalTicks == 0 {
            return (0.0, 0.0, 0.0, true)
        }
        
        let sys  = sysDiff  / totalTicks * 100.0
        let user = userDiff / totalTicks * 100.0
        
        loadPrevious = load
        
        return (sys, user, usageCPUApp, false)
    }
    
    ///
    /// CPU usage for this application.
    ///
    /// Source: https://stackoverflow.com/questions/8223348/ios-get-cpu-usage-from-application/8382889#8382889
    ///
    private static var usageCPUApp: Double {
        
        var kr: kern_return_t
        var task_info_count: mach_msg_type_number_t
        
        task_info_count = mach_msg_type_number_t(TASK_INFO_MAX)
        var tinfo = [integer_t](repeating: 0, count: Int(task_info_count))
        
        kr = task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO), &tinfo, &task_info_count)
        if kr != KERN_SUCCESS {
            return -1
        }
        
        var thread_list: UnsafeMutablePointer<thread_act_t>? = nil
        var thread_count: mach_msg_type_number_t = 0
        
        defer {

            if let thread_list = thread_list {
                vm_deallocate(mach_task_self_, vm_address_t(bitPattern: thread_list), vm_size_t(Int(thread_count) * MemoryLayout<thread_t>.stride) )
            }
        }
        
        kr = task_threads(mach_task_self_, &thread_list, &thread_count)
        
        if kr != KERN_SUCCESS {
            return -1
        }
        
        var tot_cpu: Double = 0
        
        if let thread_list = thread_list {
            
            for j in 0 ..< Int(thread_count) {
                
                var thread_info_count = mach_msg_type_number_t(THREAD_INFO_MAX)
                var thinfo = [integer_t](repeating: 0, count: Int(thread_info_count))
                kr = thread_info(thread_list[j], thread_flavor_t(THREAD_BASIC_INFO),
                                 &thinfo, &thread_info_count)
                
                if kr != KERN_SUCCESS {
                    return -1
                }
                
                let threadBasicInfo = convertThreadInfoToThreadBasicInfo(thinfo)
                
                if threadBasicInfo.flags != TH_FLAGS_IDLE {
                    tot_cpu += (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)) * 100.0
                }
            } // for each thread
        }
        
        return tot_cpu
    }
    
    private static func convertThreadInfoToThreadBasicInfo(_ threadInfo: [integer_t]) -> thread_basic_info {
        
        var result = thread_basic_info()

        result.cpu_usage = threadInfo[4]
        result.flags = threadInfo[7]

        return result
    }

    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS
    //--------------------------------------------------------------------------
    
    fileprivate static var hostCPULoadInfo: host_cpu_load_info {
        
        var size     = HOST_CPU_LOAD_INFO_COUNT
        let hostInfo = host_cpu_load_info_t.allocate(capacity: 1)

        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics(machHost, HOST_CPU_LOAD_INFO,
                                      $0,
                                      &size)
        }

        let data = hostInfo.move()
        hostInfo.deallocate()

        #if DEBUG
            if result != KERN_SUCCESS {
                print("ERROR - \(#file):\(#function) - kern_result_t = "
                        + "\(result)")
            }
        #endif

        return data
    }
    
    fileprivate static var hostBasicInfo: host_basic_info {
        
        var size     = HOST_BASIC_INFO_COUNT
        let hostInfo = host_basic_info_t.allocate(capacity: 1)
        defer {hostInfo.deallocate()}

        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_info(machHost, HOST_BASIC_INFO, $0, &size)
        }

        let data = hostInfo.move()

        #if DEBUG
        if result != KERN_SUCCESS {
            print("ERROR - \(#file):\(#function) - kern_result_t = "
                    + "\(result)")
        }
        #endif

        return data
    }
}
