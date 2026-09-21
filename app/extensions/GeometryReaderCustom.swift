
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

struct GeometryReaderCustom<Content: View>: View {

    @State private var size = CGSize(width: 0, height: 0)

    private let isIgnoreWidth: Bool
    private let isIgnoreHeight: Bool
    private let alignment: Alignment
    private let onChange: (CGSize) -> Void
    private let content: (CGSize) -> Content

    init(
        isIgnoreWidth: Bool = false,
        isIgnoreHeight: Bool = false,
        alignment: Alignment = .center,
        onChange: @escaping (CGSize) -> Void = { _ in },
        @ViewBuilder content: @escaping (CGSize) -> Content,
    ) {
        self.isIgnoreWidth = isIgnoreWidth
        self.isIgnoreHeight = isIgnoreHeight
        self.alignment = alignment
        self.onChange = onChange
        self.content = content
    }

    public var body: some View {
        ZStack(alignment: self.alignment) {
            Group {
                if      (self.isIgnoreWidth == true && self.isIgnoreHeight == true) { Color.clear.frame(width: 0, height: 0) }
                else if (self.isIgnoreWidth != true && self.isIgnoreHeight == true) { Color.clear.frame(          height: 0) }
                else if (self.isIgnoreWidth == true && self.isIgnoreHeight != true) { Color.clear.frame(width: 0) }
                else if (self.isIgnoreWidth != true && self.isIgnoreHeight != true) { Color.clear }
            }.background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: SizeKey.self, value: geometry.size)
                }
            )
            .onPreferenceChange(SizeKey.self) { size in
                self.size = size
                self.onChange(size)
            }
            self.content(self.size)
        }
    }

}
