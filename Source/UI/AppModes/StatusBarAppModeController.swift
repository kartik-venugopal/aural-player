import Cocoa

class StatusBarAppModeController: NSObject, AppModeController, NSMenuDelegate {

    var mode: AppMode {return .statusBar}

    private lazy var statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private lazy var statusBarViewController: StatusBarViewController = ViewFactory.statusBarViewController
    
    func presentMode() {
        
        NSApp.setActivationPolicy(.accessory)

        statusItem.button?.image = NSImage(named: "AppIcon-StatusBar")
        let menu = NSMenu()
        
        let item1 = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        item1.view = statusBarViewController.view
        
        menu.addItem(item1)
        menu.delegate = self
        
        statusItem.menu = menu
    }
    
    func menuDidClose(_ menu: NSMenu) {
        statusBarViewController.statusBarMenuClosed()
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        statusBarViewController.statusBarMenuOpened()
    }
    
    func dismissMode() {
        statusBarViewController.dismiss()
    }
    
    func registerConstituentView(_ view: ConstituentView) {
        
    }
}

protocol StatusBarMenuObserver {
    
    func statusBarMenuOpened()
    func statusBarMenuClosed()
}
