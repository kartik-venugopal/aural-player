import Foundation

//protocol MessageSubscriber {
//
//    var subscriberId: String {get}
//}

extension Notification.Name {
    
    static let appLaunched = Notification.Name("appLaunched")
    static let appReopened = Notification.Name("appReopened")
    static let appExitRequest = Notification.Name("appExitRequest")
    
    static let windowLayoutChanged = Notification.Name("windowLayoutChanged")
    
    static let trackAddedToFavorites = Notification.Name("trackAddedToFavorites")
    static let trackRemovedFromFavorites = Notification.Name("trackRemovedFromFavorites")
    
    static let historyUpdated = Notification.Name("historyUpdated")
    
    static let fxUnitActivated = Notification.Name("fxUnitActivated")
    
    static let playbackRateChanged = Notification.Name("playbackRateChanged")
    static let chapterChanged = Notification.Name("chapterChanged")
    static let playbackCompleted = Notification.Name("playbackCompleted")
    static let playTrack = Notification.Name("playTrack")
    static let chapterPlayback = Notification.Name("chapterPlayback")
    
    static let startedAddingTracks = Notification.Name("startedAddingTracks")
    static let doneAddingTracks = Notification.Name("doneAddingTracks")
    
    static let playlistTypeChanged = Notification.Name("playlistTypeChanged")
    static let selectSearchResult = Notification.Name("selectSearchResult")
    static let trackAdded = Notification.Name("trackAdded")
}

protocol NotificationPayload {
    
    var notificationName: Notification.Name {get}
}

class Messenger {
    
    static let notifCtr: NotificationCenter = NotificationCenter.default
    
    private static var subscriptions: [String: [Notification.Name: NSObjectProtocol]] = [:]
    
//    static func printSubs() {
//        print("\nMessenger subscriptions:\n\n", subscriptions)
//    }
    
    // With payload
    static func publish<P>(_ payload: P) where P: NotificationPayload {
        
        var notification = Notification(name: payload.notificationName)
        notification.payload = payload
        
        notifCtr.post(notification)
    }
    
    // No payload
    static func publish(_ notifName: Notification.Name) {
        notifCtr.post(Notification(name: notifName))
    }
    
    // With payload
    static func subscribe<P>(_ subscriber: MessageSubscriber, _ notifName: Notification.Name, _ msgHandler: @escaping (P) -> Void,
                             filter: ((P) -> Bool)? = nil, opQueue: OperationQueue? = nil) where P: NotificationPayload {
        
        subscribe(subscriber.subscriberId, notifName, msgHandler, filter: filter, opQueue: opQueue)
    }
    
    // With payload
    static func subscribe<P>(_ subscriberId: String, _ notifName: Notification.Name, _ msgHandler: @escaping (P) -> Void,
                             filter: ((P) -> Bool)? = nil, opQueue: OperationQueue? = nil) where P: NotificationPayload {
        
        let observer = notifCtr.addObserver(forName: notifName, object: nil, queue: nil, using: { notif in
            
            if let payload = notif.payload as? P, filter?(payload) ?? true {
                msgHandler(payload)
            }
        })
        
        registerSubscription(subscriberId, notifName, observer)
        
        print("\nSubscribed subscriber:", subscriberId, "to notif:", notifName.rawValue)
    }
    
    // No payload
    static func subscribe(_ subscriber: MessageSubscriber, _ notifName: Notification.Name, _ msgHandler: @escaping () -> Void,
                          filter: (() -> Bool)? = nil, opQueue: OperationQueue? = nil) {
        
        subscribe(subscriber.subscriberId, notifName, msgHandler, filter: filter, opQueue: opQueue)
    }
    
    // No payload
    static func subscribe(_ subscriberId: String, _ notifName: Notification.Name, _ msgHandler: @escaping () -> Void,
                            filter: (() -> Bool)? = nil, opQueue: OperationQueue? = nil) {
        
        let observer = notifCtr.addObserver(forName: notifName, object: nil, queue: opQueue, using: { notif in
            
            if filter?() ?? true {
                msgHandler()
            }
        })
        
        registerSubscription(subscriberId, notifName, observer)
        
        print("\nSubscribed subscriber:", subscriberId, "to notif:", notifName.rawValue)
    }
    
    // With payload
    static func subscribeAsync<P>(_ subscriber: MessageSubscriber, _ notifName: Notification.Name, _ msgHandler: @escaping (P) -> Void,
                                  filter: ((P) -> Bool)? = nil, queue: DispatchQueue = DispatchQueue.main) where P: NotificationPayload {
        
        let observer = notifCtr.addObserver(forName: notifName, object: nil, queue: nil, using: { notif in
            
            if let payload = notif.payload as? P, filter?(payload) ?? true {
                
                queue.async {
                    msgHandler(payload)
                }
            }
        })
        
        registerSubscription(subscriber.subscriberId, notifName, observer)
        
        print("\nSubscribedAsync subscriber:", subscriber.subscriberId, "to notif:", notifName.rawValue)
    }
    
    // No payload
    static func subscribeAsync(_ subscriber: MessageSubscriber, _ notifName: Notification.Name, _ msgHandler: @escaping () -> Void,
                                  filter: (() -> Bool)? = nil, queue: DispatchQueue) {
        
        let observer = notifCtr.addObserver(forName: notifName, object: nil, queue: nil, using: { notif in
            
            if filter?() ?? true {
                
                queue.async {
                    msgHandler()
                }
            }
        })
        
        registerSubscription(subscriber.subscriberId, notifName, observer)
        
        print("\nSubscribedAsync subscriber:", subscriber.subscriberId, "to notif:", notifName.rawValue)
    }
    
    static func unsubscribe(_ subscriber: MessageSubscriber, _ notifName: Notification.Name) {
        
        if let subscriptionsForSubscriber = subscriptions[subscriber.subscriberId],
            let observer = subscriptionsForSubscriber[notifName] {
            
            notifCtr.removeObserver(observer)
        }
    }
    
    private static func registerSubscription(_ subscriberId: String, _ notifName: Notification.Name, _ observer: NSObjectProtocol) {
        
        if subscriptions[subscriberId] == nil {
            subscriptions[subscriberId] = [:]
        }
        
        subscriptions[subscriberId]![notifName] = observer
    }
}

extension Notification {
    
    var payload: NotificationPayload? {
        
        get {
            return userInfo?["_payload_"] as? NotificationPayload
        }
        
        set(newValue) {
            
            if let theValue = newValue {
                
                if userInfo == nil {
                    userInfo = [:]
                }
                
                userInfo!["_payload_"] = theValue
            }
        }
    }
}
