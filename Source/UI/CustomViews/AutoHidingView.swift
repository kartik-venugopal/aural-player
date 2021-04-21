import Cocoa

/*
    Utility to show and automatically hide a view after a brief interval (ex - feedback labels)
 */
class AutoHidingView: NSObject {
    
    // The view that is to be shown and auto-hidden
    let view: NSView
    
    // The time interval, specified in seconds, after which the view will be hidden, after it is shown
    let autoHideInterval: TimeInterval
    
    init(_ view: NSView, _ autoHideInterval: TimeInterval) {
        
        self.view = view
        self.autoHideInterval = autoHideInterval
    }

    // A unique ID used to validate async tasks
    private var callId: Int = 0
 
    // Show the view. If the view is already shown, the auto-hide time interval will be reset, invalidating the previous one.
    func showView() {
        
        view.show()
        
        // Capture the current callId into a token used later to validate the async task.
        let token = callId.incrementAndGet()

        // Run a task later, to hide the view. If multiple tasks are spawned in quick succession, only one of them (the most recent one) should run.
        DispatchQueue.main.asyncAfter(deadline: .now() + autoHideInterval, qos: .userInteractive, flags: .enforceQoS, execute: {[weak self] in
            
            // Execute this task only if the current callId matches the previously obtained token.
            if self?.callId == token {
                self?.view.hide()
            }
        })
    }
}
