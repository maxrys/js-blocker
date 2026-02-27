
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

private struct SizeKey: @MainActor PreferenceKey {
    @MainActor static var defaultValue = CGSize(width: 0, height: 0)
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
            let colorView: AnyView = {
                if      (self.isIgnoreWidth == true && self.isIgnoreHeight == true) { return AnyView(Color.clear.frame(width: 0, height: 0)) }
                else if (self.isIgnoreWidth != true && self.isIgnoreHeight == true) { return AnyView(Color.clear.frame(          height: 0)) }
                else if (self.isIgnoreWidth == true && self.isIgnoreHeight != true) { return AnyView(Color.clear.frame(width: 0)) }
                return AnyView(Color.clear)
            }()
            colorView.background(
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
