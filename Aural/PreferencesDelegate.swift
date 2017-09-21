import Foundation

/*
    Concrete implementation of PreferencesDelegateProtocol
 */
class PreferencesDelegate: PreferencesDelegateProtocol {
    
    private let preferences: Preferences
    
    init(_ preferences: Preferences) {
        self.preferences = preferences
    }
    
    func getPreferences() -> Preferences {
        return preferences
    }
    
    func savePreferences(_ preferences: Preferences) {
        
        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            Preferences.persist(preferences)
        }
    }
}
