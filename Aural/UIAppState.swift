/*
    Encapsulates all application state, with values that are marshaled into a format directly usable by the UI, based on user preferences.
 */

import Foundation

class UIAppState {
    
//    var showPlaylist: Bool
//    var showEffects: Bool
//    
//    var windowLocationOnStartup: WindowLocationOnStartup
//    var windowLocationXY: NSPoint?
    
    init(_ appState: AppState, _ preferences: Preferences) {
        
//        if (preferences.viewPreferences.viewOnStartup.option == .rememberFromLastAppLaunch) {
//            
//            self.showPlaylist = appState.uiState.showPlaylist
//            self.showEffects = appState.uiState.showEffects
//            
//        } else {
//            
//            let viewType = preferences.viewPreferences.viewOnStartup.viewType
//            self.showPlaylist = viewType == .effectsOnly || viewType == .compact
//            self.hideEffects = viewType == .playlistOnly || viewType == .compact
//        }
//        
//        if (preferences.viewPreferences.playlistLocationOnStartup.option == .rememberFromLastAppLaunch) {
//            
//            self.playlistLocation = appState.uiState.playlistLocation
//            
//        } else {
//            
//            self.playlistLocation = preferences.viewPreferences.playlistLocationOnStartup.playlistLocation
//        }
//        
//        self.windowLocationOnStartup = preferences.viewPreferences.windowLocationOnStartup
//        
//        if (preferences.viewPreferences.windowLocationOnStartup.option == .rememberFromLastAppLaunch) {
//            
//            self.windowLocationXY = NSPoint(x: CGFloat(appState.uiState.windowLocationX), y: CGFloat(appState.uiState.windowLocationY))
//        }
    }
}
