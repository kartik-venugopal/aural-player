import Cocoa

class StatusBarAppModeController: NSObject, AppModeController, NSMenuDelegate {

    var mode: AppMode {return .statusBar}

    private var statusItem: NSStatusItem?
    
    private var controller: StatusBarViewController!
    
    func presentMode() {
        
        controller = StatusBarViewController()
        
        NSApp.setActivationPolicy(.accessory)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.button?.image = NSImage(named: "AppIcon-StatusBar")
        
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
        
        controller.destroy()
     
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

class SBMenuItem: NSMenuItem {
    
//    override func 
}
