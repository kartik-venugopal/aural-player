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

class Messenger_UnsubscribeTests: AuralTestCase {

    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func tearDown() {
        messenger.unsubscribeFromAll()
    }
    
    func testUnsubscribe_syncNotification() {
        
        var receivedNotif: Bool = false
        let notifName: Notification.Name = Notification.Name("testUnsubscribe")
        
        messenger.subscribe(to: notifName, handler: {
            receivedNotif = true
        })
        
        receivedNotif = false
        messenger.publish(notifName)
        XCTAssertTrue(receivedNotif)
        
        messenger.unsubscribe(from: notifName)
        receivedNotif = false
        messenger.publish(notifName)
        XCTAssertFalse(receivedNotif)
    }
    
    func testUnsubscribe_asyncNotification() {
        
        var receivedNotif: Bool = false
        let notifName: Notification.Name = Notification.Name("testUnsubscribe")
        
        messenger.subscribeAsync(to: notifName, handler: {
            receivedNotif = true
            
        })
        
        receivedNotif = false
        messenger.publish(notifName)
        
        executeAfter(0.2) {
            XCTAssertTrue(receivedNotif)
        }
        
        messenger.unsubscribe(from: notifName)
        receivedNotif = false
        messenger.publish(notifName)
        
        executeAfter(0.2) {
            XCTAssertFalse(receivedNotif)
        }
    }
    
    func testUnsubscribeAll() {
        
        var receivedNotif: Bool = false
        var receivedNotif2: Bool = false
        
        let notifName: Notification.Name = Notification.Name("testUnsubscribe")
        let notifName2: Notification.Name = Notification.Name("testUnsubscribe_2")
        
        messenger.subscribe(to: notifName, handler: {
            receivedNotif = true
        })
        
        messenger.subscribeAsync(to: notifName2, handler: {
            receivedNotif2 = true
            
        })
        
        receivedNotif = false
        messenger.publish(notifName)
        XCTAssertTrue(receivedNotif)
        
        receivedNotif2 = false
        messenger.publish(notifName2)
        
        executeAfter(0.2) {
            XCTAssertTrue(receivedNotif2)
        }
        
        messenger.unsubscribeFromAll()
        
        receivedNotif = false
        messenger.publish(notifName)
        XCTAssertFalse(receivedNotif)
        
        receivedNotif2 = false
        messenger.publish(notifName2)
        
        executeAfter(0.2) {
            XCTAssertFalse(receivedNotif2)
        }
    }
}
