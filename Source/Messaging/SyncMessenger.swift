import Cocoa

/*
    Messenger for synchronous message delivery. All messages are dispatched directly from the publisher to the subscriber, via this messenger, synchronously, on the same (calling) thread. For example: When the player starts playing back a new track, it messages the playlist for it to update the playlist selection to match the new playing track.
 */
class SyncMessenger {
    
    // Keeps track of subscribers. For each message type, stores a list of subscribers
    
    private static var actionMessageSubscriberRegistry: [ActionType: [ActionMessageSubscriber]] = [ActionType: [ActionMessageSubscriber]]()

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
    
    static func publishActionMessage(_ message: ActionMessage) {
        actionMessageSubscriberRegistry[message.actionType]?.forEach({$0.consumeMessage(message)})
    }
}
