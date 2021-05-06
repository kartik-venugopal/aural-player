import Foundation

/*
    A thin wrapper around NotificationCenter that is used to dispatch notifications between app components. It does the following:
 
        - Wraps and unwraps payload objects in and from Notification objects, so clients can deal directly with relevant payload objects.
        - Provides a mechanism to allow clients to filter incoming notifications (and reject unwanted ones) based on any arbitrary criteria.
        - Allows notifications to be delivered on a desired queue either synchronously or asynchronously.
        - Provides methods that use publish/subscribe parlance.
 */
class Messenger {
    
    // The underlying NotificationCenter that is used for actual notification delivery.
    static let notifCtr: NotificationCenter = NotificationCenter.default
    
    typealias Observer = NSObjectProtocol
    
    // A map that keeps track of all subscriptions, structured as follows:
    // subscriberId -> [notificationName -> observer]
    // This is needed to be able to allow subscribers to unsubscribe.
    private static var subscriptions: [String: [Notification.Name: Observer]] = [:]
    
    /// Publishes a notification with an associated payload object that conforms to the NotificationPayload protocol.
    ///
    /// - Parameter payload: The payload object to be published (must conform to NotificationPayload)
    ///
    static func publish<P>(_ payload: P) where P: NotificationPayload {
        
        // The notification name is extracted from the payload object, and the payload
        // object is wrapped in a Notification which is then posted by the NotificationCenter.
        
        var notification = Notification(name: payload.notificationName)
        notification.payload = payload
        
        notifCtr.post(notification)
    }
    
    /// Publishes a notification with no associated payload.
    ///
    /// - Parameter notifName: The name for the notification to be published.
    ///
    static func publish(_ notifName: Notification.Name) {
        notifCtr.post(Notification(name: notifName))
    }
    
    /// Publishes a notification with an arbitrary associated payload object.
    ///
    /// - Parameter notifName:  The name for the notification to be published.
    ///
    /// - Parameter payload:    The (arbitrary) payload object to be published.
    ///
    static func publish(_ notifName: Notification.Name, payload: Any) {
        
        // The payload object is wrapped in a Notification which is then posted by the NotificationCenter.
        
        var notification = Notification(name: notifName)
        notification.payload = payload
        
        notifCtr.post(notification)
    }
    
    /// Subscribes a subscriber to synchronous notifications with the given notification name and an associated payload object,
    /// specifying a notification handler, an optional filtering function to reject unwanted notifications, and an optional OperationQueue on
    /// which to receive the notifications.
    ///
    /// - Warning:                  The incoming notification must have a payload object matching the type of the inferred generic type P;
    ///                             Otherwise, the notification handler will not be invoked.
    ///
    /// - Parameter P:              The (arbitrary) type of the payload object associated with the notification.
    ///
    /// - Parameter subscriber:     The subscriber that is subscribing to notifications.
    ///
    /// - Parameter notifName:      The name of the notification the subscriber wishes to subscribe to.
    ///
    /// - Parameter msgHandler:     The function that will handle receipt of notifications, with an arbitrary payload
    ///                             object as a parameter.
    ///
    /// - Parameter filter:         An optional function that, given the payload object, decides whether or not the handler should be invoked
    ///                             i.e. whether or not the subscriber is interested in handling this particular notification instance.
    ///                             May be nil (meaning all notifications will be passed onto the handler).
    ///
    /// - Parameter opQueue:        An optional OperatitonQueue on which to (synchronously) receive the incoming notifications.
    ///
    static func subscribe<P>(_ subscriber: NotificationSubscriber, _ notifName: Notification.Name, _ msgHandler: @escaping (P) -> Void,
                             filter: ((P) -> Bool)? = nil, opQueue: OperationQueue? = nil) where P: Any {
        
        // Wrap the provided handler function in a block that receives a Notification.
        // Extract the payload from the Notification, type-check it, and pass it onto
        // the handler, if the optionally provided filter allows it.
        
        let observer = notifCtr.addObserver(forName: notifName, object: nil, queue: opQueue, using: { notif in
            
            if let payload = notif.payload as? P {
                
                if filter?(payload) ?? true {
                    msgHandler(payload)
                }
                
            } else {
                
                if let payload = notif.payload {
                    
                    // Payload is non-nil, type mismatch
                
                    NSLog("Warning: Unable to deliver notification '%@' because of a payload type mismatch. Expected type: %@, but found type: %@", notifName.rawValue, String(describing: Mirror(reflecting: P.self).subjectType), String(describing: Mirror(reflecting: payload).subjectType))
                    
                } else {
                    
                    // No payload provided
                    NSLog("Warning: Unable to deliver notification '%@' because a payload of type %@ was expected but no payload was published.", notifName.rawValue, String(describing: Mirror(reflecting: P.self).subjectType))
                }
            }
        })
        
        registerSubscription(subscriber.subscriberId, notifName, observer)
    }
    
