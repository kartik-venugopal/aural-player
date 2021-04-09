import AVFoundation

/*
     Represents a playback session, which begins with either the user requesting a new track (by clicking Play/Next track/Previous track/Play selected track) or the player plays the next track in the sequence upon completion of the previous one. The session ends when a new request is received or playback of the current session completes.
     
     The lifecycle of a session is as follows:
     
     start() -> Session is now current
     end() -> Session is no longer current. There is no current session.
     
     If a new session is started while the current one is still active (playing), the old one is implicitly ended, and the new session becomes both current. In other words, the following code will start session1, then start session2, ending session1 ...
     
     start() -> starts session1
     start() -> starts session2, ending session1
 
 */
class PlaybackSession: Hashable {
    
    // Holds the current playback session
    private(set) static var currentSession: PlaybackSession?
    
    // The track associated with this session
    let track: Track
    
    // A->B playback loop, if there is one
    private(set) var loop: PlaybackLoop?
    
    // Time interval since last boot (i.e. system uptime), at start of track playback (i.e. 0 seconds elapsed). Used to determine when track began playing.
    let timestamp: TimeInterval
    
    // Unique ID (i.e. UUID) ... used to differentiate two PlaybackSession objects
    let id: String
    
    private init(_ track: Track) {
        
        self.timestamp = ProcessInfo.processInfo.systemUptime
        self.track = track
        self.id = UUID().uuidString
    }
    
    private init(_ track: Track, _ timestamp: TimeInterval) {
        
        self.timestamp = timestamp
        self.track = track
        self.id = UUID().uuidString
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func hasCompleteLoop() -> Bool {
        return loop?.isComplete ?? false
    }
    
    func hasLoop() -> Bool {
        return loop != nil
    }
    
    // Creates an identical copy of this PlaybackSession object.
    // NOTE - Copy will have a different id (this is intended).
    private func createCopy() -> PlaybackSession {
        
        let copy = PlaybackSession(self.track, self.timestamp)
        copy.loop = self.loop
        
        return copy
    }
    
    // MARK: Static functions
    
    static func == (lhs: PlaybackSession, rhs: PlaybackSession) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Start a new session, implicitly invalidating the old one (if there was one), and returns it. This function should be called when beginning playback of a track.
    static func start(_ track: Track) -> PlaybackSession {
        
        currentSession = PlaybackSession(track)
        return currentSession!
    }
    
    static func duplicateSessionAndMakeCurrent(_ session: PlaybackSession) -> PlaybackSession {
        
        currentSession = session.createCopy()
        return currentSession!
    }
    
    // Start a new session, creating a copy of the current one (if one is defined), implicitly invalidating the old one (if there was one), and returns it. This function should be called when continuing playback of a track (i.e. seeking or toggling a loop).
    //
    // NOTE - If there is no session currently defined, this function will not create one ... it will return nil. So, this function is also an indirect way to check if a track is currently playing.
    static func startNewSessionForPlayingTrack() -> PlaybackSession? {
        
        if let curSession = currentSession {
            currentSession = curSession.createCopy()
        }
        
        return currentSession
    }
    
    // End the current session. Returns the ended session so that callers may potentially use it to hand off information to the next session (e.g. segment loop)
    static func endCurrent() -> PlaybackSession? {
        
        let endedSession = currentSession
        currentSession = nil
        return endedSession
    }
    
    // Compares the current session to a given session for equality
    static func isCurrent(_ session: PlaybackSession) -> Bool {
        return session == currentSession
    }
    
    static func hasCurrentSession() -> Bool {
        return currentSession != nil
    }
    
    // Marks the start point for a track segment playback loop
    static func beginLoop(_ loopStartTime: Double) {
        currentSession?.loop = PlaybackLoop(loopStartTime)
    }
    
    // Marks the end point for a track segment playback loop
    static func endLoop(_ loopEndTime: Double) {
        currentSession?.loop?.endTime = loopEndTime
    }
    
    // Marks the start and end point for a track segment playback loop
    static func defineLoop(_ loopStartTime: Double, _ loopEndTime: Double, _ isChapterLoop: Bool = false) {
        currentSession?.loop = PlaybackLoop(loopStartTime, loopEndTime, isChapterLoop)
    }
    
    // Removes a track segment playback loop
    static func removeLoop() {
        currentSession?.loop = nil
    }
    
    static func hasLoop() -> Bool {
        return currentSession?.loop != nil
    }
    
    static func hasCompleteLoop() -> Bool {
        return currentSession?.hasCompleteLoop() ?? false
    }
    
    // Retrieves the track segment playback loop for the current playback session
    static var currentLoop: PlaybackLoop? {
        return currentSession?.loop
    }
}
