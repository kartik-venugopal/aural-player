//
//  Messenger_SynchronousNotifications_ArbitraryPayloadTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class Messenger_SynchronousNotifications_ArbitraryPayloadTests: AuralTestCase {
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func tearDown() {
        messenger.unsubscribeFromAll()
    }

    func testSynchronousNotification_IntPayload() {
        doTestSynchronousNotification_withEquatablePayload({Int.random(in: 0..<10000000)})
    }
    
    func testSynchronousNotification_FloatPayload() {
        doTestSynchronousNotification_withEquatablePayload({Float.random(in: 0..<10000000)})
    }
    
    func testSynchronousNotification_DoublePayload() {
        doTestSynchronousNotification_withEquatablePayload({Double.random(in: 0..<10000000)})
    }
    
    func testSynchronousNotification_StringPayload() {
        doTestSynchronousNotification_withEquatablePayload({randomString(length: Int.random(in: 0..<1000))})
    }
    
    func testSynchronousNotification_URLArrayPayload() {
        
        doTestSynchronousNotification_withEquatablePayload({() -> [URL] in
            
            let count = Int.random(in: 1..<10000)
            var files: [URL] = []
            
            for ctr in 1...count {
                files.append(URL(fileURLWithPath: String(format: "/Dummy/Path/Track-%d.mp3", ctr)))
            }
            
            return files
            
        }, repetitionCount: 100)
    }
    
    enum TestEnum: CaseIterable {
        
        case lofotenIslands
        case tromso
        case aokigahara
        case portland
        case seattle
        case hinchinbrookIsland
    }
    
    func testSynchronousNotification_EnumPayload() {
        doTestSynchronousNotification_withEquatablePayload({TestEnum.allCases.randomElement() ?? .lofotenIslands})
    }
    
    struct TestPayloadStruct: Equatable {
        
        let id = UUID().uuidString
        
        static func == (lhs: TestPayloadStruct, rhs: TestPayloadStruct) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    func testSynchronousNotification_StructPayload() {
        doTestSynchronousNotification_withEquatablePayload({TestPayloadStruct()})
    }
    
    class TestPayloadClass: NSObject {
        
        let id = UUID().uuidString
        
        override var hash: Int {
            return id.hashValue
        }
    }
    
    func testSynchronousNotification_ClassPayload() {
        doTestSynchronousNotification_withEquatablePayload({TestPayloadClass()})
    }
    
    private func doTestSynchronousNotification_withEquatablePayload<P>(_ valueProducer: () -> P, repetitionCount: Int = 10000) where P: Equatable {
     
        var receivedNotif: Bool = false
        let notifName: Notification.Name = Notification.Name("doTestSynchronousNotification_withEquatablePayload")
        
        var payload: P = valueProducer()
        
        messenger.subscribe(to: notifName, handler: {(thePayload: P) in
            
            receivedNotif = true
            XCTAssertEqual(thePayload, payload)
        })
        
        for _ in 1...repetitionCount {
            
            receivedNotif = false
            payload = valueProducer()
            
            messenger.publish(notifName, payload: payload)
            
            XCTAssertTrue(receivedNotif)
        }
    }
}
