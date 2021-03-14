import Cocoa

class AppModeManager: NotificationSubscriber {
    
    let subscriberId: String = "AppModeManager"
    
    private static let subscriber: AppModeManager = AppModeManager()
    
    static var mode: AppMode = AppDefaults.appMode
    
    private static var regularMode: RegularAppModeController = RegularAppModeController()
    
    private static var statusBarMode: StatusBarAppModeController = StatusBarAppModeController()
    
    static func initialize() {
        
//        SyncMessenger.subscribe(actionTypes: [.regularAppMode, .statusBarAppMode, .miniBarAppMode], subscriber: subscriber)
//        SyncMessenger.subscribe(actionTypes: [.regularAppMode], subscriber: subscriber)
    }
    
    static func presentMode(_ newMode: AppMode) {
        
        mode = newMode
        
        switch mode {
            
        case .regular:  presentRegularMode()
        
        case .statusBar: presentStatusBarMode()
        
        }
        
        // TODO: This will cause initSubscriptions to be called twice !
//        SyncMessenger.publishNotification(AppModeChangedNotification(newMode))
    }
    
    static func switchToMode(_ newMode: AppMode) {
        
        switch mode {
            
        case .regular:  regularMode.dismissMode()
            
        case .statusBar: statusBarMode.dismissMode()
            
        }
        
        presentMode(newMode)
//        SyncMessenger.publishNotification(AppModeChangedNotification(newMode))
    }
    
    static func registerConstituentView(_ appMode: AppMode, _ view: ConstituentView) {
        
        switch appMode {
            
        case .regular: regularMode.registerConstituentView(view)
            
        case .statusBar:    statusBarMode.registerConstituentView(view)
            
        }
    }
    
    private static func presentRegularMode() {
        regularMode.presentMode()
    }
    
    private static func presentStatusBarMode() {
        statusBarMode.presentMode()
    }
    
    
    
    // MARK: Message handling
    
//    func consumeMessage(_ message: ActionMessage) {
//
//        switch message.actionType {
//
//        case .regularAppMode:   AppModeManager.switchToMode(.regular)
//
////        case .statusBarAppMode: AppModeManager.switchToMode(.statusBar)
////
////        case .miniBarAppMode:   AppModeManager.switchToMode(.miniBar)
//
//        default: return
//
//        }
//    }
}

enum AppMode: String {
    
    case regular
    case statusBar
}

protocol AppModeController {
    
    var mode: AppMode {get}
    
    func presentMode()
    
    func dismissMode()
    
    func registerConstituentView(_ view: ConstituentView)
}
