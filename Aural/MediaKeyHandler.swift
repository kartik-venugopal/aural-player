import Cocoa

class MediaKeyHandler: MediaKeyTapDelegate, MessageSubscriber {
    
    private var preferences: ControlsPreferences = ObjectGraph.preferences.controlsPreferences
    
    private var mediaKeyTap: MediaKeyTap?
    private var lastEvent: KeyEvent?
    
    private var monitoringEnabled: Bool = false
    
    init() {
        SyncMessenger.subscribe(messageTypes: [.appLoadedNotification], subscriber: self)
    }
    
    var subscriberId: String {
        return "MediaKeyHandler"
    }
    
    func startMonitoring() {
        
        if !monitoringEnabled {
            
            if mediaKeyTap == nil {
                mediaKeyTap = MediaKeyTap(delegate: self, on: .keyDownAndUp)
            }
            
            mediaKeyTap?.start()
            monitoringEnabled = true
        }
    }
    
    func stopMonitoring() {
        
        if monitoringEnabled {
            
            mediaKeyTap?.stop()
            monitoringEnabled = false
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if notification is AppLoadedNotification && preferences.respondToMediaKeys {
            startMonitoring()
        }
    }
    
    func handle(mediaKey: MediaKey, event: KeyEvent) {
        
        switch mediaKey {
            
        case .playPause:
            
            // Only do this on keyDown
            if event.keyPressed {
                SyncMessenger.publishActionMessage(PlaybackActionMessage(.playOrPause))
            }
            
        case .previous, .rewind:
            
            // Only do this on keyDown, if it is being repeated
            if event.keyPressed && event.keyRepeat {
                
                // Seek backward
                SyncMessenger.publishActionMessage(PlaybackActionMessage(.seekBackward))
                
            } else // Only do this on keyUp, if the last key event was keyDown, and was not a repeat
                if !event.keyPressed, let lastEvent = lastEvent, lastEvent.keyPressed && !lastEvent.keyRepeat {
                
                // Previous track
                SyncMessenger.publishActionMessage(PlaybackActionMessage(.previousTrack))
            }
            
        case .fastForward, .next:
            
            // Only do this on keyDown, if it is being repeated
            if event.keyPressed && event.keyRepeat {
                
                // Seek forward
                SyncMessenger.publishActionMessage(PlaybackActionMessage(.seekForward))
                
            } else // Only do this on keyUp, if the last key event was keyDown, and was not a repeat
                if !event.keyPressed, let lastEvent = lastEvent, lastEvent.keyPressed && !lastEvent.keyRepeat {
                
                // Next track
                SyncMessenger.publishActionMessage(PlaybackActionMessage(.nextTrack))
            }
        }
        
        lastEvent = event
    }
}
