
import Cocoa

/*
Orchestrates publishing of, and subscription to, event notifications, to facilitate callbacks between the UI and the player layers.
*/
class EventRegistry {
    
    // Keeps track of subscribers
    private static var subscriberRegistry: [EventType: [(EventSubscriber, DispatchQueue)]] = [EventType: [(EventSubscriber, DispatchQueue)]]()
    
    // Called by a subscriber who is interested in notifications of a certain type of event
    static func subscribe(eventType: EventType, subscriber: EventSubscriber, dispatchQueue: DispatchQueue) {
        
        let subscribers = subscriberRegistry[eventType]
        if (subscribers == nil) {
            subscriberRegistry[eventType] = [(EventSubscriber, DispatchQueue)]()
        }
        
        subscriberRegistry[eventType]?.append(subscriber, dispatchQueue)
    }
    
    // Called by a publisher who provides notifications of a certain type of event
    //    static func registerPublisher(eventType: EventType, publisher: EventPublisher) {
    //
    //        let publishers = publisherRegistry[eventType]
    //        if (publishers == nil) {
    //            publisherRegistry[eventType] = [EventPublisher]()
    //        }
    //
    //        publisherRegistry[eventType]?.append(publisher)
    //    }
    
    // Called by a publisher to publish an event
    static func publishEvent(eventType: EventType, event: Event) {
        
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