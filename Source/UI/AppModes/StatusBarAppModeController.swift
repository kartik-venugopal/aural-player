import Cocoa

class StatusBarAppModeController: AppModeController {

    var mode: AppMode {return .statusBar}

//    private lazy var statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
//    private lazy var statusBarViewController: StatusBarViewController = ViewFactory.statusBarViewController
    
    func presentMode() {
        
//        NSApp.setActivationPolicy(.accessory)
//
//        statusItem.button?.image = NSImage(named: "AppIcon-StatusBar")
//        let menu = NSMenu()
//        let item1 = NSMenuItem(title: "", action: nil, keyEquivalent: "")
//        item1.view = statusBarViewController.view
//        menu.addItem(item1)
//        statusItem.menu = menu
    }
    
    func dismissMode() {
//        statusBarViewController.dismiss()
    }
    
    func registerConstituentView(_ view: ConstituentView) {
        
    }
}