    /// Subscribes a subscriber to synchronous notifications with the given notification name and no associated payload object,
    /// specifying a notification handler, an optional filtering function to reject unwanted notifications, and an optional OperationQueue on
    /// which to receive the notifications.
    ///
    /// - Parameter subscriber:     The subscriber that is subscribing to notifications.
    ///
    /// - Parameter notifName:      The name of the notification the subscriber wishes to subscribe to.
    ///
    /// - Parameter msgHandler:     The function that will handle receipt of notifications.
    ///
    /// - Parameter filter:         An optional function that decides whether or not the handler should be invoked
    ///                             i.e. whether or not the subscriber is interested in handling this particular notification instance.
    ///                             May be nil (meaning all notifications will be passed onto the handler).
    ///
    /// - Parameter opQueue:        An optional OperatitonQueue on which to (synchronously) receive the incoming notifications.
    ///
    static func subscribe(_ subscriber: NotificationSubscriber, _ notifName: Notification.Name, _ msgHandler: @escaping () -> Void,
                          filter: (() -> Bool)? = nil, opQueue: OperationQueue? = nil) {
        
        // Wrap the provided handler function in a block that receives a Notification.
        // Invoke the handler, if the optionally provided filter allows it.
        
        let observer = notifCtr.addObserver(forName: notifName, object: nil, queue: opQueue, using: { notif in
            
            if filter?() ?? true {
                msgHandler()
            }
        })
        
        registerSubscription(subscriber.subscriberId, notifName, observer)
    }
    
    /// Subscribes a subscriber to asynchronous notifications with the given notification name and an associated payload object,
    /// specifying a notification handler, an optional filtering function to reject unwanted notifications, and a DispatchQueue on
    /// which to receive the notifications.
    ///
    /// - Parameter P:              The (arbitrary) type of the payload object associated with the notification.
    ///
    /// - Parameter subscriber:     The subscriber that is subscribing to notifications.
    ///
    /// - Parameter notifName:      The name of the notification the subscriber wishes to subscribe to.
    ///
    /// - Parameter msgHandler:     The function that will handle receipt of notifications, with an arbitrary payload
    ///                             object as a parameter.
    ///
    /// - Parameter filter:         An optional function that, given the payload object, decides whether or not the handler should be invoked
    ///                             i.e. whether or not the subscriber is interested in handling this particular notification instance.
    ///                             May be nil (meaning all notifications will be passed onto the handler).
    ///
    /// - Parameter opQueue:        A DispatchQueue on which to (asynchronously) receive the incoming notifications.
    ///
    static func subscribeAsync<P>(_ subscriber: NotificationSubscriber, _ notifName: Notification.Name, _ msgHandler: @escaping (P) -> Void,
                                  filter: ((P) -> Bool)? = nil, queue: DispatchQueue) where P: Any {
        
        // Wrap the provided handler function in a block that receives a Notification.
        // Extract the payload from the Notification, type-check it, and pass it onto
        // the handler, if the optionally provided filter allows it.
        
        let observer = notifCtr.addObserver(forName: notifName, object: nil, queue: nil, using: { notif in
            
            // Dispatch the notification asynchronously on the specified queue.
            queue.async {
            
                if let payload = notif.payload as? P {
                    
                    if filter?(payload) ?? true {
                        msgHandler(payload)
                    }
                    
                } else {
                    
                    if let payload = notif.payload {
                        
                        // Payload is non-nil, type mismatch
                    
                        NSLog("Warning: Unable to deliver notification '%@' because of a payload type mismatch. Expected type: %@, but found type: %@", notifName.rawValue, String(describing: Mirror(reflecting: P.self).subjectType), String(describing: Mirror(reflecting: payload).subjectType))
                        
                    } else {
                        
                        // No payload provided
                        NSLog("Warning: Unable to deliver notification '%@' because a payload of type %@ was expected but no payload was published.", notifName.rawValue, String(describing: Mirror(reflecting: P.self).subjectType))
                    }
                }
            }
        })
        
        registerSubscription(subscriber.subscriberId, notifName, observer)
    }
    
