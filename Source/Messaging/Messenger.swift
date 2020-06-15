import Foundation

/*
    Contract for all subscribers of messages
 */
protocol MessageSubscriber {
    
    // A unique identifer for this subscriber (typically the class name and some instance identifier like hashValue)
    var subscriberId: String {get}
}

// Default implementations
extension MessageSubscriber {
    
    var subscriberId: String {
        
        let className = String(describing: mirrorFor(self).subjectType)
        
        if let obj = self as? NSObject {
            return String(format: "%@-%d", className, obj.hashValue)
        }
        
        return className
    }
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
    
    // With arbitrary object
    static func publish(_ notifName: Notification.Name, payload: Any) {
        
        var notification = Notification(name: notifName)
        notification.payload = payload
        
        notifCtr.post(notification)
    }
    
    // With payload
    static func subscribe<P>(_ subscriber: MessageSubscriber, _ notifName: Notification.Name, _ msgHandler: @escaping (P) -> Void,
                             filter: ((P) -> Bool)? = nil, opQueue: OperationQueue? = nil) where P: Any {
        
        subscribe(subscriber.subscriberId, notifName, msgHandler, filter: filter, opQueue: opQueue)
    }
    
    // With payload
    static func subscribe<P>(_ subscriberId: String, _ notifName: Notification.Name, _ msgHandler: @escaping (P) -> Void,
                             filter: ((P) -> Bool)? = nil, opQueue: OperationQueue? = nil) where P: Any {
        
        let observer = notifCtr.addObserver(forName: notifName, object: nil, queue: nil, using: { notif in
            
            if let payload = notif.payload as? P, filter?(payload) ?? true {
                msgHandler(payload)
            }
        })
        
        registerSubscription(subscriberId, notifName, observer)
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
    }
    
    // With payload
    static func subscribeAsync<P>(_ subscriber: MessageSubscriber, _ notifName: Notification.Name, _ msgHandler: @escaping (P) -> Void,
                                  filter: ((P) -> Bool)? = nil, queue: DispatchQueue) where P: Any {
        
        let observer = notifCtr.addObserver(forName: notifName, object: nil, queue: nil, using: { notif in
            
            queue.async {
            
                if let payload = notif.payload as? P, filter?(payload) ?? true {
                    msgHandler(payload)
                }
            }
        })
        
        registerSubscription(subscriber.subscriberId, notifName, observer)
    }
    
    // No payload
    static func subscribeAsync(_ subscriber: MessageSubscriber, _ notifName: Notification.Name, _ msgHandler: @escaping () -> Void,
                                  filter: (() -> Bool)? = nil, queue: DispatchQueue) {
        
        let observer = notifCtr.addObserver(forName: notifName, object: nil, queue: nil, using: { notif in
            
            queue.async {
                
                if filter?() ?? true {
                    msgHandler()
                }
            }
        })
        
        registerSubscription(subscriber.subscriberId, notifName, observer)
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
    
    var payload: Any? {
        
        get {
            return userInfo?["_payload_"]
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
