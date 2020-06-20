import XCTest

class NotificationSubscriberTests: AuralTestCase {
    
    struct SomeSubscriber: NotificationSubscriber {
    }
    
    class SomeNSObjectSubscriber: NSObject, NotificationSubscriber {
        
        let id = UUID().uuidString
        
        override var hash: Int {
            return id.hashValue
        }
    }
    
    func testSubscriberId_nonNSObject() {
        
        let subscriber = SomeSubscriber()
        XCTAssertEqual(subscriber.subscriberId, "SomeSubscriber")
    }
    
    func testSubscriberId_NSObject() {
        
        let subscriber = SomeNSObjectSubscriber()
        XCTAssertEqual(subscriber.subscriberId, "SomeNSObjectSubscriber-" + String(subscriber.hashValue))
    }
    
    func testSubscriberId_nonNSObject_consistencyAcrossCalls() {
        
        let subscriber = SomeSubscriber()
        let expectedSubscriberID = "SomeSubscriber"
        XCTAssertEqual(subscriber.subscriberId, expectedSubscriberID)
        
        var subscriberIDs = Set<String>()
        
        for _ in 1...1000 {
            subscriberIDs.insert(subscriber.subscriberId)
        }
        
        XCTAssertEqual(subscriberIDs.count, 1)
        XCTAssertEqual(subscriberIDs.removeFirst(), "SomeSubscriber")
    }
    
    func testSubscriberId_NSObject_consistencyAcrossCalls() {
        
        let subscriber = SomeNSObjectSubscriber()
        let expectedSubscriberID = "SomeNSObjectSubscriber-" + String(subscriber.hashValue)
        XCTAssertEqual(subscriber.subscriberId, expectedSubscriberID)
        
        var subscriberIDs = Set<String>()
        
        for _ in 1...1000 {
            subscriberIDs.insert(subscriber.subscriberId)
        }
        
        XCTAssertEqual(subscriberIDs.count, 1)
        XCTAssertEqual(subscriberIDs.removeFirst(), expectedSubscriberID)
    }
}
