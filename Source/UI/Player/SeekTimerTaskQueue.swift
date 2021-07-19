//
//  SeekTimerTaskQueue.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

typealias SeekTimerTask = () -> Void

/*
    Utility class for submitting tasks to the "seek timer" that acts as a clock and triggers regular periodic UI updates as the player seeks through a track.
 
    This is needed by any external class wishing to synchronize its updates with the seek timer (so as not to create another timer instance which is resource-intensive).
 */
class SeekTimerTaskQueue {
    
    // TODO: Revisit this class, make it a singleton.
    
    // Mapping of task ID -> task
    private static var tasks: [String: SeekTimerTask] = [:]
    
    // Accessor to retrieve all currently queued tasks
    static var tasksArray: [SeekTimerTask] = []
    
    // Enqueues a single task and maps it to the given (unique) ID so that it can later be retrieved by the same ID when it needs to be dequeued
    static func enqueueTask(_ id: String, _ task: @escaping SeekTimerTask) {
        
        tasks[id] = task
        tasksArray = Array(tasks.values)
    }
    
    // Dequeues a previously queued task, identified by the given ID
    static func dequeueTask(_ id: String) {
        
        tasks.removeValue(forKey: id)
        tasksArray = Array(tasks.values)
    }
}
