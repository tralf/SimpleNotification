import XCTest
import SimpleNotification

class MockInconsistentObjectHandler: InconsistentObjectHandler {

    var skipCount = 0
    var assertCount = 0
    var fatalCount = 0

    func handle(notification: Notification, withPolicy policy: InconsistentObjectPolicy, expectedType: Any) {
        switch policy {
        case .assert:
            assertCount += 1
        case .fatalError:
            fatalCount += 1
        case .skip:
            skipCount += 1
        }
    }

}

class NotificationObserverTests: XCTestCase {

    func testSimpleNotification() {

        let eventExpectation = XCTestExpectation(description: "Event expectation")

        let event = "Foo"
        let observer = NotificationObserver<Any>(event: event) { _ in
            eventExpectation.fulfill()
        }

        NotificationEmitter.fire(event: event)
        wait(for: [eventExpectation], timeout: 1)
        XCTAssertEqual(observer.invocationCount, 1)
    }

    func testNotificationWithAssociatedObject() {

        let eventExpectation = XCTestExpectation(description: "Event expectation")

        let event = "Foo"
        let observer = NotificationObserver<String>(event: event) { object in
            XCTAssertEqual(object, "Bar")
            eventExpectation.fulfill()
        }

        NotificationEmitter.fire(event: event, associatedObject: "Bar")
        wait(for: [eventExpectation], timeout: 1)
        XCTAssertEqual(observer.invocationCount, 1)
    }

    func testMultipleInvocation() {

        let eventExpectation = XCTestExpectation(description: "Event expectation")
        eventExpectation.expectedFulfillmentCount = 2

        let event = "Foo"
        let observer = NotificationObserver<Any>(event: event) { object in
            eventExpectation.fulfill()
        }

        NotificationEmitter.fire(event: event)
        NotificationEmitter.fire(event: event)
        wait(for: [eventExpectation], timeout: 1)
        XCTAssertEqual(observer.invocationCount, 2)
    }

    func testSkippingInconsistentAssociatedObject() {

        let eventExpectation = XCTestExpectation(description: "Event expectation")

        let event = "Foo"
        let observer = NotificationObserver<String>(event: event, policy: .skip) { object in
            eventExpectation.fulfill()
        }

        NotificationEmitter.fire(event: event)
        NotificationEmitter.fire(event: event, associatedObject: 12)
        NotificationEmitter.fire(event: event, associatedObject: "Bar")
        wait(for: [eventExpectation], timeout: 1)
        XCTAssertEqual(observer.invocationCount, 1)
    }

    func testAssertingInconsistentAssociatedObject() {

        let eventExpectation = XCTestExpectation(description: "Event expectation")
        let handler = MockInconsistentObjectHandler()

        let event = "Foo"
        let observer = NotificationObserver<String>(event: event, policy: .assert(message: nil), inconsistentObjectHandler: handler) { object in
            eventExpectation.fulfill()
        }

        NotificationEmitter.fire(event: event)
        NotificationEmitter.fire(event: event, associatedObject: 12)
        NotificationEmitter.fire(event: event, associatedObject: "Bar")
        wait(for: [eventExpectation], timeout: 1)
        XCTAssertEqual(observer.invocationCount, 1)
        XCTAssertEqual(handler.assertCount, 2)
        XCTAssertEqual(handler.skipCount, 0)
        XCTAssertEqual(handler.fatalCount, 0)
    }

    func testFatalErrorInconsistentAssociatedObject() {

        let eventExpectation = XCTestExpectation(description: "Event expectation")
        let handler = MockInconsistentObjectHandler()

        let event = "Foo"
        let observer = NotificationObserver<String>(event: event, policy: .fatalError(message: nil), inconsistentObjectHandler: handler) { object in
            eventExpectation.fulfill()
        }

        NotificationEmitter.fire(event: event)
        NotificationEmitter.fire(event: event, associatedObject: 12)
        NotificationEmitter.fire(event: event, associatedObject: "Bar")
        wait(for: [eventExpectation], timeout: 1)
        XCTAssertEqual(observer.invocationCount, 1)
        XCTAssertEqual(handler.assertCount, 0)
        XCTAssertEqual(handler.skipCount, 0)
        XCTAssertEqual(handler.fatalCount, 2)
    }

    func testSystemNotification() {

        class MockNotificationCenter: NotificationCenter {

            func mockPost() {
                post(Notification(name: .NSSystemClockDidChange))
            }
        }

        let notificationCenter = MockNotificationCenter()
        let eventExpectation = XCTestExpectation(description: "Event expectation")

        let observer = NotificationObserver<Any>(systemEvent: .NSSystemClockDidChange, notificationCenter: notificationCenter) { _ in
            eventExpectation.fulfill()
        }

        notificationCenter.mockPost()
        wait(for: [eventExpectation], timeout: 1)
        XCTAssertEqual(observer.invocationCount, 1)
    }

}
