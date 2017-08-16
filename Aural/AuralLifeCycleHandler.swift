import Foundation

/*
    Contract for a class that handles application life cycle events
 */
protocol AuralLifeCycleHandler {
    
    // Invoked when the application has just loaded. Does any necessary initialization like loading persisted app state.
    func appLoaded()
    
    // Invoked when the application is about to exit. Does any deallocation that is required before the app exits
    // This includes saving "remembered" player state and releasing player resources
    // The uiState parameter contains all UI state that needs to be persisted.
    func appExiting(_ uiState: UIState)
}
