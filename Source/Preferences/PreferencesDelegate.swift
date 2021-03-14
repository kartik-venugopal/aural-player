import Foundation

/*
    Concrete implementation of PreferencesDelegateProtocol
 */
class PreferencesDelegate: PreferencesDelegateProtocol {
    
    private var _preferences: Preferences
    
    var preferences: Preferences {
        
        get {
            return _preferences
        }
        
        set(newValue) {
            
            self._preferences = newValue
            
            // Perform asynchronously, to unblock the main thread
            DispatchQueue.global(qos: .userInitiated).async {
                Preferences.persist(self._preferences)
            }
        }
    }
    
    init(_ preferences: Preferences) {
        self._preferences = preferences
    }
}
