
import Cocoa

// Marker protocols

protocol Event {
}

protocol EventSubscriber {
    
    // Every event subscriber must implement this method to consume an event it is interested in
    func consumeEvent(event: Event)
}