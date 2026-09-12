
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct TimelineCustom<Content: View>: View {

    @ObservedObject private var frameNumber = ValueState<UInt>(0)
    @Binding private var isActive: Bool

    private var timer: Timer.Custom!
    private let interval: TimeInterval
    private let content: () -> Content

    init(
        isActive: Binding<Bool> = .constant(true),
        interval: TimeInterval,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isActive = isActive
        self.interval = interval
        self.content = content
        self.timer = Timer.Custom(
            repeats: .infinity,
            delay: self.interval,
            onTick: self.onTick
        )
    }

    private func onTick(timer: Timer.Custom) {
        if (self.isActive) {
            self.frameNumber.value += 1
        }
    }

    public var body: some View {
        self.content()
    }

}
