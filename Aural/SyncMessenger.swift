import Cocoa

/*
    Messenger for synchronous message delivery. All messages are dispatched directly from the publisher to the subscriber, via this messenger, synchronously, on the same (calling) thread. For example: When the player starts playing back a new track, it messages the playlist for it to update the playlist selection to match the new playing track.
 */
class SyncMessenger {
    
    // Keeps track of subscribers. For each message type, stores a list of subscribers
    
    private static var messageSubscriberRegistry: [MessageType: [MessageSubscriber]] = [MessageType: [MessageSubscriber]]()
    
    private static var actionMessageSubscriberRegistry: [ActionType: [ActionMessageSubscriber]] = [ActionType: [ActionMessageSubscriber]]()
    
    // Called by a subscriber who is interested in a certain type of message
    static func subscribe(messageTypes: [MessageType], subscriber: MessageSubscriber) {
        
        messageTypes.forEach({
            
            let messageType = $0
            
            let subscribers = messageSubscriberRegistry[messageType]
            if (subscribers == nil) {
                messageSubscriberRegistry[messageType] = [MessageSubscriber]()
            }
            
            messageSubscriberRegistry[messageType]?.append(subscriber)
        })
    }
    
    // Called by a subscriber who is interested in a certain type of message
    static func subscribe(actionTypes: [ActionType], subscriber: ActionMessageSubscriber) {
        
        actionTypes.forEach({
            
            let actionType = $0
        
            let subscribers = actionMessageSubscriberRegistry[actionType]
            if (subscribers == nil) {
                actionMessageSubscriberRegistry[actionType] = [ActionMessageSubscriber]()
            }
            
            actionMessageSubscriberRegistry[actionType]?.append(subscriber)
        })
    }
    
    // Called by a publisher to publish a notification message
    static func publishNotification(_ notification: NotificationMessage) {
        
        let subscribers = messageSubscriberRegistry[notification.messageType]
        subscribers?.forEach({$0.consumeNotification(notification)})
    }
    
    // Called by a publisher to publish a request message. Returns an array of responses, one per request consumer.
    static func publishRequest(_ request: RequestMessage) -> [ResponseMessage] {
        
        let messageType = request.messageType
        let subscribers = messageSubscriberRegistry[messageType]
        var responseMsgs: [ResponseMessage] = [ResponseMessage]()
        
        subscribers?.forEach({responseMsgs.append($0.processRequest(request))})
        return responseMsgs
    }
    
    static func publishActionMessage(_ message: ActionMessage) {
        
        let subscribers = actionMessageSubscriberRegistry[message.actionType]
        subscribers?.forEach({$0.consumeMessage(message)})
    }
}
