import XCTest

class Messenger_UnsubscribeTests: AuralTestCase, NotificationSubscriber {

    override func setUp() {
        Messenger.unsubscribeAll(for: self)
    }
    
    override func tearDown() {
        Messenger.unsubscribeAll(for: self)
    }
    
    func testUnsubscribe() {
        
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
    
    func testUnsubscribeAll() {
        
        var receivedNotif: Bool = false
        let notifName: Notification.Name = Notification.Name("testUnsubscribe")
        
        Messenger.subscribe(self, notifName, {
            receivedNotif = true
        })
        
        receivedNotif = false
        Messenger.publish(notifName)
        XCTAssertTrue(receivedNotif)
        
        Messenger.unsubscribeAll(for: self)
        receivedNotif = false
        Messenger.publish(notifName)
        XCTAssertFalse(receivedNotif)
    }
}
