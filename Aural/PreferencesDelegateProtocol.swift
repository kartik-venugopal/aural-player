import Foundation

/*
    Contract for a middleman/delegate to perform CRUD of user preferences
 */
protocol PreferencesDelegateProtocol {
   
    // Retrieve all user preferences
    func getPreferences() -> Preferences
    
    // Persist the given user preferences to disk
    func savePreferences(_ preferences: Preferences)
}
