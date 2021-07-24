//
//  Messenger_AsynchronousNotifications_ArbitraryPayloadTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class Messenger_AsynchronousNotifications_ArbitraryPayloadTests: AuralTestCase {

    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func tearDown() {
        messenger.unsubscribeFromAll()
    }

    func testAsynchronousNotification_IntPayload() {
        doTestAsynchronousNotification_withEquatablePayload({Int.random(in: 0..<10000000)})
    }
    
    func testAsynchronousNotification_FloatPayload() {
        doTestAsynchronousNotification_withEquatablePayload({Float.random(in: 0..<10000000)})
    }
    
    func testAsynchronousNotification_DoublePayload() {
        doTestAsynchronousNotification_withEquatablePayload({Double.random(in: 0..<10000000)})
    }
    
    func testAsynchronousNotification_StringPayload() {
        doTestAsynchronousNotification_withEquatablePayload({return randomString(length: Int.random(in: 0..<1000))})
    }
    
    func testAsynchronousNotification_URLArrayPayload() {
        
        doTestAsynchronousNotification_withEquatablePayload({() -> [URL] in
            
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
    
    func testAsynchronousNotification_EnumPayload() {
        doTestAsynchronousNotification_withEquatablePayload({return TestEnum.allCases.randomElement() ?? .lofotenIslands})
    }
    
    struct TestPayloadStruct: Hashable {
        
        let id = UUID().uuidString
        
        static func == (lhs: TestPayloadStruct, rhs: TestPayloadStruct) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    func testAsynchronousNotification_StructPayload() {
        doTestAsynchronousNotification_withEquatablePayload({return TestPayloadStruct()})
    }
    
    class TestPayloadClass: NSObject {
        
        let id = UUID().uuidString
        
        override var hash: Int {
            return id.hashValue
        }
    }
    
    func testAsynchronousNotification_ClassPayload() {
        doTestAsynchronousNotification_withEquatablePayload({return TestPayloadClass()})
    }
    
    private func doTestAsynchronousNotification_withEquatablePayload<P>(_ valueProducer: () -> P, repetitionCount: Int = 10000) where P: Hashable {
     
        let receivedNotifCount: AtomicCounter<Int> = AtomicCounter()
        let notifName: Notification.Name = Notification.Name("doTestSynchronousNotification_withEquatablePayload")
        
        let sentPayloads: ConcurrentSet<P> = ConcurrentSet()
        let receivedPayloads: ConcurrentSet<P> = ConcurrentSet()
        
        messenger.subscribeAsync(to: notifName, handler: {(thePayload: P) in
            
            receivedNotifCount.increment()
            receivedPayloads.insert(thePayload)
            
        })
        
        for _ in 1...repetitionCount {
            
            let payload = valueProducer()
            sentPayloads.insert(payload)
            
            messenger.publish(notifName, payload: payload)
        }
        
        executeAfter(5) {
        
            XCTAssertEqual(receivedNotifCount.value, repetitionCount)
            XCTAssertEqual(receivedPayloads.set, sentPayloads.set)
        }
    }
}
