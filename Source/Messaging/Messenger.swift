//
//  Messenger.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A thin wrapper around NotificationCenter that is used to subscribe to, and dispatch, notifications
/// between app components.
///
/// It does the following:
///
/// 1. Wraps and unwraps payload objects in and from Notification objects, so clients can deal directly with relevant payload objects.
/// 2. Provides a mechanism to allow clients to filter incoming notifications (rejecting unwanted ones) based on any arbitrary criteria.
/// 3. Allows notifications to be delivered either synchronously on the same thread as the calling thread or asynchronously on a chosen queue.
/// 4. Provides methods that use publish / subscribe parlance.
///
class Messenger {
    
    // The underlying NotificationCenter that is used for actual notification delivery.
    private let notifCtr: NotificationCenter = .default
    
    private typealias Observer = NSObjectProtocol
    
    typealias MessageHandler = () -> Void
    typealias PayloadMessageHandler<P> = (P) -> Void
    
    typealias MessageFilter = () -> Bool
    typealias PayloadMessageFilter<P> = (P) -> Bool
    
    ///
    /// The client serviced by this **Messenger** object.
    ///
    private unowned var client: AnyObject!
    
    private let asyncNotificationQueue: DispatchQueue
    
    //
    // A map that keeps track of all subscriptions.
    // This is needed to be able to allow the client to unsubscribe from notifications.
    private var subscriptions: [Notification.Name: Observer] = [:]
    
    ///
    /// Initializes a messenger for a given client.
    ///
    /// - Parameter client:                     The client to be serviced by this **Messenger** object, i.e. the subscriber / publisher.
    ///
    /// - Parameter asyncNotificationQueue:     The **DispatchQueue** on which to (asynchronously)
    ///                                         receive incoming notifications that are marked as being
    ///                                         asynchronous, i.e. subscribed to by calling subscribeAsync().
    ///
    init(for client: AnyObject, asyncNotificationQueue: DispatchQueue = .main) {
        
        self.client = client
        self.asyncNotificationQueue = asyncNotificationQueue
    }
    
