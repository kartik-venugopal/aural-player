/*
    Represents a playback session, which begins with either the user requesting a new track (by clicking Play/Next track/Previous track/Play selected track) or the player plays the next track in the sequence upon completion of the previous one. The session ends when a new request is received or playback of the current session completes.
 
    The lifecycle of a session is as follows:
 
    start() -> session is both current and active
    end() -> session is current but no longer active
    invalidate() -> session is neither active nor current
 
    If a new session is started while the current one is still active (playing), the old one is implicitly invalidated, and the new session becomes both current and active. In other words, the following code will start session1, then start session2, invalidating session1 ...
    start() -> starts session1
    start() -> starts session2, invalidating session1
 
    TODO: Ensure thread-safety
 */

import Cocoa
import AVFoundation

class PlaybackSession {
    
    // Holds the current playback session
    static var currentSession: PlaybackSession? = nil
    
    // Time when the request for the session was initiated
    let timestamp: Date
    
    // The track associated with this session
    let track: IndexedTrack
    
    // Indicates whether the track is still playing (i.e. playback has not completed). When the track is finished playing, it is still current but no longer active. Once any final processing/cleanup has been done, it is invalidated and is no longer either active or current
    var active: Bool
    
    private init(_ track: IndexedTrack) {
        timestamp = Date()
        self.track = track
        
        // When a session is started, it is implicitly active
        self.active = true
    }
    
    // Start a new session, implicitly invalidating the old one (if there was one)
    static func start(_ track: IndexedTrack) {
        currentSession = PlaybackSession(track)
    }
    
    // End the given session
    static func end(_ session: PlaybackSession) {
        session.active = false
    }
    
    // Invalidate the current session
    static func invalidate() {
        currentSession = nil
    }
    
    // Compares the current session to a given session for equality
    static func isCurrent(_ session: PlaybackSession) -> Bool {
        return currentSession != nil && (session === currentSession)
    }
    
    // Compares the current session to a given session for equality and checks if that session is also active
    static func isCurrentAndActive(_ session: PlaybackSession) -> Bool {
        return isCurrent(session) && session.active
    }
}
