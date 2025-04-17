
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import QuartzCore
import Combine

final class RealTimer {

    private var timer: Cancellable?
    private var startedAt: Double = 0
    private var onTick: (Double) -> Void

    init(onTick: @escaping (Double) -> Void = { _ in }) {
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
        ).autoconnect().sink(receiveCompletion: { _ in }, receiveValue: { _ in
            self.onTick(
                CACurrentMediaTime() - self.startedAt
            )
        })
    }

    func stopAndReset() {
        self.timer?.cancel()
    }

}