    ///
    /// Subscribes the client to synchronous notifications with the given notification name and an associated payload object,
    /// specifying a notification handler, an optional filtering function to reject unwanted notifications, and an optional OperationQueue on
    /// which to receive the notifications.
    ///
    /// - Warning:                  The incoming notification must have a payload object matching the type of the inferred generic type P;
    ///                             Otherwise, the notification handler will not be invoked.
    ///
    /// - Parameter P:              The (arbitrary) type of the payload object associated with the notification.
    ///
    /// - Parameter notifName:      The name of the notification the client wishes to subscribe to.
    ///
    /// - Parameter handler:        The function that will handle receipt of notifications, with an arbitrary payload
    ///                             object as a parameter.
    ///
    /// - Parameter filter:         An optional function that, given the payload object, decides whether or not the handler should be invoked
    ///                             i.e. whether or not the client is interested in handling this particular notification instance.
    ///                             May be nil (meaning all notifications will be passed onto the handler).
    ///
    func subscribe<P: Any>(to notifName: Notification.Name,
                           handler: @escaping PayloadMessageHandler<P>,
                           filter: PayloadMessageFilter<P>? = nil) {
        
        // Wrap the provided handler function in a block that receives a Notification.
        // Extract the payload from the Notification, type-check it, and pass it onto
        // the handler, if the optionally provided filter allows it.
        
        let observer = notifCtr.addObserver(forName: notifName, object: nil, queue: nil, using: {notif in
            
            if let payload = notif.payload as? P {
                
                if filter?(payload) ?? true {
                    handler(payload)
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
        
        subscriptions[notifName] = observer
    }
    
    ///
    /// Subscribes the client to synchronous notifications with the given notification name and an associated payload object,
    /// specifying a notification handler, a filtering function to reject unwanted notifications, and an optional OperationQueue on
    /// which to receive the notifications.
    ///
    /// This function can be used when the client needs the payload only for filtering purposes and not for message handling.
    ///
    /// - Warning:                  The incoming notification must have a payload object matching the type of the inferred generic type P;
    ///                             Otherwise, the notification handler will not be invoked.
    ///
    /// - Parameter P:              The (arbitrary) type of the payload object associated with the notification.
    ///
    /// - Parameter notifName:      The name of the notification the client wishes to subscribe to.
    ///
    /// - Parameter handler:        The function that will handle receipt of notifications, with no parameters.
    ///
    /// - Parameter filter:         A  function that, given the payload object, decides whether or not the handler should be invoked
    ///                             i.e. whether or not the client is interested in handling this particular notification instance.
    ///
    func subscribe<P: Any>(to notifName: Notification.Name,
                           handler: @escaping MessageHandler,
                           filter: @escaping PayloadMessageFilter<P>) {
        
        // Wrap the provided handler function in a block that receives a Notification.
        // Extract the payload from the Notification, type-check it, and pass it onto
        // the handler, if the optionally provided filter allows it.
        
        let observer = notifCtr.addObserver(forName: notifName, object: nil, queue: nil, using: {notif in
            
            if let payload = notif.payload as? P {
                
                if filter(payload) {
                    handler()
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
        
        subscriptions[notifName] = observer
    }
    
    ///
    /// Subscribes the client to synchronous notifications with the given notification name and no associated payload object,
    /// specifying a notification handler, an optional filtering function to reject unwanted notifications, and an optional OperationQueue on
    /// which to receive the notifications.
    ///
    /// - Parameter notifName:      The name of the notification the client wishes to subscribe to.
    ///
    /// - Parameter handler:        The function that will handle receipt of notifications.
    ///
    /// - Parameter filter:         An optional function that decides whether or not the handler should be invoked
    ///                             i.e. whether or not the client is interested in handling this particular notification instance.
    ///                             May be nil (meaning all notifications will be passed onto the handler).
    ///
    func subscribe(to notifName: Notification.Name,
                   handler: @escaping MessageHandler,
                   filter: MessageFilter? = nil) {
        
        // Wrap the provided handler function in a block that receives a Notification.
        // Invoke the handler, if the optionally provided filter allows it.
        
        let observer = notifCtr.addObserver(forName: notifName, object: nil, queue: nil, using: {notif in
            
            if filter?() ?? true {
                handler()
            }
        })
        
        subscriptions[notifName] = observer
    }
    
    ///
    /// Subscribes the client to asynchronous notifications with the given notification name and an associated payload object,
    /// specifying a notification handler, an optional filtering function to reject unwanted notifications, and a DispatchQueue on
    /// which to receive the notifications.
    ///
    /// - Parameter P:              The (arbitrary) type of the payload object associated with the notification.
    ///
    /// - Parameter notifName:      The name of the notification the client wishes to subscribe to.
    ///
    /// - Parameter handler:        The function that will handle receipt of notifications, with an arbitrary payload
    ///                             object as a parameter.
    ///
    /// - Parameter filter:         An optional function that, given the payload object, decides whether or not the handler should be invoked
    ///                             i.e. whether or not the client is interested in handling this particular notification instance.
    ///                             May be nil (meaning all notifications will be passed onto the handler).
    ///
    func subscribeAsync<P: Any>(to notifName: Notification.Name,
                                handler: @escaping PayloadMessageHandler<P>,
                                filter: PayloadMessageFilter<P>? = nil) {
        
        // Wrap the provided handler function in a block that receives a Notification.
        // Extract the payload from the Notification, type-check it, and pass it onto
        // the handler, if the optionally provided filter allows it.
        
        let observer = notifCtr.addObserver(forName: notifName, object: nil, queue: nil, using: {notif in
            
            // Dispatch the notification asynchronously on the specified queue.
            self.asyncNotificationQueue.async {
            
                if let payload = notif.payload as? P {
                    
                    if filter?(payload) ?? true {
                        handler(payload)
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
        
        subscriptions[notifName] = observer
    }
    
    ///
    /// Subscribes the client to asynchronous notifications with the given notification name and no associated payload object,
    /// specifying a notification handler, an optional filtering function to reject unwanted notifications, and a DispatchQueue on
    /// which to receive the notifications.
    ///
    /// - Parameter notifName:      The name of the notification the client wishes to subscribe to.
    ///
    /// - Parameter handler:        The function that will handle receipt of notifications, with an arbitrary payload
    ///                             object as a parameter.
    ///
    /// - Parameter filter:         An optional function that, given the payload object, decides whether or not the handler should be invoked
    ///                             i.e. whether or not the client is interested in handling this particular notification instance.
    ///                             May be nil (meaning all notifications will be passed onto the handler).
    ///
    /// - Parameter queue:          The DispatchQueue on which to (asynchronously) receive the incoming notifications.
    ///
    func subscribeAsync(to notifName: Notification.Name,
                        handler: @escaping MessageHandler,
                        filter: MessageFilter? = nil) {
        
        // Wrap the provided handler function in a block that receives a Notification.
        // Invoke the handler, if the optionally provided filter allows it.
        
        let observer = notifCtr.addObserver(forName: notifName, object: nil, queue: nil, using: {notif in
            
            // Dispatch the notification asynchronously on the specified queue.
            self.asyncNotificationQueue.async {
                
                if filter?() ?? true {
                    handler()
                }
            }
        })
        
        subscriptions[notifName] = observer
    }
    
    ///
    /// Unsubscribes the client from notifications with the given notification name.
    ///
    /// - Parameter notifName:      The name of the notification the client wishes to unsubscribe from.
    ///
    func unsubscribe(from notifName: Notification.Name) {
        
        if let observer = subscriptions[notifName] {
            
            notifCtr.removeObserver(observer)
            subscriptions.removeValue(forKey: notifName)
        }
    }
    
    ///
    /// Unsubscribes the client from all its registered notifications.
    ///
    func unsubscribeFromAll() {
        
        // Retrieve the subscriptions from the subscriptions map
        for observer in subscriptions.values {
            notifCtr.removeObserver(observer)
        }
        
        subscriptions.removeAll()
    }
    
    // MARK: Publish ---------------------------------------------
    
    ///
    /// Publishes a notification with an associated payload object that conforms to the **NotificationPayload** protocol.
    ///
    /// - Parameter payload: The payload object to be published (must conform to **NotificationPayload**)
    ///
    func publish<P: NotificationPayload>(_ payload: P) {
        
        // The notification name is extracted from the payload object, and the payload
        // object is wrapped in a Notification which is then posted by the NotificationCenter.
        
        var notification = Notification(name: payload.notificationName)
        notification.payload = payload
        notification.object = client
        
        notifCtr.post(notification)
    }
    
    ///
    /// Publishes a notification with a name but no associated payload.
    ///
    /// - Parameter notifName: The name for the notification to be published.
    ///
    func publish(_ notifName: Notification.Name) {
        notifCtr.post(name: notifName, object: client)
    }
    
    ///
    /// Publishes a notification with an arbitrary associated payload object.
    ///
    /// - Parameter notifName:  The name for the notification to be published.
    ///
    /// - Parameter payload:    The (arbitrary) payload object to be published.
    ///
    func publish(_ notifName: Notification.Name, payload: Any) {
        
        // The payload object is wrapped in a Notification which is then posted by the NotificationCenter.
        
        var notification = Notification(name: notifName)
        notification.payload = payload
        notification.object = client
        
        notifCtr.post(notification)
    }
}

extension Notification {
    
    // A designated key used when accessing a notification payload object inside the userInfo map.
    static let userInfoKey_payload: String = "_payload_"
    
    // A special property that refers to the associated payload object within a Notification instance.
    // It provides callers the convenience of accessing the payload within the Notification's userInfo
    // map without having to refer to userInfo explicitly.
    var payload: Any? {
        
        get {userInfo?[Self.userInfoKey_payload]}
        
        set {
            
            if let theValue = newValue {
                
                if userInfo == nil {userInfo = [:]}
                userInfo![Self.userInfoKey_payload] = theValue
            }
        }
    }
}
