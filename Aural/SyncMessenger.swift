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
        
        for messageType in messageTypes {
            
            if messageSubscriberRegistry[messageType] == nil {messageSubscriberRegistry[messageType] = [MessageSubscriber]()}
            
            // Only add if it doesn't already exist
            if messageSubscriberRegistry[messageType]!.firstIndex(where: {$0.subscriberId == subscriber.subscriberId}) == nil {
                messageSubscriberRegistry[messageType]!.append(subscriber)
            }
        }
    }
    
    // Called by a subscriber who is no longer interested in a certain type of message
    static func unsubscribe(messageTypes: [MessageType], subscriber: MessageSubscriber) {
        
        for messageType in messageTypes {
            
            // Find and remove the subscriber from the registry
            if let subscribers = messageSubscriberRegistry[messageType], let subIndex = subscribers.firstIndex(where: {$0.subscriberId == subscriber.subscriberId}) {
                messageSubscriberRegistry[messageType]!.remove(at: subIndex)
            }
        }
    }
    
    // Called by a subscriber who is interested in a certain type of message
    static func subscribe(actionTypes: [ActionType], subscriber: ActionMessageSubscriber) {
        
        for actionType in actionTypes {
            
            if actionMessageSubscriberRegistry[actionType] == nil {actionMessageSubscriberRegistry[actionType] = [ActionMessageSubscriber]()}
            
            if actionMessageSubscriberRegistry[actionType]!.firstIndex(where: {$0.subscriberId == subscriber.subscriberId}) == nil {
                actionMessageSubscriberRegistry[actionType]!.append(subscriber)
            }
        }
    }
    
    // Called by a subscriber who is no longer interested in a certain type of message
    static func unsubscribe(actionTypes: [ActionType], subscriber: ActionMessageSubscriber) {
        
        for actionType in actionTypes {
            
            // Find and remove the subscriber from the registry
            if let subscribers = actionMessageSubscriberRegistry[actionType], let subIndex = subscribers.firstIndex(where: {$0.subscriberId == subscriber.subscriberId}) {
                actionMessageSubscriberRegistry[actionType]!.remove(at: subIndex)
            }
        }
    }
    
    // Called by a publisher to publish a notification message
    static func publishNotification(_ notification: NotificationMessage) {
        
        messageSubscriberRegistry[notification.messageType]?.forEach({
            $0.consumeNotification(notification)
        })
    }
    
    // Called by a publisher to publish a request message. Returns an array of responses, one per request consumer.
    static func publishRequest(_ request: RequestMessage) -> [ResponseMessage] {
        
        var responseMsgs: [ResponseMessage] = [ResponseMessage]()
        messageSubscriberRegistry[request.messageType]?.forEach({responseMsgs.append($0.processRequest(request))})
        return responseMsgs
    }
    
    static func publishActionMessage(_ message: ActionMessage) {
        actionMessageSubscriberRegistry[message.actionType]?.forEach({$0.consumeMessage(message)})
    }
}
