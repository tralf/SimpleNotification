//
//  NotificationRepresentable.swift
//  SimpleNotification
//
//  Created by Viktor Kalinchuk on 5/15/19.
//  Copyright © 2019 Viktor Kalinchuk. All rights reserved.
//

import Foundation

public protocol NotificationRepresentable {

    var notificationName: Notification.Name { get }

}

extension String: NotificationRepresentable {

    public var notificationName: Notification.Name {
        return Notification.Name(self)
    }

}

public protocol RawStringNotificationRepresentable: NotificationRepresentable, RawRepresentable where RawValue == String {}

extension RawStringNotificationRepresentable {

    public var notificationName: Notification.Name {
        return rawValue.notificationName
    }

}
