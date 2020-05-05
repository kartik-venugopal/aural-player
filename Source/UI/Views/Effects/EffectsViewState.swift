// Convenient accessor for information about the effects view
class EffectsViewState {
    
    static var textSize: TextSize = .normal
    
    static func initialize(_ appState: EffectsUIState) {
        textSize = appState.textSize
    }
    
    static var persistentState: EffectsUIState {
        
        let state = EffectsUIState()
        state.textSize = textSize
        
        return state
    }
}
