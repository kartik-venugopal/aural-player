//
//  AppDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Entry point for the Aural Player application. Performs application life-cycle functions and allows launching of the app with specific files
/// from Finder.
///
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var playbackMenuRootItem: NSMenuItem!
    @IBOutlet weak var soundMenuRootItem: NSMenuItem!
    @IBOutlet weak var playQueueMenuRootItem: NSMenuItem!
    
    lazy var messenger = Messenger(for: self)
    
    override init() {
        
        super.init()
        
        System.openFilesLimit = 10000
        configureLogging()
        
//        copyOverV3State()
    }
    
//    private func copyOverV3State() {
//        
//        let src = URL(fileURLWithPath: "/Users/kven/Music/aural/state.json")
//        let dest = URL(fileURLWithPath: "/Users/kven/Music/aural4/state.json")
//        
//        if dest.exists {
//            dest.rename(to: URL(fileURLWithPath: "/Users/kven/Music/aural4/muthu_\(Date().serializableStringAsHMS)_state.json"))
//        }
//        
//        try? FileManager.default.copyItem(at: src, to: dest)
//    }
    
    /// Make sure all logging is done to the app's log file
    private func configureLogging() {
        
        if let logFileCString = FilesAndPaths.logFile.path.cString(using: .ascii) {
            freopen(logFileCString, "a+", stderr)
        }
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        userDefaults.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    /// Presents the application's user interface upon app startup.
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
//        print("applicationDidFinishLaunching - \(Date.nowTimestampString)")
        
        // Force eager loading of persistent state
        eagerlyInitializeObjects(appPersistentState, metadataRegistry)
        
        let start = CFAbsoluteTimeGetCurrent()
        metadataRegistry.initializeImageCache(fromPersistentState: metadataPersistentState)
        let end = CFAbsoluteTimeGetCurrent()
        
        print("Took \(end - start) sec to init metadata image cache.")
        
        if appSetup.setupRequired {
            performAppSetup()
            
        } else {
            postLaunch()
        }
        
        initializeMetadataComponents()
        
//        opQueue.maxConcurrentOperationCount = 14
//        opQueue.underlyingQueue = .global(qos: .utility)
//        
//        let dir = URL(fileURLWithPath: "/Users/kven/meta-cache/")
////        let dir: URL = URL(fileURLWithPath: "/Users/kven/Music")
//        recurse(dir)
//        opQueue.waitUntilAllOperationsAreFinished()
//        
//        print("Num: \(map.map)")
        
//        SearchWindowController.shared.showWindow(self)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            colorSchemesManager.printNumObservers()
//            fontSchemesManager.printNumObservers()
//        }
    }
    
    let opQueue = OperationQueue()
    var fileCtr: AtomicIntCounter = .init()
    var ctr: AtomicIntCounter = .init()
    var sizeCtr: AtomicIntCounter = .init()
    
    var map: ConcurrentMap<String, Int> = .init()
//    var fileCtr: Int = 0
//    var ctr: Int = 0
//    var sizeCtr: Int = 0
    
    private func recurse(_ dir: URL) {
        
//        for file in dir.children ?? [] {
//            
//            if file.isDirectory {
//                
//                recurse(file)
//                continue
//            }
//            
//            self.fileCtr.increment()
//            
//            //            if file.lowerCasedExtension != "mp3" {continue}
//            let ext = file.lowerCasedExtension
//            if !SupportedTypes.allAudioExtensions.contains(ext) {continue}
//            
//            opQueue.addOperation {
//                
//                if let art = fileReader.getArt(for: file) {
//                    
//                    let data = art.imageData
//                    
//                    self.map[ext] = (self.map[ext] ?? 0) + 1
////                    
////                    var idCtr = 1
////                    
////                    self.ctr.increment()
////                    let size = data.count
//////                    self.sizeCtr = self.sizeCtr + size
////                    var base = URL(fileURLWithPath: "/Users/kven/meta-cache/")
////                    var fn = file.deletingPathExtension().lastPathComponent
////                    var dest = base.appendingPathComponent(fn + "\(idCtr).\(ext)")
////                    
////                    while dest.exists {
////                        
////                        idCtr.increment()
////                        dest = base.appendingPathComponent(fn + "\(idCtr).\(ext)")
////                    }
////                    
////                    print("Copying to: \(dest.path)")
////                    
////                    try! FileManager.default.copyItem(at: file, to: dest)
////                    
////                    if self.fileCtr.value % 100 == 0 {
////                        print("Processed \(self.fileCtr) values")
////                    }
//                }
//            }
//        }
    }

    /// Opens the application with a single file (audio file or playlist)
    public func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        
        self.application(sender, openFiles: [filename])
        return true
    }
    
    /// Opens the application with a set of files (audio files or playlists)
    public func application(_ sender: NSApplication, openFiles filenames: [String]) {
        openApp(withFiles: filenames)
    }
    
    /// Tears down app components in preparation for app termination.
    func applicationWillTerminate(_ aNotification: Notification) {
        
        // Broadcast a notification to all app components that the app will exit.
        // This call is synchronous, i.e. it will block till all observers have
        // finished saving their state or performing any cleanup.
        messenger.publish(.Application.willExit)
        
        // Perform a final shutdown.
        tearDown()
    }
}
