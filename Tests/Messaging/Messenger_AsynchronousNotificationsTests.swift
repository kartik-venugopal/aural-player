import XCTest

class Messenger_AsynchronousNotificationsTests: AuralTestCase, NotificationSubscriber {

    override func setUp() {
        Messenger.unsubscribeAll(for: self)
    }
    
    override func tearDown() {
        Messenger.unsubscribeAll(for: self)
    }

    func testAsynchronousNotification_noPayload_noFilter() {
        
        var receivedNotif: Bool = false
        
        // TODO: Use an array of these Bool values, and keep track of current one with a counter
        var publisherIsBlocked: Bool = true
        
        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_noPayload_noFilter")
        
        Messenger.subscribeAsync(self, notifName, {
            
            receivedNotif = true
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertFalse(publisherIsBlocked)
            
        }, queue: DispatchQueue.global(qos: .userInteractive))
        
        for _ in 1...10 {
            
            receivedNotif = false
            
            publisherIsBlocked = true
            Messenger.publish(notifName)
            publisherIsBlocked = false
            
            XCTAssertTrue(receivedNotif)
        }
    }
    
//    func testAsynchronousNotification_noPayload_withFilter_neverReceive() {
//
//        var receivedNotif: Bool = false
//        var publisherIsBlocked: Bool = true
//
//        let neverReceiveFilter: () -> Bool = {return false}
//
//        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_noPayload_withFilter_neverReceive")
//        Messenger.subscribeAsync(self, notifName, {
//
//            receivedNotif = true
//
//            // Simulate some work being done
//            usleep(UInt32.random(in: 1000...100000))
//
//            XCTAssertFalse(publisherIsBlocked)
//
//        }, filter: neverReceiveFilter,
//           queue: DispatchQueue.global(qos: .userInteractive))
//
//        for _ in 1...100 {
//
//            receivedNotif = false
//
//            publisherIsBlocked = true
//            Messenger.publish(notifName)
//            publisherIsBlocked = false
//
//            // Notification should never be received (filter always returns false)
//            XCTAssertFalse(receivedNotif)
//        }
//    }
//
//    func testAsynchronousNotification_noPayload_withFilter_alwaysReceive() {
//
//        var receivedNotif: Bool = false
//        var publisherIsBlocked: Bool = true
//
//        let alwaysReceiveFilter: () -> Bool = {return true}
//
//        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_noPayload_withFilter_alwaysReceive")
//        Messenger.subscribeAsync(self, notifName, {
//
//            receivedNotif = true
//
//            // Simulate some work being done
//            usleep(UInt32.random(in: 1000...100000))
//
//            XCTAssertFalse(publisherIsBlocked)
//
//        }, filter: alwaysReceiveFilter,
//           queue: DispatchQueue.global(qos: .userInteractive))
//
//        for _ in 1...100 {
//
//            receivedNotif = false
//
//            publisherIsBlocked = true
//            Messenger.publish(notifName)
//            publisherIsBlocked = false
//
//            // Notification should always be received (filter always returns true)
//            XCTAssertTrue(receivedNotif)
//        }
//    }
//
//    func testAsynchronousNotification_noPayload_withFilter_conditional() {
//
//        var receivedNotif: Bool = false
//        var publisherIsBlocked: Bool = true
//
//        var filterCondition: Bool = false
//        let conditionalFilter: () -> Bool = {return filterCondition}
//
//        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_noPayload_withFilter_conditional")
//        Messenger.subscribeAsync(self, notifName, {
//
//            receivedNotif = true
//
//            // Simulate some work being done
//            usleep(UInt32.random(in: 1000...100000))
//
//            XCTAssertFalse(publisherIsBlocked)
//
//        }, filter: conditionalFilter, queue: DispatchQueue.global(qos: .userInteractive))
//
//        for _ in 1...100 {
//
//            receivedNotif = false
//            filterCondition = Bool.random()
//
//            publisherIsBlocked = true
//            Messenger.publish(notifName)
//            publisherIsBlocked = false
//
//            // Notification should be received if and only if filterCondition is true
//            XCTAssertEqual(receivedNotif, filterCondition)
//        }
//    }
//
//    // MARK: Notifications with a payload object --------------------------------------------------------------------------------
//
//    struct TestPayload<V>: NotificationPayload where V: Equatable {
//
//        let notificationName: Notification.Name
//        let equatableValue: V
//    }
//
//    func testAsynchronousNotification_withPayload_noFilter() {
//
//        var receivedNotif: Bool = false
//        var publisherIsBlocked: Bool = true
//
//        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_withPayload_noFilter")
//        var receivedFloatVal: Float = 0
//
//        Messenger.subscribeAsync(self, notifName, {(thePayload: TestPayload<Float>) in
//
//            receivedNotif = true
//            receivedFloatVal = thePayload.equatableValue
//
//            // Simulate some work being done
//            usleep(UInt32.random(in: 1000...100000))
//
//            XCTAssertFalse(publisherIsBlocked)
//        }, queue: DispatchQueue.global(qos: .userInteractive))
//
//        for _ in 1...100 {
//
//            receivedNotif = false
//
//            let sentFloatVal: Float = Float.random(in: 0...3600000)
//            let payload = TestPayload<Float>(notificationName: notifName, equatableValue: sentFloatVal)
//
//            publisherIsBlocked = true
//            Messenger.publish(payload)
//            publisherIsBlocked = false
//
//            XCTAssertTrue(receivedNotif)
//            XCTAssertEqual(receivedFloatVal, sentFloatVal, accuracy: 0.001)
//        }
//    }
//
//    func testAsynchronousNotification_withPayload_withFilter_neverReceive() {
//
//        var receivedNotif: Bool = false
//        var publisherIsBlocked: Bool = true
//
//        var receivedFloatVal: Float = -1
//        let neverReceiveFilter: (TestPayload<Float>) -> Bool = {(payload: TestPayload<Float>) in return false}
//        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_withPayload_withFilter_neverReceive")
//
//        Messenger.subscribeAsync(self, notifName, {(thePayload: TestPayload<Float>) in
//
//            receivedNotif = true
//            receivedFloatVal = thePayload.equatableValue
//
//            // Simulate some work being done
//            usleep(UInt32.random(in: 1000...100000))
//
//            XCTAssertFalse(publisherIsBlocked)
//
//        }, filter: neverReceiveFilter,
//           queue: DispatchQueue.global(qos: .userInteractive))
//
//        for _ in 1...100 {
//
//            receivedNotif = false
//
//            let sentFloatVal: Float = Float.random(in: 0...3600000)
//            let payload = TestPayload<Float>(notificationName: notifName, equatableValue: sentFloatVal)
//
//            publisherIsBlocked = true
//            Messenger.publish(payload)
//            publisherIsBlocked = false
//
//            // Notification should never be received (filter always returns false)
//            XCTAssertFalse(receivedNotif)
//            XCTAssertEqual(receivedFloatVal, -1, accuracy: 0.001)
//        }
//    }
//
//    func testAsynchronousNotification_withPayload_withFilter_alwaysReceive() {
//
//        var receivedNotif: Bool = false
//        var publisherIsBlocked: Bool = true
//
//        var receivedFloatVal: Float = -1
//        let alwaysReceiveFilter: (TestPayload<Float>) -> Bool = {(payload: TestPayload<Float>) in return true}
//        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_withPayload_withFilter_alwaysReceive")
//
//        Messenger.subscribeAsync(self, notifName, {(thePayload: TestPayload<Float>) in
//
//            receivedNotif = true
//            receivedFloatVal = thePayload.equatableValue
//
//            // Simulate some work being done
//            usleep(UInt32.random(in: 1000...100000))
//
//            XCTAssertFalse(publisherIsBlocked)
//
//        }, filter: alwaysReceiveFilter,
//           queue: DispatchQueue.global(qos: .userInteractive))
//
//        for _ in 1...100 {
//
//            receivedNotif = false
//
//            let sentFloatVal: Float = Float.random(in: 0...3600000)
//            let payload = TestPayload<Float>(notificationName: notifName, equatableValue: sentFloatVal)
//
//            publisherIsBlocked = true
//            Messenger.publish(payload)
//            publisherIsBlocked = false
//
//            // Notification should always be received (filter always returns true)
//            XCTAssertTrue(receivedNotif)
//            XCTAssertEqual(receivedFloatVal, sentFloatVal, accuracy: 0.001)
//        }
//    }
//
//    func testAsynchronousNotification_withPayload_withFilter_conditional() {
//
//        var filterCondition: Bool = false
//
//        var receivedNotif: Bool = false
//        var publisherIsBlocked: Bool = true
//
//        var receivedFloatVal: Float = -1
//        let conditionalFilter: (TestPayload<Float>) -> Bool = {(payload: TestPayload<Float>) in return filterCondition}
//        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_withPayload_withFilter_alwaysReceive")
//
//        Messenger.subscribeAsync(self, notifName, {(thePayload: TestPayload<Float>) in
//
//            receivedNotif = true
//            receivedFloatVal = thePayload.equatableValue
//
//            // Simulate some work being done
//            usleep(UInt32.random(in: 1000...100000))
//
//            XCTAssertFalse(publisherIsBlocked)
//
//        }, filter: conditionalFilter,
//           queue: DispatchQueue.global(qos: .userInteractive))
//
//        for _ in 1...100 {
//
//            receivedNotif = false
//
//            let sentFloatVal: Float = Float.random(in: 0...3600000)
//            let payload = TestPayload<Float>(notificationName: notifName, equatableValue: sentFloatVal)
//
//            filterCondition = Bool.random()
//            receivedFloatVal = -1
//
//            publisherIsBlocked = true
//            Messenger.publish(payload)
//            publisherIsBlocked = false
//
//            // Notification should be received if and only if filterCondition is true
//            XCTAssertEqual(receivedNotif, filterCondition)
//            XCTAssertEqual(receivedFloatVal, filterCondition ? sentFloatVal : -1, accuracy: 0.001)
//        }
//    }
//
//    // MARK: Notifications with an arbitrary payload object --------------------------------------------------------------------------------
//
//    func testAsynchronousNotification_withArbitraryPayload_noFilter() {
//
//        var receivedNotif: Bool = false
//        var publisherIsBlocked: Bool = true
//
//        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_withArbitraryPayload_noFilter")
//        var receivedFloatVal: Float = 0
//
//        Messenger.subscribeAsync(self, notifName, {(thePayload: Float) in
//
//            receivedNotif = true
//            receivedFloatVal = thePayload
//
//            // Simulate some work being done
//            usleep(UInt32.random(in: 1000...100000))
//
//            XCTAssertFalse(publisherIsBlocked)
//
//        }, queue: DispatchQueue.global(qos: .userInteractive))
//
//        for _ in 1...100 {
//
//            receivedNotif = false
//
//            let sentFloatVal: Float = Float.random(in: 0...3600000)
//
//            publisherIsBlocked = true
//            Messenger.publish(notifName, payload: sentFloatVal)
//            publisherIsBlocked = false
//
//            XCTAssertTrue(receivedNotif)
//            XCTAssertEqual(receivedFloatVal, sentFloatVal, accuracy: 0.001)
//        }
//    }
//
//    func testAsynchronousNotification_withArbitraryPayload_withFilter_neverReceive() {
//
//        var receivedNotif: Bool = false
//        var publisherIsBlocked: Bool = true
//
//        var receivedFloatVal: Float = -1
//        let neverReceiveFilter: (Float) -> Bool = {(payload: Float) in return false}
//        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_withArbitraryPayload_withFilter_neverReceive")
//
//        Messenger.subscribeAsync(self, notifName, {(thePayload: Float) in
//
//            receivedNotif = true
//            receivedFloatVal = thePayload
//
//            // Simulate some work being done
//            usleep(UInt32.random(in: 1000...100000))
//
//            XCTAssertFalse(publisherIsBlocked)
//
//        }, filter: neverReceiveFilter, queue: DispatchQueue.global(qos: .userInteractive))
//
//        for _ in 1...100 {
//
//            receivedNotif = false
//
//            let sentFloatVal: Float = Float.random(in: 0...3600000)
//
//            publisherIsBlocked = true
//            Messenger.publish(notifName, payload: sentFloatVal)
//            publisherIsBlocked = false
//
//            // Notification should never be received (filter always returns false)
//            XCTAssertFalse(receivedNotif)
//            XCTAssertEqual(receivedFloatVal, -1, accuracy: 0.001)
//        }
//    }
//
//    func testAsynchronousNotification_withArbitraryPayload_withFilter_alwaysReceive() {
//
//        var receivedNotif: Bool = false
//        var publisherIsBlocked: Bool = true
//
//        var receivedFloatVal: Float = -1
//        let alwaysReceiveFilter: (Float) -> Bool = {(payload: Float) in return true}
//        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_withArbitraryPayload_withFilter_alwaysReceive")
//
//        Messenger.subscribeAsync(self, notifName, {(thePayload: Float) in
//
//            receivedNotif = true
//            receivedFloatVal = thePayload
//
//            // Simulate some work being done
//            usleep(UInt32.random(in: 1000...100000))
//
//            XCTAssertFalse(publisherIsBlocked)
//
//        }, filter: alwaysReceiveFilter, queue: DispatchQueue.global(qos: .userInteractive))
//
//        for _ in 1...100 {
//
//            receivedNotif = false
//
//            let sentFloatVal: Float = Float.random(in: 0...3600000)
//
//            publisherIsBlocked = true
//            Messenger.publish(notifName, payload: sentFloatVal)
//            publisherIsBlocked = false
//
//            // Notification should always be received (filter always returns true)
//            XCTAssertTrue(receivedNotif)
//            XCTAssertEqual(receivedFloatVal, sentFloatVal, accuracy: 0.001)
//        }
//    }
//
//    func testAsynchronousNotification_withArbitraryPayload_withFilter_conditional() {
//
//        var filterCondition: Bool = false
//
//        var receivedNotif: Bool = false
//        var publisherIsBlocked: Bool = true
//
//        var receivedFloatVal: Float = -1
//        let conditionalFilter: (Float) -> Bool = {(payload: Float) in return filterCondition}
//        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_withArbitraryPayload_withFilter_alwaysReceive")
//
//        Messenger.subscribeAsync(self, notifName, {(thePayload: Float) in
//
//            receivedNotif = true
//            receivedFloatVal = thePayload
//
//            // Simulate some work being done
//            usleep(UInt32.random(in: 1000...100000))
//
//            XCTAssertFalse(publisherIsBlocked)
//
//        }, filter: conditionalFilter, queue: DispatchQueue.global(qos: .userInteractive))
//
//        for _ in 1...100 {
//
//            receivedNotif = false
//
//            let sentFloatVal: Float = Float.random(in: 0...3600000)
//
//            filterCondition = Bool.random()
//            receivedFloatVal = -1
//
//            publisherIsBlocked = true
//            Messenger.publish(notifName, payload: sentFloatVal)
//            publisherIsBlocked = false
//
//            // Notification should be received if and only if filterCondition is true
//            XCTAssertEqual(receivedNotif, filterCondition)
//            XCTAssertEqual(receivedFloatVal, filterCondition ? sentFloatVal : -1, accuracy: 0.001)
//        }
//    }
    
    // TODO: Arbitrary payloads of different kinds: numbers, strings, structs, classes, tuples, enums, collections, etc.
    
    /*
        TODO: Error cases
        - Payload type doesn't match expected type
        - Expected payload, none was sent
        - Not expecting payload, payload was sent
        - Listening to wrong notifName (notifName mismatch)
     */
}

class AtomicCounter {
    
    private (set) var value : Int = 0
    
    func increment() {
        
        ConcurrencyUtils.executeSynchronized(self, closure: {
            value.increment()
        })
    }
    
    func incrementAndGet() -> Int {
        
        ConcurrencyUtils.executeSynchronized(self, closure: {
            value.increment()
        })
        
        return value
    }
}
