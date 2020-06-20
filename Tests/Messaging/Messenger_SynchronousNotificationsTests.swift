import XCTest

class Messenger_SynchronousNotificationsTests: AuralTestCase, NotificationSubscriber {

    override func setUp() {
        Messenger.unsubscribeAll(for: self)
    }
    
    override func tearDown() {
        Messenger.unsubscribeAll(for: self)
    }

    func testSynchronousNotification_noPayload_noFilter() {
        
        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true
        
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_noPayload_noFilter")
        
        Messenger.subscribe(self, notifName, {
            
            receivedNotif = true
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
        })
        
        for _ in 1...100 {
            
            receivedNotif = false
            
            publisherIsBlocked = true
            Messenger.publish(notifName)
            publisherIsBlocked = false
            
            XCTAssertTrue(receivedNotif)
        }
    }
    
    func testSynchronousNotification_noPayload_withFilter_neverReceive() {
        
        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true
        
        let neverReceiveFilter: () -> Bool = {return false}
        
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_noPayload_withFilter_neverReceive")
        Messenger.subscribe(self, notifName, {
            
            receivedNotif = true
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: neverReceiveFilter)
        
        for _ in 1...100 {
            
            receivedNotif = false
            
            publisherIsBlocked = true
            Messenger.publish(notifName)
            publisherIsBlocked = false
            
            // Notification should never be received (filter always returns false)
            XCTAssertFalse(receivedNotif)
        }
    }
    
    func testSynchronousNotification_noPayload_withFilter_alwaysReceive() {
        
        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true
        
        let alwaysReceiveFilter: () -> Bool = {return true}
        
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_noPayload_withFilter_alwaysReceive")
        Messenger.subscribe(self, notifName, {
            
            receivedNotif = true
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: alwaysReceiveFilter)
        
        for _ in 1...100 {
            
            receivedNotif = false
            
            publisherIsBlocked = true
            Messenger.publish(notifName)
            publisherIsBlocked = false
            
            // Notification should always be received (filter always returns true)
            XCTAssertTrue(receivedNotif)
        }
    }
    
    func testSynchronousNotification_noPayload_withFilter_conditional() {
        
        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true
        
        var filterCondition: Bool = false
        let conditionalFilter: () -> Bool = {return filterCondition}
        
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_noPayload_withFilter_conditional")
        Messenger.subscribe(self, notifName, {
            
            receivedNotif = true
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: conditionalFilter)
        
        for _ in 1...100 {
            
            receivedNotif = false
            filterCondition = Bool.random()
            
            publisherIsBlocked = true
            Messenger.publish(notifName)
            publisherIsBlocked = false
            
            // Notification should be received if and only if filterCondition is true
            XCTAssertEqual(receivedNotif, filterCondition)
        }
    }
    
    func testSynchronousNotification_noPayload_receiveOnOpQueue() {
        
        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true
        
        var receiptThreadQOS: QualityOfService = .background
        var receiptThreadIsMainThread: Bool = false
        
        let opQueue = OperationQueue()
        opQueue.underlyingQueue = DispatchQueue.global(qos: .background)
        opQueue.qualityOfService = .background
        
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_noPayload_receiveOnOpQueue")
        Messenger.subscribe(self, notifName, {
            
            receivedNotif = true
            receiptThreadQOS = Thread.current.qualityOfService
            receiptThreadIsMainThread = Thread.current.isMainThread
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))

            XCTAssertTrue(publisherIsBlocked)
            
        }, opQueue: opQueue)
        
        for _ in 1...100 {
            
            receivedNotif = false
            
            publisherIsBlocked = true
            Messenger.publish(notifName)
            publisherIsBlocked = false
            
            // Notification should be received on the specified opQueue
            XCTAssertTrue(receivedNotif)
            XCTAssertEqual(receiptThreadQOS, opQueue.qualityOfService)
            XCTAssertFalse(receiptThreadIsMainThread)
        }
    }
    
    // MARK: Notifications with a payload object --------------------------------------------------------------------------------
    
    struct TestPayload<V>: NotificationPayload where V: Equatable {

        let notificationName: Notification.Name
        let equatableValue: V
    }
    
    func testSynchronousNotification_withPayload_noFilter() {
        
        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true
        
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_withPayload_noFilter")
        var receivedFloatVal: Float = 0

        Messenger.subscribe(self, notifName, {(thePayload: TestPayload<Float>) in
            
            receivedNotif = true
            receivedFloatVal = thePayload.equatableValue
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
        })
        
        for _ in 1...100 {
            
            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            let payload = TestPayload<Float>(notificationName: notifName, equatableValue: sentFloatVal)
            
            publisherIsBlocked = true
            Messenger.publish(payload)
            publisherIsBlocked = false
            
            XCTAssertTrue(receivedNotif)
            XCTAssertEqual(receivedFloatVal, sentFloatVal, accuracy: 0.001)
        }
    }
    
    func testSynchronousNotification_withPayload_withFilter_neverReceive() {
        
        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true
        
        var receivedFloatVal: Float = -1
        let neverReceiveFilter: (TestPayload<Float>) -> Bool = {(payload: TestPayload<Float>) in return false}
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_withPayload_withFilter_neverReceive")
        
        Messenger.subscribe(self, notifName, {(thePayload: TestPayload<Float>) in
            
            receivedNotif = true
            receivedFloatVal = thePayload.equatableValue
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: neverReceiveFilter)
        
        for _ in 1...100 {
            
            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            let payload = TestPayload<Float>(notificationName: notifName, equatableValue: sentFloatVal)
            
            publisherIsBlocked = true
            Messenger.publish(payload)
            publisherIsBlocked = false
            
            // Notification should never be received (filter always returns false)
            XCTAssertFalse(receivedNotif)
            XCTAssertEqual(receivedFloatVal, -1, accuracy: 0.001)
        }
    }
    
    func testSynchronousNotification_withPayload_withFilter_alwaysReceive() {
        
        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true
        
        var receivedFloatVal: Float = -1
        let alwaysReceiveFilter: (TestPayload<Float>) -> Bool = {(payload: TestPayload<Float>) in return true}
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_withPayload_withFilter_alwaysReceive")
        
        Messenger.subscribe(self, notifName, {(thePayload: TestPayload<Float>) in
            
            receivedNotif = true
            receivedFloatVal = thePayload.equatableValue
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: alwaysReceiveFilter)
        
        for _ in 1...100 {
            
            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            let payload = TestPayload<Float>(notificationName: notifName, equatableValue: sentFloatVal)
            
            publisherIsBlocked = true
            Messenger.publish(payload)
            publisherIsBlocked = false
            
            // Notification should always be received (filter always returns true)
            XCTAssertTrue(receivedNotif)
            XCTAssertEqual(receivedFloatVal, sentFloatVal, accuracy: 0.001)
        }
    }
    
    func testSynchronousNotification_withPayload_withFilter_conditional() {
        
        var filterCondition: Bool = false
        
        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true
        
        var receivedFloatVal: Float = -1
        let conditionalFilter: (TestPayload<Float>) -> Bool = {(payload: TestPayload<Float>) in return filterCondition}
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_withPayload_withFilter_alwaysReceive")
        
        Messenger.subscribe(self, notifName, {(thePayload: TestPayload<Float>) in
            
            receivedNotif = true
            receivedFloatVal = thePayload.equatableValue
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: conditionalFilter)
        
        for _ in 1...100 {
            
            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            let payload = TestPayload<Float>(notificationName: notifName, equatableValue: sentFloatVal)
            
            filterCondition = Bool.random()
            receivedFloatVal = -1
            
            publisherIsBlocked = true
            Messenger.publish(payload)
            publisherIsBlocked = false
            
            // Notification should be received if and only if filterCondition is true
            XCTAssertEqual(receivedNotif, filterCondition)
            XCTAssertEqual(receivedFloatVal, filterCondition ? sentFloatVal : -1, accuracy: 0.001)
        }
    }
    
    func testSynchronousNotification_withPayload_receiveOnOpQueue() {

        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true

        var receiptThreadQOS: QualityOfService = .background
        var receiptThreadIsMainThread: Bool = false

        let opQueue = OperationQueue()
        opQueue.underlyingQueue = DispatchQueue.global(qos: .background)
        opQueue.qualityOfService = .background

        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_withPayload_receiveOnOpQueue")
        var receivedFloatVal: Float = -1
        
        Messenger.subscribe(self, notifName, {(thePayload: TestPayload<Float>) in

            receivedNotif = true
            receiptThreadQOS = Thread.current.qualityOfService
            receiptThreadIsMainThread = Thread.current.isMainThread
            
            receivedFloatVal = thePayload.equatableValue

            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))

            XCTAssertTrue(publisherIsBlocked)

        }, opQueue: opQueue)

        for _ in 1...100 {

            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            let payload = TestPayload<Float>(notificationName: notifName, equatableValue: sentFloatVal)
            
            receivedFloatVal = -1

            publisherIsBlocked = true
            Messenger.publish(payload)
            publisherIsBlocked = false

            // Notification should be received on the specified opQueue
            XCTAssertTrue(receivedNotif)
            XCTAssertEqual(receiptThreadQOS, opQueue.qualityOfService)
            XCTAssertFalse(receiptThreadIsMainThread)
            XCTAssertEqual(receivedFloatVal, sentFloatVal, accuracy: 0.001)
        }
    }
    
    // MARK: Notifications with an arbitrary payload object --------------------------------------------------------------------------------
    
    func testSynchronousNotification_withArbitraryPayload_noFilter() {
        
        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true
        
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_withArbitraryPayload_noFilter")
        var receivedFloatVal: Float = 0

        Messenger.subscribe(self, notifName, {(thePayload: Float) in
            
            receivedNotif = true
            receivedFloatVal = thePayload
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
        })
        
        for _ in 1...100 {
            
            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            
            publisherIsBlocked = true
            Messenger.publish(notifName, payload: sentFloatVal)
            publisherIsBlocked = false
            
            XCTAssertTrue(receivedNotif)
            XCTAssertEqual(receivedFloatVal, sentFloatVal, accuracy: 0.001)
        }
    }
    
    func testSynchronousNotification_withArbitraryPayload_withFilter_neverReceive() {
        
        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true
        
        var receivedFloatVal: Float = -1
        let neverReceiveFilter: (Float) -> Bool = {(payload: Float) in return false}
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_withArbitraryPayload_withFilter_neverReceive")
        
        Messenger.subscribe(self, notifName, {(thePayload: Float) in
            
            receivedNotif = true
            receivedFloatVal = thePayload
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: neverReceiveFilter)
        
        for _ in 1...100 {
            
            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            
            publisherIsBlocked = true
            Messenger.publish(notifName, payload: sentFloatVal)
            publisherIsBlocked = false
            
            // Notification should never be received (filter always returns false)
            XCTAssertFalse(receivedNotif)
            XCTAssertEqual(receivedFloatVal, -1, accuracy: 0.001)
        }
    }
    
    func testSynchronousNotification_withArbitraryPayload_withFilter_alwaysReceive() {
        
        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true
        
        var receivedFloatVal: Float = -1
        let alwaysReceiveFilter: (Float) -> Bool = {(payload: Float) in return true}
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_withArbitraryPayload_withFilter_alwaysReceive")
        
        Messenger.subscribe(self, notifName, {(thePayload: Float) in
            
            receivedNotif = true
            receivedFloatVal = thePayload
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: alwaysReceiveFilter)
        
        for _ in 1...100 {
            
            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            
            publisherIsBlocked = true
            Messenger.publish(notifName, payload: sentFloatVal)
            publisherIsBlocked = false
            
            // Notification should always be received (filter always returns true)
            XCTAssertTrue(receivedNotif)
            XCTAssertEqual(receivedFloatVal, sentFloatVal, accuracy: 0.001)
        }
    }
    
    func testSynchronousNotification_withArbitraryPayload_withFilter_conditional() {
        
        var filterCondition: Bool = false
        
        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true
        
        var receivedFloatVal: Float = -1
        let conditionalFilter: (Float) -> Bool = {(payload: Float) in return filterCondition}
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_withArbitraryPayload_withFilter_alwaysReceive")
        
        Messenger.subscribe(self, notifName, {(thePayload: Float) in
            
            receivedNotif = true
            receivedFloatVal = thePayload
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: conditionalFilter)
        
        for _ in 1...100 {
            
            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            
            filterCondition = Bool.random()
            receivedFloatVal = -1
            
            publisherIsBlocked = true
            Messenger.publish(notifName, payload: sentFloatVal)
            publisherIsBlocked = false
            
            // Notification should be received if and only if filterCondition is true
            XCTAssertEqual(receivedNotif, filterCondition)
            XCTAssertEqual(receivedFloatVal, filterCondition ? sentFloatVal : -1, accuracy: 0.001)
        }
    }
    
    func testSynchronousNotification_withArbitraryPayload_receiveOnOpQueue() {

        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true

        var receiptThreadQOS: QualityOfService = .background
        var receiptThreadIsMainThread: Bool = false

        let opQueue = OperationQueue()
        opQueue.underlyingQueue = DispatchQueue.global(qos: .background)
        opQueue.qualityOfService = .background

        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_withArbitraryPayload_receiveOnOpQueue")
        var receivedFloatVal: Float = -1
        
        Messenger.subscribe(self, notifName, {(thePayload: Float) in

            receivedNotif = true
            receiptThreadQOS = Thread.current.qualityOfService
            receiptThreadIsMainThread = Thread.current.isMainThread
            
            receivedFloatVal = thePayload

            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))

            XCTAssertTrue(publisherIsBlocked)

        }, opQueue: opQueue)

        for _ in 1...100 {

            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            
            receivedFloatVal = -1

            publisherIsBlocked = true
            Messenger.publish(notifName, payload: sentFloatVal)
            publisherIsBlocked = false

            // Notification should be received on the specified opQueue
            XCTAssertTrue(receivedNotif)
            XCTAssertEqual(receiptThreadQOS, opQueue.qualityOfService)
            XCTAssertFalse(receiptThreadIsMainThread)
            XCTAssertEqual(receivedFloatVal, sentFloatVal, accuracy: 0.001)
        }
    }
    
    // TODO: Arbitrary payloads of different kinds: numbers, strings, structs, classes, tuples, enums, collections, etc.
    
    /*
        TODO: Error cases
        - Payload type doesn't match expected type
        - Expected payload, none was sent
        - Not expecting payload, payload was sent
        - Listening to wrong notifName (notifName mismatch)
     */
}
