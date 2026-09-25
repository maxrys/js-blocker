
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct RadioButtonSimple: View {

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    private let shape = Circle()
    private let indicatorScale: Double = 0.7

    private let isSelected: Bool
    private let onSelect: () -> Void
    private let lebel: any View
    private let size: CGFloat
    private let indicatorAlignment: VerticalAlignment

    init(
        isSelected: Bool,
        onSelect: @escaping () -> Void,
        size: CGFloat = 20,
        indicatorAlignment: VerticalAlignment = .center,
        @ViewBuilder lebel: () -> any View
    ) {
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.size = size
        self.indicatorAlignment = indicatorAlignment
        self.lebel = lebel()
    }

    var body: some View {
        HStack(alignment: self.indicatorAlignment, spacing: 10) {
            Button { self.onSelect() } label: {
                self.shape
                    .fill(
                        self.colorScheme == .dark ?
                            Color.black :
                            Color.white
                    )
                    .frame(
                        width : self.size,
                        height: self.size
                    )
                    .overlayPolyfill {
                        self.BorderView()
                    }
                    .overlayPolyfill {
                        if (self.isSelected) {
                            self.IndicatorView()
                        }
                    }
                    .clipShape   (self.shape)
                    .contentShape(self.shape)
                    .focusEffect (self.shape)
            }
            .buttonStyle(.plain)
            .disabled(!self.isEnabled)
            .pointerStyleLinkPolyfill(self.isEnabled)

            AnyView(self.lebel)
                .opacity(self.isEnabled ? 1.0 : 0.3)
        }
    }

    @ViewBuilder private func BorderView() -> some View {
        self.shape
            .stroke(
                self.colorScheme == .dark ?
                    Color.white.opacity(0.3) :
                    Color.black.opacity(0.3),
                lineWidth: 2
            )
            .frame(
                width : self.size,
                height: self.size
            )
    }

    @ViewBuilder private func IndicatorView() -> some View {
        self.shape
            .fill(Color.accentColor)
            .frame(
                width : self.size * self.indicatorScale,
                height: self.size * self.indicatorScale
            )
    }

}


/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct RadioButtonSimple_Previews: PreviewProvider {
    struct ViewWithState: View {
        static let DEMO_ID_0: UInt = 0
        static let DEMO_ID_1: UInt = 1
        static let DEMO_ID_2: UInt = 2
        @State private var selected: UInt = 0
        public var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                RadioButtonSimple(isSelected: self.selected == Self.DEMO_ID_0, onSelect: { self.selected = Self.DEMO_ID_0 }) {
                    Text("Item 1")
                }
                RadioButtonSimple(isSelected: self.selected == Self.DEMO_ID_1, onSelect: { self.selected = Self.DEMO_ID_1 }) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Item 2")
                        Text("some description 1").font(.system(size: 10))
                        Text("some description 2").font(.system(size: 10))
                        Text("some description 3").font(.system(size: 10))
                    }
                }
                RadioButtonSimple(isSelected: self.selected == Self.DEMO_ID_2, onSelect: { self.selected = Self.DEMO_ID_2 }) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Item 3")
                        Text("disabled").font(.system(size: 10))
                    }
                }.disabled(true)
            }.padding(20)
        }
    }
    static public var previews: some View {
        ViewWithState()
    }
}
