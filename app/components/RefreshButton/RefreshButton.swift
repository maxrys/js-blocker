
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct RefreshButton: View {

    static let ICON_REFRESH = Image("symbol Icon Refresh")

    @State private var isAnimated = false
    @State private var timer: Timer.Custom?

    private let speed: Double
    private let size: CGFloat
    private let onClick: () -> Void

    init(
        speed: Double = 500,
        size: CGFloat = 30,
        onClick: @escaping () -> Void
    ) {
        self.speed = speed
        self.size = size
        self.onClick = onClick
    }

    public var body: some View {
        Button {
            self.isAnimated = true
            self.timer = Timer.Custom(
                repeats: .count(1),
                delay: 1.0,
                onExpire: { _ in
                    self.isAnimated = false
                    self.timer = nil
                }
            )
            Task {
                self.onClick()
            }
        } label: {
            TimelineCustom(isActive: self.$isAnimated, interval: 1.0 / 24) {
                Circle()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: self.size, height: self.size)
                    .overlayPolyfill {
                        Self.ICON_REFRESH
                            .font(.system(size: 18))
                    }
                    .clipShape   (Capsule())
                    .contentShape(Capsule())
                    .focusEffect (Capsule())
                    .rotationEffect(
                        .degrees(Date.spin(max: UInt(360), speed: self.speed))
                    )
            }
        }
        .buttonStyle(.plain)
        .pointerStyleLinkPolyfill()
        .disabled(self.isAnimated)
    }

}
