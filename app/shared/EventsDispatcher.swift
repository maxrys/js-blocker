
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation
import Combine

class EventsDispatcher {

    static let shared = EventsDispatcher()

    private var cancellableBag = Set<AnyCancellable>()
    private var publisherBag: [
        String: NotificationCenter.Publisher
    ] = [:]
    private var handlers: [
        String: [(Any) -> Void]
    ] = [:]

    func publisher( _ type: String) -> NotificationCenter.Publisher? {
        if (self.publisherBag[type] == nil) {
            self.publisherBag[type] = NotificationCenter.default.publisher(for: Notification.Name(type))
            self.publisherBag[type]!.sink(receiveValue: { notification in
                for handler in self.handlers[type] ?? [] {
                    handler(notification.object!)
                }
            }).store(in: &self.cancellableBag)
        }
        return self.publisherBag[type]!
    }

    func send(_ type: String, object: Any) {
        NotificationCenter.default.post(
            name: Notification.Name(type),
            object: object
        )
    }

    func on(_ type: String, handler: @escaping (Any) -> Void) {
        if (self.handlers[type] == nil) { self.handlers[type] = [] }
        self.handlers[type]!.append(handler)
    }

}
