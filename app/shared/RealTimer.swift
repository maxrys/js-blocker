
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import QuartzCore
import Combine

final class RealTimer {

    var tag: UInt

    private var timer: Cancellable?
    private var startedAt: Double = 0
    private var onTick: (Double, RealTimer) -> Void

    init(tag: UInt = 0, onTick: @escaping (Double, RealTimer) -> Void = { _,_  in }) {
        self.tag    = tag
        self.onTick = onTick
    }

    func start(tickInterval: Double = 1.0 / 24, from offset: Double = 0) {
        self.timer?.cancel()
        self.startedAt = CACurrentMediaTime() - offset
        self.timer = Timer.publish(
            every: tickInterval,
            tolerance: 0.0,
            on: RunLoop.main,
            in: RunLoop.Mode.common,
            options: nil
        ).autoconnect().sink(receiveValue: { _ in
            self.onTick(
                CACurrentMediaTime() - self.startedAt,
                self
            )
        })
    }

    func stopAndReset() {
        self.timer?.cancel()
    }

}
