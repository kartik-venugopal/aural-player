import Foundation

class PreferencesDelegate: PreferencesDelegateProtocol {
    
    private let preferences: Preferences
    
    init(_ preferences: Preferences) {
        self.preferences = preferences
    }
    
    func getPreferences() -> Preferences {
        return preferences
    }
    
    func savePreferences(_ preferences: Preferences) {
        
        // Don't block the calling thread
        DispatchQueue.global(qos: .userInitiated).async {
            Preferences.persist(preferences)
        }
    }
}
