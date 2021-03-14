import Foundation

/*
    Contract for a middleman/delegate to perform CRUD of user preferences
 */
protocol PreferencesDelegateProtocol {
   
    // Retrieve all user preferences
    // When set, the given user preferences are persisted to disk
    var preferences: Preferences {get set}
}
