import Cocoa

class LazyWindowLoader<T>: Destroyable where T: NSWindowController, T: Destroyable {
    
    lazy var controller: T = {
        
        windowLoaded = true
        return T.init()
    }()
    
    lazy var window: NSWindow = controller.window!
    
    var windowLoaded: Bool = false
    
    func destroy() {
        
        if windowLoaded {
            controller.destroy()
        }
    }
}
