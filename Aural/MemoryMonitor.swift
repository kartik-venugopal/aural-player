/*
    A daemon task that keeps an eye on memory usage of this app. If memory usage exceeds a pre-defined threshold, indicating a possible memory leak, the task will exit the app, to prevent a system freeze.
*/

import Cocoa

class MemoryMonitor: NSObject {
    
    private static var daemonThread: NSThread?
    private static var taskExecutor: ScheduledTaskExecutor?
    
    private static let MAX_MEMORY_USAGE: Size = Size(size: 500, sizeUnit: SizeUnit.MB)
    private static let MONITOR_FREQUENCY_MILLIS: Int = 5000   // Poll interval
    
    // Start the memory monitor
    static func start() {
        
        taskExecutor = ScheduledTaskExecutor(intervalMillis: UInt32(MONITOR_FREQUENCY_MILLIS), task: {checkMemory()}, queue: DispatchQueue(queueName: "Aural.queues.monitoring"))
        taskExecutor?.startOrResume()
    }
    
    // Checks memory usage. If it exceeds the limit, the app is exited.
    static func checkMemory() {
        
        let memUsed = getMemoryUsage()
        
        if (memUsed != nil) {
            
            if (memUsed!.greaterThan(MAX_MEMORY_USAGE)) {
                print(String(format: "\n**** Max memory used (%@), exiting ... ****\n", (memUsed?.toString())!))
                exit(1)
            }
            
        } else {
            print("Unable to obtain memory usage !\n")
        }
    }
    
    // Returns the amount of memory currently being used by this app
    private static func getMemoryUsage() -> Size? {
        
        var info = task_basic_info()
        var count = mach_msg_type_number_t(sizeofValue(info))/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(&info) {
            
            task_info(mach_task_self_,
                task_flavor_t(TASK_BASIC_INFO),
                task_info_t($0),
                &count)
            
        }
        
        if kerr == KERN_SUCCESS {
            return Size(sizeBytes: info.resident_size)
            
        } else {
            print("Error with task_info(): " +
                (String.fromCString(mach_error_string(kerr)) ?? "unknown error"))
            return nil
        }
    }
}