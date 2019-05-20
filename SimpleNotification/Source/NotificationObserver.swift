//
//  NotificationObserver.swift
//  SimpleNotification
//
//  Created by Viktor Kalinchuk on 5/14/19.
//  Copyright © 2019 Viktor Kalinchuk. All rights reserved.
//

import Foundation

public struct NotificationEmitter {

    fileprivate static let notificationObjectKey = "notificationObjectKey"

    public static func fire(event: NotificationRepresentable, sender: Any? = nil, associatedObject: Any? = nil, notificationCenter: NotificationCenter = .default) {
        notificationCenter.post(name: event.notificationName, object: sender, userInfo: [notificationObjectKey: associatedObject as Any])
    }

}

public enum InconsistentObjectPolicy {
    case fatalError(message: String?)
    case assert(message: String?)
    case skip
}

public protocol InconsistentObjectHandler {

    func handle(notification: Notification, withPolicy policy: InconsistentObjectPolicy, expectedType: Any)
}

public struct StandardInconsistentObjectHandler: InconsistentObjectHandler {

    public static let instance = StandardInconsistentObjectHandler()

    private init() {}

    public func handle(notification: Notification, withPolicy policy: InconsistentObjectPolicy, expectedType: Any) {
        switch policy {
        case .fatalError(let message):
            fatalError(message ?? standardFailMessage(for: notification, expectedType: expectedType))
        case .assert(let message):
            assertionFailure(message ?? standardFailMessage(for: notification, expectedType: expectedType))
        case .skip:
            break
        }
    }

    private func standardFailMessage(for notification: Notification, expectedType: Any) -> String {
        return  """
                \n*** NotificationObserver assertion *** Unexpected type of object received for \n<Notification: \(notification)>\n Must be \(expectedType.self)
                \n*** If this behaviour is unwanted, consider setting policy to \(InconsistentObjectPolicy.self).\(InconsistentObjectPolicy.skip) or provide custom policy.\n
                """
    }
}

public final class NotificationObserver<T> {

    private let notificationCenter: NotificationCenter
    private let policy: InconsistentObjectPolicy
    private let inconsistentObjectHandler: InconsistentObjectHandler

    private let callback: (T) -> Void

    private(set) public var invocationCount = 0

    public convenience init(event: NotificationRepresentable,
                     object: Any? = nil,
                     notificationCenter: NotificationCenter = .default,
                     policy: InconsistentObjectPolicy = .assert(message: nil),
                     inconsistentObjectHandler: InconsistentObjectHandler = StandardInconsistentObjectHandler.instance,
                     callback: @escaping (T) -> Void) {

        self.init(notification: event.notificationName, object: object, notificationCenter: notificationCenter, policy: policy, inconsistentObjectHandler: inconsistentObjectHandler, callback: callback)
    }

    public convenience init(systemEvent: Notification.Name,
                     object: Any? = nil,
                     notificationCenter: NotificationCenter = .default,
                     policy: InconsistentObjectPolicy = .assert(message: nil),
                     inconsistentObjectHandler: InconsistentObjectHandler = StandardInconsistentObjectHandler.instance,
                     callback: @escaping (T) -> Void) {

        self.init(notification: systemEvent, object: object, notificationCenter: notificationCenter, policy: policy, inconsistentObjectHandler: inconsistentObjectHandler, callback: callback)
    }

    private init(notification: Notification.Name,
                 object: Any?,
                 notificationCenter: NotificationCenter,
                 policy: InconsistentObjectPolicy,
                 inconsistentObjectHandler: InconsistentObjectHandler,
                 callback: @escaping (T) -> Void) {

        self.notificationCenter = notificationCenter
        self.callback = callback
        self.policy = policy
        self.inconsistentObjectHandler = inconsistentObjectHandler
        notificationCenter.addObserver(self, selector: #selector(eventDidHappen), name: notification, object: object)
    }

    @objc
    private func eventDidHappen(_ sender: Notification) {
        guard let object = sender.userInfo?[NotificationEmitter.notificationObjectKey] as? T else {
            inconsistentObjectHandler.handle(notification: sender, withPolicy: policy, expectedType: T.self)
            return
        }

        invocationCount += 1
        callback(object)
    }

}
