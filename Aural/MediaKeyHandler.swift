import Cocoa

class MediaKeyHandler: MediaKeyTapDelegate, MessageSubscriber {
    
    var mediaKeyTap: MediaKeyTap?
    
    init() {
        SyncMessenger.subscribe(messageTypes: [.appLoadedNotification], subscriber: self)
    }
    
    var subscriberId: String {
        return "MediaKeyHandler"
    }
    
    func startMonitoring() {
        
        mediaKeyTap = MediaKeyTap(delegate: self, on: .keyDownAndUp)
        mediaKeyTap?.start()
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if (notification is AppLoadedNotification) {
            startMonitoring()
        }
    }
    
    func handle(mediaKey: MediaKey, event: KeyEvent) {
        
//        print(event.\)
     
        switch mediaKey {
            
        case .playPause:
            print("\nAYYAPPA MUTHUSAMI !!!")
            NSLog("Play/pause pressed")
        case .previous:
            NSLog("Previous pressed")
        case .rewind:
            NSLog("Rewind pressed")
        case .next:
            NSLog("Next pressed")
        case .fastForward:
            NSLog("Fast Forward pressed")
        }
    }
}
