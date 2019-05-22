# SimpleNotification

[![CI Status](https://img.shields.io/travis/tralf/SimpleNotification.svg?style=flat)](https://travis-ci.org/tralf/SimpleNotification)

**SimpleNotification** is a lightweight wrapper, that helps you to deal with observer pattern easier, than using good old buddy NotificationCenter.

## Features

- Deals with closures, not selectors
- Uses powerful typed observer blocks with user data object type defined at compilation time
- Supports both custom and system notifications

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Simple example of observing a notification, which is expected to send `Data` object:

```swift
// Registering for a notification
let dumbDateObserver: NotificationObserver<Date> = NotificationObserver(event: "Example event") { item in
    // item variable is guaranteed to be type of Date
}

// Sending a notification
NotificationEmitter.fire(event: "Example event", associatedObject: Date())
```

If it doesn't matter what type of object is send as user data with a notification or it sends nothing:
```swift
// Registering for a notification
let dumbNilObserver: NotificationObserver<Any> = NotificationObserver(event: "Another event") { _ in
    // Your code here
}

// Sending a notification
NotificationEmitter.fire(event: "Another event")
```

**A reasonable question:** "What happens if I expect one type of object, but the other is sent?"
The answer: it depends on your needs. When registering for an event, you may pass an optional argument `policy`. There are 3 options: to raise a fatal error, to raise an assert or just skip. By default it uses `.assert` value, but feel free to use any.

```swift
let dateObserver = NotificationObserver<Date>(event: "Example event", policy: fatalError("Wow, so unexpected!")) { item in
    // Your code here
}

// Causes fatal error
NotificationEmitter.fire(event: "Example event", associatedObject: "I'm a string!")
```

However, if default behaviour in case of unexpected associated type isn't that you need, you can handle it yourself by passing a `inconsistentObjectHandler` parameter.

## Installation

SimpleNotification is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SimpleNotification'
```

## Author

Viktor Kalinchuk, viktor.kalinchuk@gmail.com

## License

SimpleNotification is available under the MIT license. See the LICENSE file for more info.
