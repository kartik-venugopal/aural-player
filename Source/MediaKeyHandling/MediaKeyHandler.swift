import Cocoa

/*
    Handler that responds to macOS media keys (play/pause, next, previous)
 */
class MediaKeyHandler: MediaKeyTapDelegate, MessageSubscriber {
    
    private var preferences: ControlsPreferences
    
    private var mediaKeyTap: MediaKeyTap?
    private var monitoringEnabled: Bool = false
    
    private var lastEvent: KeyEvent?
    
    private var keyRepeatInterval_msecs: Int {
        
        switch preferences.repeatSpeed {
            
        case .slow:
            
            return 1000
            
        case .medium:
            
            return 500
            
        case .fast:
            
            return 250
        }
    }
    
    // Recurring task used to repeat key press events according to the preferred repeat speed
    private var repeatExecutor: RepeatingTaskExecutor?
    
    init(_ preferences: ControlsPreferences) {
        
        self.preferences = preferences
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
                
                DispatchQueue.main.async {
                    SyncMessenger.publishActionMessage(PlaybackActionMessage(.playOrPause))
                }
            }
            
        default:
            
            switch preferences.skipKeyBehavior {
                
            case .hybrid:
                
                handleHybrid(mediaKey, event)
                
            case .trackChangesOnly:
                
                handleTrackChangesOnly(mediaKey, event)
                
            case .seekingOnly:
                
                handleSeekingOnly(mediaKey, event)
            }
        }
    }
    
    private func handleHybrid(_ mediaKey: MediaKey, _ event: KeyEvent) {
        
        let isFwd: Bool = mediaKey == .fastForward || mediaKey == .next
        
        // Only do this on keyDown, if it is being repeated
        if event.keyPressed && event.keyRepeat {
            
            // Seeking (repeated)
            if repeatExecutor == nil {
                
                repeatExecutor = RepeatingTaskExecutor(intervalMillis: keyRepeatInterval_msecs, task: {
                    
                    SyncMessenger.publishActionMessage(PlaybackActionMessage(isFwd ? .seekForward : .seekBackward))
                    
                }, queue: DispatchQueue.main)
                
                repeatExecutor?.startOrResume()
            }
            
        } else // Only do this on keyUp, if the last key event was keyDown, and was not a repeat
            if !event.keyPressed, let lastEvent = lastEvent, lastEvent.keyPressed && !lastEvent.keyRepeat {
                
                // Change track
                DispatchQueue.main.async {
                    SyncMessenger.publishActionMessage(PlaybackActionMessage(isFwd ? .nextTrack : .previousTrack))
                }
                
            } else if !event.keyPressed, let lastEvent = lastEvent, lastEvent.keyPressed && lastEvent.keyRepeat {
                
                // Key up after repeating ... invalidate the repeating task
                repeatExecutor?.stop()
                repeatExecutor = nil
        }
        
        
        lastEvent = event
    }
    
    private func handleTrackChangesOnly(_ mediaKey: MediaKey, _ event: KeyEvent) {
        
        let isFwd: Bool = mediaKey == .fastForward || mediaKey == .next
        
        if event.keyPressed && !event.keyRepeat {
            
            DispatchQueue.main.async {
                SyncMessenger.publishActionMessage(PlaybackActionMessage(isFwd ? .nextTrack : .previousTrack))
            }
            
            // Only do this on keyDown, if it is being repeated
        } else if event.keyPressed && event.keyRepeat {
            
            if repeatExecutor == nil {
                
                repeatExecutor = RepeatingTaskExecutor(intervalMillis: keyRepeatInterval_msecs, task: {
                    
                    SyncMessenger.publishActionMessage(PlaybackActionMessage(isFwd ? .nextTrack : .previousTrack))
                    
                }, queue: DispatchQueue.main)
                
                repeatExecutor?.startOrResume()
            }
            
        } else if !event.keyPressed, let lastEvent = lastEvent, lastEvent.keyPressed && lastEvent.keyRepeat {
            
            // Key up after repeating ... invalidate the repeating task
            repeatExecutor?.stop()
            repeatExecutor = nil
        }
        
        lastEvent = event
    }
    
    private func handleSeekingOnly(_ mediaKey: MediaKey, _ event: KeyEvent) {
        
        let isFwd: Bool = mediaKey == .fastForward || mediaKey == .next
        
        if event.keyPressed && !event.keyRepeat {
            
            DispatchQueue.main.async {
                SyncMessenger.publishActionMessage(PlaybackActionMessage(isFwd ? .seekForward : .seekBackward))
            }
            
            // Only do this on keyDown, if it is being repeated
        } else if event.keyPressed && event.keyRepeat {
            
            if repeatExecutor == nil {
                
                repeatExecutor = RepeatingTaskExecutor(intervalMillis: keyRepeatInterval_msecs, task: {
                    
                    SyncMessenger.publishActionMessage(PlaybackActionMessage(isFwd ? .seekForward : .seekBackward))
                    
                }, queue: DispatchQueue.main)
                
                repeatExecutor?.startOrResume()
            }
            
        } else if !event.keyPressed, let lastEvent = lastEvent, lastEvent.keyPressed && lastEvent.keyRepeat {
            
            // Key up after repeating ... invalidate the repeating task
            repeatExecutor?.stop()
            repeatExecutor = nil
        }
        
        lastEvent = event
    }
}
