import Cocoa

class StatusBarAppModeController: NSObject, AppModeController, NSMenuDelegate, NotificationSubscriber {

    var mode: AppMode {.statusBar}

    private var statusItem: NSStatusItem?
    private var controller: StatusBarViewController!
    
    private lazy var appIcon: NSImage = NSImage(named: "AppIcon-StatusBar")!
    
    func presentMode(transitioningFromMode previousMode: AppMode?) {
        
        controller = StatusBarViewController()

        // Make app run in status bar and make it active.
        NSApp.setActivationPolicy(.accessory)
        NSApp.activate(ignoringOtherApps: true)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.button?.image = appIcon
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            statusItem?.button?.toolTip = "Aural Player v\(appVersion)"
        } else {
            statusItem?.button?.toolTip = "Aural Player"
        }
        
        let menu = NSMenu()
        
        let menuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        menuItem.view = controller.view
        
        menu.addItem(menuItem)
        menu.delegate = self
        
        statusItem?.menu = menu
    }
    
    func menuDidClose(_ menu: NSMenu) {
        controller?.statusBarMenuClosed()
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        controller.statusBarMenuOpened()
    }
    
    func dismissMode() {
        
        controller?.destroy()
     
        if let statusItem = self.statusItem {
            
            statusItem.menu?.cancelTracking()
            statusItem.menu = nil
            
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
        }
        
        controller = nil
    }
}

protocol StatusBarMenuObserver {
    
    func statusBarMenuOpened()
    
    func statusBarMenuClosed()
}
