import Cocoa

class AppModeManager: ActionMessageSubscriber {
    
    private static let subscriber: AppModeManager = AppModeManager()
    
    static var mode: AppMode = AppDefaults.appMode
    
    private static var regularMode: RegularAppModeController = RegularAppModeController()
    
    private static var statusBarMode: StatusBarAppModeController = StatusBarAppModeController()
    
    private static var miniBarMode: MiniBarAppModeController = MiniBarAppModeController()
    
    static func initialize() {
        
        SyncMessenger.subscribe(actionTypes: [.regularAppMode, .statusBarAppMode, .miniBarAppMode], subscriber: subscriber)
    }
    
    static func presentMode(_ newMode: AppMode) {
        
        mode = newMode
        
        switch mode {
            
        case .regular:  presentRegularMode()
        
        case .miniBar: presentMiniBarMode()
        
        case .statusBar: presentStatusBarMode()
        
        }
        
        // TODO: This will cause initSubscriptions to be called twice !
        SyncMessenger.publishNotification(AppModeChangedNotification(newMode))
    }
    
    static func switchToMode(_ newMode: AppMode) {
        
        switch mode {
            
        case .regular:  regularMode.dismissMode()
            
        case .miniBar: miniBarMode.dismissMode()
            
        case .statusBar: statusBarMode.dismissMode()
            
        }
        
        presentMode(newMode)
//        SyncMessenger.publishNotification(AppModeChangedNotification(newMode))
    }
    
    static func registerConstituentView(_ appMode: AppMode, _ view: ConstituentView) {
        
        switch appMode {
            
        case .regular: regularMode.registerConstituentView(view)
            
        case .miniBar:  miniBarMode.registerConstituentView(view)
            
        case .statusBar:    statusBarMode.registerConstituentView(view)
            
        }
    }
    
    private static func presentRegularMode() {
        regularMode.presentMode()
    }
    
    private static func presentMiniBarMode() {
        miniBarMode.presentMode()
    }
    
    private static func presentStatusBarMode() {
        statusBarMode.presentMode()
    }
    
    func getID() -> String {
        return "AppModeManager"
    }
    
    // MARK: Message handling
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .regularAppMode:   AppModeManager.switchToMode(.regular)
            
        case .statusBarAppMode: AppModeManager.switchToMode(.statusBar)
            
        case .miniBarAppMode:   AppModeManager.switchToMode(.miniBar)
            
        default: return
            
        }
    }
}

enum AppMode: String {
    
    case regular
    case statusBar
    case miniBar
}

protocol AppModeController {
    
    var mode: AppMode {get}
    
    func presentMode()
    
    func dismissMode()
    
    func registerConstituentView(_ view: ConstituentView)
}
