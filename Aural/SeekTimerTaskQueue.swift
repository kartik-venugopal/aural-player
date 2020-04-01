import Cocoa

/*
    Utility class for submitting tasks to the "seek timer" that acts as a clock and triggers regular periodic UI updates as the player seeks through a track.
    This is needed by any external class wishing to synchronize its updates with the seek timer (so as not to create another timer instance which is resource-intensive).
 */
class SeekTimerTaskQueue {
    
    // Mapping of task ID -> task
    private static var tasks: [String: () -> Void] = [:]
    
    // Accessor to retrieve all currently queued tasks
    static var tasksArray: [() -> Void] = []
    
    // Enqueues a single task and maps it to the given (unique) ID so that it can later be retrieved by the same ID when it needs to be dequeued
    static func enqueueTask(_ id: String, _ task: @escaping () -> Void) {
        
        tasks[id] = task
        tasksArray = Array(tasks.values)
    }
    
    // Dequeues a previously queued task, identified by the given ID
    static func dequeueTask(_ id: String) {
        
        tasks.removeValue(forKey: id)
        tasksArray = Array(tasks.values)
    }
}
