import Cocoa

/*
    Messenger for synchronous message delivery. All messages are dispatched directly from the publisher to the subscriber, via this messenger, synchronously, on the same (calling) thread. For example: When the player starts playing back a new track, it messages the playlist for it to update the playlist selection to match the new playing track.
 */
class SyncMessenger {
    
    // Keeps track of subscribers. For each message type, stores a list of subscribers
    private static var subscriberRegistry: [MessageType: [MessageSubscriber]] = [MessageType: [MessageSubscriber]]()
    
    // Called by a subscriber who is interested in a certain type of message
    static func subscribe(_ messageType: MessageType, subscriber: MessageSubscriber) {
        
        let subscribers = subscriberRegistry[messageType]
        if (subscribers == nil) {
            subscriberRegistry[messageType] = [MessageSubscriber]()
        }
        
        subscriberRegistry[messageType]?.append(subscriber)
    }
    
    // Called by a publisher to publish a notification message
    static func publishNotification(_ notification: NotificationMessage) {
        
        let messageType = notification.messageType
        let subscribers = subscriberRegistry[messageType]
        
        if (subscribers != nil) {
            
            for subscriber in subscribers! {
                
                // Notify the subscriber
                subscriber.consumeNotification(notification)
            }
        }
    }
    
    // Called by a publisher to publish a request message. Returns an array of responses, one per request consumer.
    static func publishRequest(_ request: RequestMessage) -> [ResponseMessage] {
        
        let messageType = request.messageType
        let subscribers = subscriberRegistry[messageType]
        var responseMsgs: [ResponseMessage] = [ResponseMessage]()
        
        if (subscribers != nil) {
            
            for subscriber in subscribers! {
                
                // Notify the subscriber
                let responseMsg = subscriber.processRequest(request)
                responseMsgs.append(responseMsg)
            }
        }
        
        return responseMsgs
    }
}
