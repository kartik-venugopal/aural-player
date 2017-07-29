
import Cocoa

/*
Orchestrates publishing of, and subscription to, event notifications, to facilitate callbacks between the UI and the player layers.
*/
class EventRegistry {
    
    // Keeps track of subscribers
    fileprivate static var subscriberRegistry: [EventType: [(EventSubscriber, GCDDispatchQueue)]] = [EventType: [(EventSubscriber, GCDDispatchQueue)]]()
    
    // Called by a subscriber who is interested in notifications of a certain type of event
    // The queue argument specifies which queue the event notification should be dispatched to (for the UI, this should be the main dispatch queue)
    static func subscribe(_ eventType: EventType, subscriber: EventSubscriber, dispatchQueue: GCDDispatchQueue) {
        
        let subscribers = subscriberRegistry[eventType]
        if (subscribers == nil) {
            subscriberRegistry[eventType] = [(EventSubscriber, GCDDispatchQueue)]()
        }
        
        subscriberRegistry[eventType]?.append(subscriber, dispatchQueue)
    }
    
    // Called by a publisher to publish an event
    static func publishEvent(_ eventType: EventType, _ event: Event) {
        
        let subscribers = subscriberRegistry[eventType]
        
        if (subscribers != nil) {
            for (subscriber, queue) in subscribers! {
                
                AsyncExecutor.execute({
                    
                    subscriber.consumeEvent(event)
                    
                    }, dispatchQueue: queue)
            }
        }
    }
}
