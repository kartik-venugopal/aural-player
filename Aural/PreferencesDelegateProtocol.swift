import Foundation

protocol PreferencesDelegateProtocol {
    
    func getPreferences() -> Preferences
    
    func savePreferences(_ preferences: Preferences)
}
