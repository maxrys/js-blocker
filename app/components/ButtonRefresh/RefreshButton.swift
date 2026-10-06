
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct ButtonRefresh: View {

    static let ICON = Image("symbol Icon Refresh")

    @Environment(\.colorScheme) private var colorScheme
    @State private var isAnimated = false
    @State private var timer: Timer.Custom?

    private let speed: Double
    private let size: CGFloat
    private let onClick: () -> Void

    init(
        speed: Double = 500,
        size: CGFloat = 20,
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
            let shape = Circle()
            TimelineCustom(isActive: self.$isAnimated, interval: 1.0 / 24) {
                Self.ICON
                    .resizable()
                    .frame(width: self.size, height: self.size)
                    .foregroundPolyfill(
                        self.colorScheme == .dark ?
                            Color.white.opacity(0.2) :
                            Color.black.opacity(0.1)
                    )
                    .clipShape   (shape)
                    .contentShape(shape)
                    .focusEffect (shape)
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



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct ButtonRefresh_Previews: PreviewProvider {
    static public var previews: some View {
        Previewer(padding: 20) {
            ButtonRefresh(
                onClick: {
                }
            )
        }
    }
}
