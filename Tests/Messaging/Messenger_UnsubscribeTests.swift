//
//  Messenger_UnsubscribeTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class Messenger_UnsubscribeTests: AuralTestCase, NotificationSubscriber {

    override func setUp() {
        Messenger.unsubscribeAll(for: self)
    }
    
    override func tearDown() {
        Messenger.unsubscribeAll(for: self)
    }
    
    func testUnsubscribe_syncNotification() {
        
        var receivedNotif: Bool = false
        let notifName: Notification.Name = Notification.Name("testUnsubscribe")
        
        Messenger.subscribe(self, notifName, {
            receivedNotif = true
        })
        
        receivedNotif = false
        Messenger.publish(notifName)
        XCTAssertTrue(receivedNotif)
        
        Messenger.unsubscribe(self, notifName)
        receivedNotif = false
        Messenger.publish(notifName)
        XCTAssertFalse(receivedNotif)
    }
    
    func testUnsubscribe_asyncNotification() {
        
        var receivedNotif: Bool = false
        let notifName: Notification.Name = Notification.Name("testUnsubscribe")
        
        Messenger.subscribeAsync(self, notifName, {
            receivedNotif = true
            
        }, queue: DispatchQueue.global(qos: .userInteractive))
        
        receivedNotif = false
        Messenger.publish(notifName)
        
        executeAfter(0.2) {
            XCTAssertTrue(receivedNotif)
        }
        
        Messenger.unsubscribe(self, notifName)
        receivedNotif = false
        Messenger.publish(notifName)
        
        executeAfter(0.2) {
            XCTAssertFalse(receivedNotif)
        }
    }
    
    func testUnsubscribeAll() {
        
        var receivedNotif: Bool = false
        var receivedNotif2: Bool = false
        
        let notifName: Notification.Name = Notification.Name("testUnsubscribe")
        let notifName2: Notification.Name = Notification.Name("testUnsubscribe_2")
        
        Messenger.subscribe(self, notifName, {
            receivedNotif = true
        })
        
        Messenger.subscribeAsync(self, notifName2, {
            receivedNotif2 = true
            
        }, queue: DispatchQueue.global(qos: .userInteractive))
        
        receivedNotif = false
        Messenger.publish(notifName)
        XCTAssertTrue(receivedNotif)
        
        receivedNotif2 = false
        Messenger.publish(notifName2)
        
        executeAfter(0.2) {
            XCTAssertTrue(receivedNotif2)
        }
        
        Messenger.unsubscribeAll(for: self)
        
        receivedNotif = false
        Messenger.publish(notifName)
        XCTAssertFalse(receivedNotif)
        
        receivedNotif2 = false
        Messenger.publish(notifName2)
        
        executeAfter(0.2) {
            XCTAssertFalse(receivedNotif2)
        }
    }
}