    /// Subscribes a subscriber to asynchronous notifications with the given notification name and no associated payload object,
    /// specifying a notification handler, an optional filtering function to reject unwanted notifications, and a DispatchQueue on
    /// which to receive the notifications.
    ///
    /// - Parameter subscriber:     The subscriber that is subscribing to notifications.
    ///
    /// - Parameter notifName:      The name of the notification the subscriber wishes to subscribe to.
    ///
    /// - Parameter msgHandler:     The function that will handle receipt of notifications, with an arbitrary payload
    ///                             object as a parameter.
    ///
    /// - Parameter filter:         An optional function that, given the payload object, decides whether or not the handler should be invoked
    ///                             i.e. whether or not the subscriber is interested in handling this particular notification instance.
    ///                             May be nil (meaning all notifications will be passed onto the handler).
    ///
    /// - Parameter opQueue:        A DispatchQueue on which to (asynchronously) receive the incoming notifications.
    ///
    static func subscribeAsync(_ subscriber: NotificationSubscriber, _ notifName: Notification.Name, _ msgHandler: @escaping () -> Void,
                                  filter: (() -> Bool)? = nil, queue: DispatchQueue) {
        
        // Wrap the provided handler function in a block that receives a Notification.
        // Invoke the handler, if the optionally provided filter allows it.
        
        let observer = notifCtr.addObserver(forName: notifName, object: nil, queue: nil, using: { notif in
            
            // Dispatch the notification asynchronously on the specified queue.
            queue.async {
                
                if filter?() ?? true {
                    msgHandler()
                }
            }
        })
        
        registerSubscription(subscriber.subscriberId, notifName, observer)
    }
    
    /// Unsubscribes a subscriber from notifications with the given notification name.
    ///
    /// - Parameter subscriber:     The subscriber that is unsubscribing from notifications.
    ///
    /// - Parameter notifName:      The name of the notification the subscriber wishes to unsubscribe from.
    ///
    static func unsubscribe(_ subscriber: NotificationSubscriber, _ notifName: Notification.Name) {
        
        // Retrieve the subscription from the subscriptions map
        if let subscriptionsForSubscriber = subscriptions[subscriber.subscriberId],
            let observer = subscriptionsForSubscriber[notifName] {
            
            notifCtr.removeObserver(observer)
            subscriptions[subscriber.subscriberId]?.removeValue(forKey: notifName)
        }
    }
    
    /// Unsubscribes a subscriber from all its registered notifications.
    ///
    /// - Parameter subscriber:     The subscriber that is unsubscribing from notifications.
    ///
    static func unsubscribeAll(for subscriber: NotificationSubscriber) {
        
        // Retrieve the subscriptions from the subscriptions map
        if let subscriptionsForSubscriber = subscriptions[subscriber.subscriberId] {
            
            for observer in subscriptionsForSubscriber.values {
                notifCtr.removeObserver(observer)
            }
            
            subscriptions.removeValue(forKey: subscriber.subscriberId)
        }
    }
    
    /// Helper function that adds a new subscription to the subscriptions map, for later reference (eg. when unsubscribing).
    ///
    /// - Parameter subscriberId:   A unique identifier for the subscriber of the relevant notification.
    ///
    /// - Parameter notifName:      The name of the notification the subscriber wishes to subscribe to.
    ///
    /// - Parameter observer:       The observer object returned by NotificationCenter when subscribing to this notification.
    ///                             This object can later be used to unsubscribe from this notification.
    ///
    private static func registerSubscription(_ subscriberId: String, _ notifName: Notification.Name, _ observer: Observer) {
        
        if subscriptions[subscriberId] == nil {
            subscriptions[subscriberId] = [:]
        }
        
        subscriptions[subscriberId]![notifName] = observer
    }
}

extension Notification {
    
    // A designated key used when accessing a notification payload object inside the userInfo map.
    static let userInfoKey_payload: String = "_payload_"
    
    // A special property that refers to the associated payload object within a Notification instance.
    // It provides callers the convenience of accessing the payload within the Notification's userInfo
    // map without having to refer to userInfo explicitly.
    var payload: Any? {
        
        get {userInfo?[Notification.userInfoKey_payload]
        }
        
        set {
            
            if let theValue = newValue {
                
                if userInfo == nil {
                    userInfo = [:]
                }
                
                userInfo![Notification.userInfoKey_payload] = theValue
            }
        }
    }
}
