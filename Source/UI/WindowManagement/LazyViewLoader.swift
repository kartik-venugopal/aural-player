import Cocoa

class LazyViewLoader<T>: Destroyable where T: NSViewController, T: Destroyable {
    
    lazy var controller: T = {
        
        viewLoaded = true
        return T.init()
    }()
    
    lazy var view: NSView = controller.view
    
    var viewLoaded: Bool = false
    
    func destroy() {
        
        if viewLoaded {
            controller.destroy()
        }
    }
}
