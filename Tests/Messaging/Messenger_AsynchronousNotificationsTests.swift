import XCTest

class Messenger_AsynchronousNotificationsTests: AuralTestCase, NotificationSubscriber {

    override func setUp() {
        Messenger.unsubscribeAll(for: self)
    }
    
    override func tearDown() {
        Messenger.unsubscribeAll(for: self)
    }

    func testAsynchronousNotification_noPayload_noFilter() {
        
        let receivedNotifCount: AtomicCounter = AtomicCounter()
        
        var publisherIsBlocked: [Bool] = []
        
        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_noPayload_noFilter")
        
        Messenger.subscribeAsync(self, notifName, {
            
            let notifIndex: Int = receivedNotifCount.getAndIncrement()
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...10000))
            
            XCTAssertFalse(publisherIsBlocked[notifIndex])
            
        }, queue: DispatchQueue.global(qos: .userInteractive))
        
        for producerIndex in 0..<100 {
            
            publisherIsBlocked.append(true)
            Messenger.publish(notifName)
            publisherIsBlocked[producerIndex] = false
        }
        
        executeAfter(2) {
            XCTAssertEqual(receivedNotifCount.value, 100)
        }
    }
    
    func testAsynchronousNotification_noPayload_withFilter_neverReceive() {

        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_noPayload_withFilter_neverReceive")
        let neverReceiveFilter: () -> Bool = {return false}
        
        let receivedNotifCount: AtomicCounter = AtomicCounter()
        
        Messenger.subscribeAsync(self, notifName, {
            
            receivedNotifCount.increment()
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...10000))
            
        }, filter: neverReceiveFilter,
           queue: DispatchQueue.global(qos: .userInteractive))
        
        for _ in 1...100 {
            Messenger.publish(notifName)
        }
        
        executeAfter(2) {
            
            // Notification should never be received (filter always returns false)
            XCTAssertEqual(receivedNotifCount.value, 0)
        }
    }

    func testAsynchronousNotification_noPayload_withFilter_alwaysReceive() {

        let receivedNotifCount: AtomicCounter = AtomicCounter()
        let alwaysReceiveFilter: () -> Bool = {return true}
        
        var publisherIsBlocked: [Bool] = []
        
        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_noPayload_withFilter_alwaysReceive")
        
        Messenger.subscribeAsync(self, notifName, {
            
            let notifIndex: Int = receivedNotifCount.getAndIncrement()
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...10000))
            
            XCTAssertFalse(publisherIsBlocked[notifIndex])
            
        }, filter: alwaysReceiveFilter,
           queue: DispatchQueue.global(qos: .userInteractive))
        
        for producerIndex in 0..<100 {
            
            publisherIsBlocked.append(true)
            Messenger.publish(notifName)
            publisherIsBlocked[producerIndex] = false
        }
        
        executeAfter(2) {
            XCTAssertEqual(receivedNotifCount.value, 100)
        }
    }

    func testAsynchronousNotification_noPayload_withFilter_conditional() {

        let filterConditionValues: ConcurrentQueue<Bool> = ConcurrentQueue<Bool>("testAsynchronousNotification_noPayload_withFilter_conditional")
        
        let receivedNotifCount: AtomicCounter = AtomicCounter()
        let conditionalFilter: () -> Bool = {return filterConditionValues.dequeue() ?? false}
        
        var publisherIsBlocked: [Bool] = []
        
        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_noPayload_withFilter_conditional")
        
        Messenger.subscribeAsync(self, notifName, {
            
            let notifIndex: Int = receivedNotifCount.getAndIncrement()
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...10000))
            
            XCTAssertFalse(publisherIsBlocked[notifIndex])
            
        }, filter: conditionalFilter,
           queue: DispatchQueue.global(qos: .userInteractive))
        
        var expectedReceiptCount: Int = 0
        
        for producerIndex in 0..<100 {
            
            let filterAllowsReceipt = Bool.random()
            filterConditionValues.enqueue(filterAllowsReceipt)
            expectedReceiptCount += filterAllowsReceipt ? 1 : 0
            
            publisherIsBlocked.append(true)
            Messenger.publish(notifName)
            publisherIsBlocked[producerIndex] = false
        }
        
        executeAfter(2) {
            XCTAssertEqual(receivedNotifCount.value, expectedReceiptCount)
        }
    }

    // MARK: Notifications with a payload object --------------------------------------------------------------------------------

    struct TestPayload<V>: NotificationPayload where V: Equatable {

        let notificationName: Notification.Name
        let equatableValue: V
    }

    func testAsynchronousNotification_withPayload_noFilter() {

        let receivedNotifCount: AtomicCounter = AtomicCounter()
        
        var publisherIsBlocked: [Bool] = []
        
        let sentValues: ConcurrentSet<Double> = ConcurrentSet<Double>("testAsynchronousNotification_noPayload_withFilter_alwaysReceive-producer")
        let receivedValues: ConcurrentSet<Double> = ConcurrentSet<Double>("testAsynchronousNotification_noPayload_withFilter_alwaysReceive-consumer")
        
        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_noPayload_withFilter_alwaysReceive")
        
        Messenger.subscribeAsync(self, notifName, {(thePayload: TestPayload<Double>) in
            
            let notifIndex: Int = receivedNotifCount.getAndIncrement()
            receivedValues.insert(thePayload.equatableValue)
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...10000))
            
            XCTAssertFalse(publisherIsBlocked[notifIndex])
            
        }, queue: DispatchQueue.global(qos: .userInteractive))
        
        for producerIndex in 0..<100 {
            
            let sentVal: Double = Double.random(in: 0...3600000)
            let payload = TestPayload<Double>(notificationName: notifName, equatableValue: sentVal)
            sentValues.insert(sentVal)
            
            publisherIsBlocked.append(true)
            Messenger.publish(payload)
            publisherIsBlocked[producerIndex] = false
        }
        
        executeAfter(2) {
            
            XCTAssertEqual(receivedNotifCount.value, 100)
            XCTAssertEqual(receivedValues.set, sentValues.set)
        }
    }
    
    func testAsynchronousNotification_withPayload_withFilter_alwaysReceive() {

        let receivedNotifCount: AtomicCounter = AtomicCounter()
        let alwaysReceiveFilter: (TestPayload<Double>) -> Bool = {(thePayload: TestPayload<Double>) in return true}
        
        var publisherIsBlocked: [Bool] = []
        let sentValues: ConcurrentSet<Double> = ConcurrentSet<Double>("testAsynchronousNotification_withPayload_withFilter_alwaysReceive-producer")
        let receivedValues: ConcurrentSet<Double> = ConcurrentSet<Double>("testAsynchronousNotification_withPayload_withFilter_alwaysReceive-consumer")
        
        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_withPayload_withFilter_alwaysReceive")
        
        Messenger.subscribeAsync(self, notifName, {(thePayload: TestPayload<Double>) in
            
            let notifIndex: Int = receivedNotifCount.getAndIncrement()
            receivedValues.insert(thePayload.equatableValue)
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...10000))
            
            XCTAssertFalse(publisherIsBlocked[notifIndex])
            
        }, filter: alwaysReceiveFilter,
           queue: DispatchQueue.global(qos: .userInteractive))
        
        for producerIndex in 0..<100 {
            
            let sentVal: Double = Double.random(in: 0...3600000)
            let payload = TestPayload<Double>(notificationName: notifName, equatableValue: sentVal)
            sentValues.insert(sentVal)
            
            publisherIsBlocked.append(true)
            Messenger.publish(payload)
            publisherIsBlocked[producerIndex] = false
        }
        
        executeAfter(2) {
            
            XCTAssertEqual(receivedNotifCount.value, 100)
            XCTAssertEqual(receivedValues.set, sentValues.set)
        }
    }

    func testAsynchronousNotification_withPayload_withFilter_neverReceive() {

        let receivedNotifCount: AtomicCounter = AtomicCounter()
        let receivedValues: ConcurrentSet<Double> = ConcurrentSet<Double>("testAsynchronousNotification_withPayload_withFilter_neverReceive-consumer")
        
        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_withPayload_withFilter_neverReceive")
        let neverReceiveFilter: (TestPayload<Double>) -> Bool = {(thePayload: TestPayload<Double>) in return false}
        
        Messenger.subscribeAsync(self, notifName, {(thePayload: TestPayload<Double>) in
            
            receivedNotifCount.increment()
            receivedValues.insert(thePayload.equatableValue)
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...10000))
            
        }, filter: neverReceiveFilter,
           queue: DispatchQueue.global(qos: .userInteractive))
        
        for _ in 1...100 {
            
            let sentVal: Double = Double.random(in: 0...3600000)
            let payload = TestPayload<Double>(notificationName: notifName, equatableValue: sentVal)
            
            Messenger.publish(payload)
        }
        
        executeAfter(2) {
            
            XCTAssertEqual(receivedNotifCount.value, 0)
            XCTAssertEqual(receivedValues.set.count, 0)
        }
    }

    func testAsynchronousNotification_withPayload_withFilter_conditional() {

        let receivedNotifCount: AtomicCounter = AtomicCounter()
        let conditionalFilter: (TestPayload<Double>) -> Bool = {(thePayload: TestPayload<Double>) in return thePayload.equatableValue < 300}
        
        var publisherIsBlocked: [Bool] = []
        let sentValues: ConcurrentSet<Double> = ConcurrentSet<Double>("testAsynchronousNotification_withPayload_withFilter_conditional-producer")
        let receivedValues: ConcurrentSet<Double> = ConcurrentSet<Double>("testAsynchronousNotification_withPayload_withFilter_conditional-consumer")
        
        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_withPayload_withFilter_conditional")
        
        Messenger.subscribeAsync(self, notifName, {(thePayload: TestPayload<Double>) in
            
            let notifIndex: Int = receivedNotifCount.getAndIncrement()
            receivedValues.insert(thePayload.equatableValue)
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...10000))
            
            XCTAssertFalse(publisherIsBlocked[notifIndex])
            
        }, filter: conditionalFilter,
           queue: DispatchQueue.global(qos: .userInteractive))
        
        var expectedReceiptCount: Int = 0
        
        for producerIndex in 0..<100 {
            
            let sentVal: Double = Double.random(in: 0...3600)
            let payload = TestPayload<Double>(notificationName: notifName, equatableValue: sentVal)
            
            let filterAllowsReceipt = conditionalFilter(payload)
            expectedReceiptCount += filterAllowsReceipt ? 1 : 0
            
            if filterAllowsReceipt {
                sentValues.insert(sentVal)
            }
            
            publisherIsBlocked.append(true)
            Messenger.publish(payload)
            publisherIsBlocked[producerIndex] = false
        }
        
        executeAfter(2) {
            XCTAssertEqual(receivedNotifCount.value, expectedReceiptCount)
            XCTAssertEqual(receivedValues.set, sentValues.set)
        }
    }

    // MARK: Notifications with an arbitrary payload object --------------------------------------------------------------------------------

    func testAsynchronousNotification_withArbitraryPayload_noFilter() {
        
        let receivedNotifCount: AtomicCounter = AtomicCounter()
        
        var publisherIsBlocked: [Bool] = []
        
        let sentValues: ConcurrentSet<Double> = ConcurrentSet<Double>("testAsynchronousNotification_noPayload_withFilter_alwaysReceive-producer")
        let receivedValues: ConcurrentSet<Double> = ConcurrentSet<Double>("testAsynchronousNotification_noPayload_withFilter_alwaysReceive-consumer")
        
        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_noPayload_withFilter_alwaysReceive")
        
        Messenger.subscribeAsync(self, notifName, {(thePayload: Double) in
            
            let notifIndex: Int = receivedNotifCount.getAndIncrement()
            receivedValues.insert(thePayload)
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...10000))
            
            XCTAssertFalse(publisherIsBlocked[notifIndex])
            
        }, queue: DispatchQueue.global(qos: .userInteractive))
        
        for producerIndex in 0..<100 {
            
            let sentVal: Double = Double.random(in: 0...3600000)
            sentValues.insert(sentVal)
            
            publisherIsBlocked.append(true)
            Messenger.publish(notifName, payload: sentVal)
            publisherIsBlocked[producerIndex] = false
        }
        
        executeAfter(2) {
            
            XCTAssertEqual(receivedNotifCount.value, 100)
            XCTAssertEqual(receivedValues.set, sentValues.set)
        }
    }
    
    func testAsynchronousNotification_withArbitraryPayload_withFilter_alwaysReceive() {
        
        let receivedNotifCount: AtomicCounter = AtomicCounter()
        let alwaysReceiveFilter: (Double) -> Bool = {(thePayload: Double) in return true}
        
        var publisherIsBlocked: [Bool] = []
        let sentValues: ConcurrentSet<Double> = ConcurrentSet<Double>("testAsynchronousNotification_withArbitraryPayload_withFilter_alwaysReceive-producer")
        let receivedValues: ConcurrentSet<Double> = ConcurrentSet<Double>("testAsynchronousNotification_withArbitraryPayload_withFilter_alwaysReceive-consumer")
        
        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_withArbitraryPayload_withFilter_alwaysReceive")
        
        Messenger.subscribeAsync(self, notifName, {(thePayload: Double) in
            
            let notifIndex: Int = receivedNotifCount.getAndIncrement()
            receivedValues.insert(thePayload)
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...10000))
            
            XCTAssertFalse(publisherIsBlocked[notifIndex])
            
        }, filter: alwaysReceiveFilter,
           queue: DispatchQueue.global(qos: .userInteractive))
        
        for producerIndex in 0..<100 {
            
            let sentVal: Double = Double.random(in: 0...3600000)
            sentValues.insert(sentVal)
            
            publisherIsBlocked.append(true)
            Messenger.publish(notifName, payload: sentVal)
            publisherIsBlocked[producerIndex] = false
        }
        
        executeAfter(2) {
            
            XCTAssertEqual(receivedNotifCount.value, 100)
            XCTAssertEqual(receivedValues.set, sentValues.set)
        }
    }
    
    func testAsynchronousNotification_withArbitraryPayload_withFilter_neverReceive() {
        
        let receivedNotifCount: AtomicCounter = AtomicCounter()
        let receivedValues: ConcurrentSet<Double> = ConcurrentSet<Double>("testAsynchronousNotification_withArbitraryPayload_withFilter_neverReceive-consumer")
        
        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_withArbitraryPayload_withFilter_neverReceive")
        let neverReceiveFilter: (Double) -> Bool = {(thePayload: Double) in return false}
        
        Messenger.subscribeAsync(self, notifName, {(thePayload: Double) in
            
            receivedNotifCount.increment()
            receivedValues.insert(thePayload)
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...10000))
            
        }, filter: neverReceiveFilter,
           queue: DispatchQueue.global(qos: .userInteractive))
        
        for _ in 1...100 {
            
            let sentVal: Double = Double.random(in: 0...3600000)
            Messenger.publish(notifName, payload: sentVal)
        }
        
        executeAfter(2) {
            
            XCTAssertEqual(receivedNotifCount.value, 0)
            XCTAssertEqual(receivedValues.set.count, 0)
        }
    }
    
    func testAsynchronousNotification_withArbitraryPayload_withFilter_conditional() {
        
        let receivedNotifCount: AtomicCounter = AtomicCounter()
        let conditionalFilter: (Double) -> Bool = {(thePayload: Double) in return thePayload < 300}
        
        var publisherIsBlocked: [Bool] = []
        let sentValues: ConcurrentSet<Double> = ConcurrentSet<Double>("testAsynchronousNotification_withArbitraryPayload_withFilter_conditional-producer")
        let receivedValues: ConcurrentSet<Double> = ConcurrentSet<Double>("testAsynchronousNotification_withArbitraryPayload_withFilter_conditional-consumer")
        
        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_withArbitraryPayload_withFilter_conditional")
        
        Messenger.subscribeAsync(self, notifName, {(thePayload: Double) in
            
            let notifIndex: Int = receivedNotifCount.getAndIncrement()
            receivedValues.insert(thePayload)
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...10000))
            
            XCTAssertFalse(publisherIsBlocked[notifIndex])
            
        }, filter: conditionalFilter,
           queue: DispatchQueue.global(qos: .userInteractive))
        
        var expectedReceiptCount: Int = 0
        
        for producerIndex in 0..<100 {
            
            let sentVal: Double = Double.random(in: 0...3600)
            let filterAllowsReceipt = conditionalFilter(sentVal)
            expectedReceiptCount += filterAllowsReceipt ? 1 : 0
            
            if filterAllowsReceipt {
                sentValues.insert(sentVal)
            }
            
            publisherIsBlocked.append(true)
            Messenger.publish(notifName, payload: sentVal)
            publisherIsBlocked[producerIndex] = false
        }
        
        executeAfter(2) {
            XCTAssertEqual(receivedNotifCount.value, expectedReceiptCount)
            XCTAssertEqual(receivedValues.set, sentValues.set)
        }
    }
    
    // TODO: Arbitrary payloads of different kinds: numbers, strings, structs, classes, tuples, enums, collections, etc.
    
    // MARK: Tests for error cases -------------------------------------------------------------------------------------------
    
    func testAsynchronousNotification_payloadExpected_payloadTypeMismatch() {
        
        var receivedNotif: Bool = false
        
        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_payloadExpected_payloadTypeMismatch")
        
        Messenger.subscribeAsync(self, notifName, {(thePayload: Double) in
            receivedNotif = true
            
        }, queue: DispatchQueue.global(qos: .userInteractive))
        
        // Subscriber is expecting a Double, but send a Float
        Messenger.publish(notifName, payload: Float(234.435364))
        
        executeAfter(0.2) {
            XCTAssertFalse(receivedNotif)
        }
    }
    
    func testAsynchronousNotification_payloadExpected_noPayloadProvided() {
        
        var receivedNotif: Bool = false
        
        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_payloadExpected_noPayloadProvided")
        
        Messenger.subscribeAsync(self, notifName, {(thePayload: Double) in
            receivedNotif = true
            
        }, queue: DispatchQueue.global(qos: .userInteractive))
        
        // Subscriber is expecting a Double, but don't send a payload
        Messenger.publish(notifName)
        
        executeAfter(0.2) {
            XCTAssertFalse(receivedNotif)
        }
    }
    
    func testAsynchronousNotification_noPayloadExpected_payloadProvided_payloadIgnored() {
        
        var receivedNotif: Bool = false
        
        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_noPayloadExpected_payloadProvided_payloadIgnored")
        
        Messenger.subscribeAsync(self, notifName, {
            receivedNotif = true
            
        }, queue: DispatchQueue.global(qos: .userInteractive))
        
        // Subscriber is expecting no payload, but send a Float
        Messenger.publish(notifName, payload: Float(234.435364))
        
        executeAfter(0.2) {
            XCTAssertTrue(receivedNotif)
        }
    }
    
    func testAsynchronousNotification_notificationNameMismatch() {
        
        var receivedNotif: Bool = false
        
        let notifName: Notification.Name = Notification.Name("testAsynchronousNotification_notificationNameMismatch")
        let wrongNotifName: Notification.Name = Notification.Name("testAsynchronousNotification_notificationNameMismatch_xyz")
        
        Messenger.subscribeAsync(self, wrongNotifName, {
            receivedNotif = true
            
        }, queue: DispatchQueue.global(qos: .userInteractive))
        
        // Subscriber is subscribed to the wrong notification name, so this notification should not be received.
        Messenger.publish(notifName)
        
        executeAfter(0.2) {
            XCTAssertFalse(receivedNotif)
        }
    }
}
