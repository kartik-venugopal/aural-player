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
    static func subscribe(_ AsyncMessageType: AsyncMessageType, subscriber: AsyncMessageSubscriber, dispatchQueue: DispatchQueue) {
        
        let subscribers = subscriberRegistry[AsyncMessageType]
        if (subscribers == nil) {
            subscriberRegistry[AsyncMessageType] = [(AsyncMessageSubscriber, DispatchQueue)]()
        }
        
        subscriberRegistry[AsyncMessageType]?.append((subscriber, dispatchQueue))
    }
    
    // Called by a publisher to publish an event
    static func publishMessage(_ message: AsyncMessage) {
        
        let subscribers = subscriberRegistry[message.messageType]
        
        if (subscribers != nil) {
            
            for (subscriber, queue) in subscribers! {
                
                // Notify the subscriber on its notification queue
                queue.async(execute: { () -> Void in
                    subscriber.consumeAsyncMessage(message)
                })
            }
        }
    }
}
