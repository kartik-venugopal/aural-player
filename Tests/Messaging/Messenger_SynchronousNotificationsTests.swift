//
//  Messenger_SynchronousNotificationsTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class Messenger_SynchronousNotificationsTests: AuralTestCase {

    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func tearDown() {
        messenger.unsubscribeFromAll()
    }

    func testSynchronousNotification_noPayload_noFilter() {
        
        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true
        
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_noPayload_noFilter")
        
        messenger.subscribe(to: notifName, handler: {
            
            receivedNotif = true
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
        })
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            receivedNotif = false
            
            publisherIsBlocked = true
            messenger.publish(notifName)
            publisherIsBlocked = false
            
            XCTAssertTrue(receivedNotif)
        }
    }
    
    func testSynchronousNotification_noPayload_withFilter_neverReceive() {
        
        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true
        
        let neverReceiveFilter: () -> Bool = {return false}
        
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_noPayload_withFilter_neverReceive")
        messenger.subscribe(to: notifName, handler: {
            
            receivedNotif = true
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: neverReceiveFilter)
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            receivedNotif = false
            
            publisherIsBlocked = true
            messenger.publish(notifName)
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
        messenger.subscribe(to: notifName, handler: {
            
            receivedNotif = true
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: alwaysReceiveFilter)
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            receivedNotif = false
            
            publisherIsBlocked = true
            messenger.publish(notifName)
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
        messenger.subscribe(to: notifName, handler: {
            
            receivedNotif = true
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: conditionalFilter)
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            receivedNotif = false
            filterCondition = .random()
            
            publisherIsBlocked = true
            messenger.publish(notifName)
            publisherIsBlocked = false
            
            // Notification should be received if and only if filterCondition is true
            XCTAssertEqual(receivedNotif, filterCondition)
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

        messenger.subscribe(to: notifName, handler: {(thePayload: TestPayload<Float>) in
            
            receivedNotif = true
            receivedFloatVal = thePayload.equatableValue
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
        })
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            let payload = TestPayload<Float>(notificationName: notifName, equatableValue: sentFloatVal)
            
            publisherIsBlocked = true
            messenger.publish(payload)
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
        
        messenger.subscribe(to: notifName, handler: {(thePayload: TestPayload<Float>) in
            
            receivedNotif = true
            receivedFloatVal = thePayload.equatableValue
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: neverReceiveFilter)
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            let payload = TestPayload<Float>(notificationName: notifName, equatableValue: sentFloatVal)
            
            publisherIsBlocked = true
            messenger.publish(payload)
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
        
        messenger.subscribe(to: notifName, handler: {(thePayload: TestPayload<Float>) in
            
            receivedNotif = true
            receivedFloatVal = thePayload.equatableValue
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: alwaysReceiveFilter)
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            let payload = TestPayload<Float>(notificationName: notifName, equatableValue: sentFloatVal)
            
            publisherIsBlocked = true
            messenger.publish(payload)
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
        
        messenger.subscribe(to: notifName, handler: {(thePayload: TestPayload<Float>) in
            
            receivedNotif = true
            receivedFloatVal = thePayload.equatableValue
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: conditionalFilter)
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            let payload = TestPayload<Float>(notificationName: notifName, equatableValue: sentFloatVal)
            
            filterCondition = .random()
            receivedFloatVal = -1
            
            publisherIsBlocked = true
            messenger.publish(payload)
            publisherIsBlocked = false
            
            // Notification should be received if and only if filterCondition is true
            XCTAssertEqual(receivedNotif, filterCondition)
            XCTAssertEqual(receivedFloatVal, filterCondition ? sentFloatVal : -1, accuracy: 0.001)
        }
    }
    
    // MARK: Notifications with an arbitrary payload object --------------------------------------------------------------------------------
    
    func testSynchronousNotification_withArbitraryPayload_noFilter() {
        
        var receivedNotif: Bool = false
        var publisherIsBlocked: Bool = true
        
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_withArbitraryPayload_noFilter")
        var receivedFloatVal: Float = 0

        messenger.subscribe(to: notifName, handler: {(thePayload: Float) in
            
            receivedNotif = true
            receivedFloatVal = thePayload
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
        })
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            
            publisherIsBlocked = true
            messenger.publish(notifName, payload: sentFloatVal)
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
        
        messenger.subscribe(to: notifName, handler: {(thePayload: Float) in
            
            receivedNotif = true
            receivedFloatVal = thePayload
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: neverReceiveFilter)
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            
            publisherIsBlocked = true
            messenger.publish(notifName, payload: sentFloatVal)
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
        
        messenger.subscribe(to: notifName, handler: {(thePayload: Float) in
            
            receivedNotif = true
            receivedFloatVal = thePayload
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: alwaysReceiveFilter)
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            
            publisherIsBlocked = true
            messenger.publish(notifName, payload: sentFloatVal)
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
        
        messenger.subscribe(to: notifName, handler: {(thePayload: Float) in
            
            receivedNotif = true
            receivedFloatVal = thePayload
            
            // Simulate some work being done
            usleep(UInt32.random(in: 1000...100000))
            
            XCTAssertTrue(publisherIsBlocked)
            
        }, filter: conditionalFilter)
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            receivedNotif = false
            
            let sentFloatVal: Float = Float.random(in: 0...3600000)
            
            filterCondition = .random()
            receivedFloatVal = -1
            
            publisherIsBlocked = true
            messenger.publish(notifName, payload: sentFloatVal)
            publisherIsBlocked = false
            
            // Notification should be received if and only if filterCondition is true
            XCTAssertEqual(receivedNotif, filterCondition)
            XCTAssertEqual(receivedFloatVal, filterCondition ? sentFloatVal : -1, accuracy: 0.001)
        }
    }
    
    // MARK: Tests for error cases -------------------------------------------------------------------------------------------
    
    func testSynchronousNotification_payloadExpected_payloadTypeMismatch() {
        
        var receivedNotif: Bool = false
        
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_payloadExpected_payloadTypeMismatch")
        
        messenger.subscribe(to: notifName, handler: {(thePayload: Double) in
            receivedNotif = true
        })
        
        // Subscriber is expecting a Double, but send a Float
        messenger.publish(notifName, payload: Float(234.435364))
        
        XCTAssertFalse(receivedNotif)
    }
    
    func testSynchronousNotification_payloadExpected_noPayloadProvided() {
        
        var receivedNotif: Bool = false
        
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_payloadExpected_noPayloadProvided")
        
        messenger.subscribe(to: notifName, handler: {(thePayload: Double) in
            receivedNotif = true
        })
        
        // Subscriber is expecting a Double, but don't send a payload
        messenger.publish(notifName)
        
        XCTAssertFalse(receivedNotif)
    }
    
    func testSynchronousNotification_noPayloadExpected_payloadProvided_payloadIgnored() {
        
        var receivedNotif: Bool = false
        
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_noPayloadExpected_payloadProvided_payloadIgnored")
        
        messenger.subscribe(to: notifName, handler: {
            receivedNotif = true
        })
        
        // Subscriber is expecting no payload, but send a Float
        messenger.publish(notifName, payload: Float(234.435364))
        
        XCTAssertTrue(receivedNotif)
    }
    
    func testSynchronousNotification_notificationNameMismatch() {
        
        var receivedNotif: Bool = false
        
        let notifName: Notification.Name = Notification.Name("testSynchronousNotification_notificationNameMismatch")
        let wrongNotifName: Notification.Name = Notification.Name("testSynchronousNotification_notificationNameMismatch_xyz")
        
        messenger.subscribe(to: wrongNotifName, handler: {
            receivedNotif = true
        })
        
        // Subscriber is subscribed to the wrong notification name, so this notification should not be received.
        messenger.publish(notifName)
        
        XCTAssertFalse(receivedNotif)
    }
}
