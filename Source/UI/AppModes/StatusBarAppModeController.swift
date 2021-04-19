import Cocoa

class StatusBarAppModeController: NSObject, AppModeController, NSMenuDelegate {

    var mode: AppMode {return .statusBar}

    private var statusItem: NSStatusItem?
    private lazy var statusBarViewController: StatusBarViewController = ViewFactory.statusBarViewController
    
    func presentMode() {
        
        NSApp.setActivationPolicy(.accessory)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.button?.image = NSImage(named: "AppIcon-StatusBar")
        
        let menu = NSMenu()
        
        let menuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        menuItem.view = statusBarViewController.view
        
        menu.addItem(menuItem)
        menu.delegate = self
        
        statusItem?.menu = menu
    }
    
    func menuDidClose(_ menu: NSMenu) {
        statusBarViewController.statusBarMenuClosed()
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        statusBarViewController.statusBarMenuOpened()
    }
    
    func dismissMode() {
     
        if let statusItem = self.statusItem {
            
            statusItem.menu?.cancelTracking()
            statusItem.menu = nil
            
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
        }
    }
}

protocol StatusBarMenuObserver {
    
    func statusBarMenuOpened()
    func statusBarMenuClosed()
}
