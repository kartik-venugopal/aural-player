import Foundation

/*
    Contract for a class that handles application life cycle events and is invoked by the UI layer.
 */
protocol AuralLifeCycleHandler {
    
    // Invoked when the application has just loaded. Loads persisted app state, and returns it.
    func appLoaded() -> UIAppState

    // Invoked when the application is about to exit. Does any deallocation that is required before the app exits
    // This includes saving "remembered" app state and releasing resources
    // The uiState parameter contains all UI state that needs to be persisted.
    func appExiting(_ uiState: UIState)
}
