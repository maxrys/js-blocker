
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import QuartzCore
import Combine

extension Timer {

    final class Custom {

        enum Repeats {
            case count(UInt)
            case infinity
        }

        public let tag: UInt
        public let repeats: Repeats
        public let delay: Double
        public private(set) var i: UInt = 0

        private let onTick: (Timer.Custom) -> Void
        private let onExpire: (Timer.Custom) -> Void
        private var timer: Cancellable?

        public var isStoped: Bool {
            self.timer == nil
        }

        init(
            tag: UInt = 0,
            immediately: Bool = true,
            repeats: Repeats,
            delay: Double,
            onTick  : @escaping (Timer.Custom) -> Void = { _ in },
            onExpire: @escaping (Timer.Custom) -> Void = { _ in }
        ) {
            self.tag = tag
            self.repeats = repeats
            self.delay = delay
            self.onTick = onTick
            self.onExpire = onExpire
            if (immediately) {
                self.startOrRenew()
            }
        }

        public func startOrRenew() {
            self.i = 0
            self.timer?.cancel()
            self.timer = Timer.publish(
                every: self.delay,
                tolerance: 0.0,
                on: RunLoop.main,
                in: RunLoop.Mode.common,
                options: nil
            ).autoconnect().sink(receiveValue: { _ in
                switch self.repeats {
                    case .count(let count):
                        self.onTick(self)
                        if (self.i < UInt.max) { self.i += 1 }
                        if (self.i > count - 1) {
                            self.stopAndReset()
                            self.onExpire(self)
                        }
                    case .infinity:
                        self.onTick(self)
                        if (self.i < UInt.max) { self.i += 1 }
                }
            })
        }

        public func stopAndReset() {
            self.timer?.cancel()
            self.timer = nil
        }

    }

}
