//
//  ViewController.swift
//  SimpleNotification
//
//  Created by Viktor Kalinchuk on 5/14/19.
//  Copyright © 2019 Viktor Kalinchuk. All rights reserved.
//

import UIKit
import SimpleNotification

enum ExampleEvent: String, RawStringNotificationRepresentable {
    case sampleString
    case sampleDate
}

class ViewController: UIViewController {

    @IBOutlet private weak var textField: UITextField!

    private let enteringBackgroundObserver: NotificationObserver<Any>

    private let exampleStringObserver: NotificationObserver<String>

    private let exampleDateObserver: NotificationObserver<Date>

    private let exampleNeverHappenObserver: NotificationObserver<Date>

    required init?(coder aDecoder: NSCoder) {
        enteringBackgroundObserver = NotificationObserver(systemEvent: UIApplication.didEnterBackgroundNotification) { _ in
            print("Did enter background")
        }

        exampleStringObserver = NotificationObserver(event: ExampleEvent.sampleString) { item in
            print("Yep, it's string - " + item)
        }

        exampleDateObserver = NotificationObserver(event: ExampleEvent.sampleDate) { item in
            print("Yep, it's date - \(item.timeIntervalSince1970)")
        }

        exampleNeverHappenObserver = NotificationObserver(event: ExampleEvent.sampleString, policy: .skip) { item in
            print("This never happens, because the observer waits for \(Date.self) item, but listens for \(ExampleEvent.sampleString) event")
        }

        super.init(coder: aDecoder)
    }

    @IBAction
    func postCurrentDate() {
        NotificationEmitter.fire(event: ExampleEvent.sampleDate, associatedObject: Date())
    }

    @IBAction
    func postText() {
        NotificationEmitter.fire(event: ExampleEvent.sampleString, associatedObject: textField.text)
    }

}

