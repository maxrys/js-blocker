
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

private struct SizeKey: PreferenceKey {
    static var defaultValue = CGSize(width: 0, height: 0)
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct GeometryReaderPolyfill<Content: View>: View {

    @State private var size = CGSize(width: 0, height: 0)

    private let content: (CGSize) -> Content
    private let isIgnoreHeight: Bool
    private let isIgnoreWidth: Bool

    init(
        isIgnoreHeight: Bool = false,
        isIgnoreWidth: Bool = false,
        @ViewBuilder content: @escaping (CGSize) -> Content
    ) {
        self.isIgnoreHeight = isIgnoreHeight
        self.isIgnoreWidth = isIgnoreWidth
        self.content = content
    }

    public var body: some View {
        ZStack {
            Group {
                if      (self.isIgnoreWidth == true && self.isIgnoreHeight == true) { Color.clear.frame(width: 0, height: 0) }
                else if (self.isIgnoreWidth != true && self.isIgnoreHeight == true) { Color.clear.frame(          height: 0) }
                else if (self.isIgnoreWidth == true && self.isIgnoreHeight != true) { Color.clear.frame(width: 0) }
            }.background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: SizeKey.self, value: geometry.size)
                }
            )
            .onPreferenceChange(SizeKey.self) { value in
                self.size = value
            }
            self.content(self.size)
        }
    }

}
