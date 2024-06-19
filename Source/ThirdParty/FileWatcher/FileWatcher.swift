import Cocoa

public typealias CallBack = (_ fileWatcherEvent: FileWatcherEvent) -> Void

public class FileWatcher {
   let filePaths: [String]  // -- paths to watch - works on folders and file paths
   public var callback: (CallBack)?
   public var queue: DispatchQueue?
   var streamRef: FSEventStreamRef?
   var hasStarted: Bool { streamRef != nil }
   public init(paths: [String]) { self.filePaths = paths }
    public init(urls: [URL]) { self.filePaths = urls.map {$0.path} }
   /**
    * - Parameters:
    *    - streamRef: The stream for which event(s) occurred. clientCallBackInfo: The info field that was supplied in the context when this stream was created.
    *    - numEvents:  The number of events being reported in this callback. Each of the arrays (eventPaths, eventFlags, eventIds) will have this many elements.
    *    - eventPaths: An array of paths to the directories in which event(s) occurred. The type of this parameter depends on the flags
    *    - eventFlags: An array of flag words corresponding to the paths in the eventPaths parameter. If no flags are set, then there was some change in the directory at the specific path supplied in this  event. See FSEventStreamEventFlags. 
    *    - eventIds: An array of FSEventStreamEventIds corresponding to the paths in the eventPaths parameter. Each event ID comes from the most recent event being reported in the corresponding directory named in the eventPaths parameter.
    */
   let eventCallback: FSEventStreamCallback = {(
      stream: ConstFSEventStreamRef,
      contextInfo: UnsafeMutableRawPointer?,
      numEvents: Int,
      eventPaths: UnsafeMutableRawPointer,
      eventFlags: UnsafePointer<FSEventStreamEventFlags>,
      eventIds: UnsafePointer<FSEventStreamEventId>
      ) in
      let fileSystemWatcher = Unmanaged<FileWatcher>.fromOpaque(contextInfo!).takeUnretainedValue()
      let paths = Unmanaged<CFArray>.fromOpaque(eventPaths).takeUnretainedValue() as! [String]
      (0..<numEvents).indices.forEach { index in
         fileSystemWatcher.callback?(FileWatcherEvent(eventIds[index], paths[index], eventFlags[index]))
      }
   }
   let retainCallback: CFAllocatorRetainCallBack = {(info: UnsafeRawPointer?) in
      _ = Unmanaged<FileWatcher>.fromOpaque(info!).retain()
      return info
   }
   let releaseCallback: CFAllocatorReleaseCallBack = {(info: UnsafeRawPointer?) in
      Unmanaged<FileWatcher>.fromOpaque(info!).release()
   }
   func selectStreamScheduler() {
      if let queue = queue {
         FSEventStreamSetDispatchQueue(streamRef!, queue)
      } else {
         FSEventStreamScheduleWithRunLoop(
            streamRef!, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue
         )
      }
   }
}
/**
 * Convenient
 */
extension FileWatcher {
   convenience init(
    _ paths: [String],
    _ callback: @escaping (CallBack),
    _ queue: DispatchQueue
    ) {
        self.init(paths: paths)
      self.callback = callback
      self.queue = queue
   }
}
