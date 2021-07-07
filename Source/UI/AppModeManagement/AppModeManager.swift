//
//  AppModeManager.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class AppModeManager {
    
    static var mode: AppMode = .windowed
    
    private static var windowedMode: WindowedAppModeController = WindowedAppModeController()
    
    private static var menuBarMode: MenuBarAppModeController = MenuBarAppModeController()
    
    private static var controlBarMode: ControlBarAppModeController = ControlBarAppModeController()
    
    static func presentApp(lastPresentedAppMode: AppMode?, preferences: ViewPreferences) {
        
        if preferences.appModeOnStartup.option == .specific,
           let appMode = preferences.appModeOnStartup.mode {
            
            presentMode(appMode)
            
        } else {    // Remember from last app launch.
            presentMode(lastPresentedAppMode ?? .defaultMode)
        }
    }
    
    static func presentMode(_ newMode: AppMode) {
        
        dismissCurrentMode()
        
        switch newMode {
        
        case .windowed:  windowedMode.presentMode(transitioningFromMode: mode)
        
        case .menuBar: menuBarMode.presentMode(transitioningFromMode: mode)
            
        case .controlBar:   controlBarMode.presentMode(transitioningFromMode: mode)
        
        }
        
        mode = newMode
    }
    
    private static func dismissCurrentMode() {
        
        switch mode {
            
        case .windowed:  windowedMode.dismissMode()
            
        case .menuBar: menuBarMode.dismissMode()
            
        case .controlBar:   controlBarMode.dismissMode()
            
        }
    }
}

protocol AppModeController {
    
    var mode: AppMode {get}
    
    func presentMode(transitioningFromMode previousMode: AppMode)
    
    func dismissMode()
}
