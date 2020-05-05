import Cocoa

/*
    Manages publishing of, and subscription to, asynchronous message notifications, to facilitate callbacks across different application layers.
 
    First, a subscriber subscribes to a certain type of AsyncMessage. Then, a notification is published by a publisher. The subscriber is then notified on its preferred notificsation queue.
*/
class AsyncMessenger {
    
    // Keeps track of subscribers. For each event type, stores a list of subscribers along with their notification queues
    private static var subscriberRegistry: [AsyncMessageType: [(AsyncMessageSubscriber, DispatchQueue)]] = [AsyncMessageType: [(AsyncMessageSubscriber, DispatchQueue)]]()
    
    // Called by a subscriber who is interested in notifications of a certain type of event
    // The queue argument specifies which queue the event notification should be dispatched to (for the UI, this should be the main dispatch queue)
    static func subscribe(_ messageTypes: [AsyncMessageType], subscriber: AsyncMessageSubscriber, dispatchQueue: DispatchQueue) {
        
        for messageType in messageTypes {
            
            if subscriberRegistry[messageType] == nil {subscriberRegistry[messageType] = [(AsyncMessageSubscriber, DispatchQueue)]()}
            
            // Only add if it doesn't already exist
            if subscriberRegistry[messageType]!.firstIndex(where: {$0.0.subscriberId == subscriber.subscriberId}) == nil {
                subscriberRegistry[messageType]!.append((subscriber, dispatchQueue))
            }
        }
    }
    
    static func unsubscribe(_ messageTypes: [AsyncMessageType], subscriber: AsyncMessageSubscriber) {

        for messageType in messageTypes {
            
            if let subscribers = subscriberRegistry[messageType], let subIndex = subscribers.firstIndex(where: {$0.0.subscriberId == subscriber.subscriberId}) {
                subscriberRegistry[messageType]!.remove(at: subIndex)
            }
        }
    }
    
    // Called by a publisher to publish an event
    static func publishMessage(_ message: AsyncMessage) {
        
        if let subscribers = subscriberRegistry[message.messageType] {
            
            for (subscriber, queue) in subscribers {
                
                // Notify the subscriber on its notification queue
                queue.async {
                    subscriber.consumeAsyncMessage(message)
                }
            }
        }
    }
}
