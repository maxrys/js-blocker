
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct RadioButtonSimple: View {

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    private let isSelected: Bool
    private let radioShape = Circle()
    private let radioSize: CGFloat
    private let radioAlignment: VerticalAlignment
    private let indicatoorSize: CGFloat
    private let lebel: any View
    private let onSelect: () -> Void

    init(
        isSelected: Bool,
        radioSize: CGFloat = 20,
        radioAlignment: VerticalAlignment = .center,
        indicatoorSize: CGFloat = 14,
        onSelect: @escaping () -> Void,
        @ViewBuilder lebel: () -> any View
    ) {
        self.isSelected = isSelected
        self.radioSize = radioSize
        self.radioAlignment = radioAlignment
        self.indicatoorSize = indicatoorSize
        self.onSelect = onSelect
        self.lebel = lebel()
    }

    var body: some View {
        HStack(alignment: self.radioAlignment, spacing: 10) {
            Button { self.onSelect() } label: {
                self.RadioView()
                    .clipShape   (self.radioShape)
                    .contentShape(self.radioShape)
                    .focusEffect (self.radioShape)
            }
            .buttonStyle(.plain)
            .disabled(!self.isEnabled)
            .pointerStyleLinkPolyfill(self.isEnabled)

            self.LebelView()
                .contentShape(Rectangle())
                .onTapGesture {
                    self.onSelect()
                }
        }.pointerStyleLinkPolyfill(self.isEnabled)
    }

    @ViewBuilder private func RadioView() -> some View {
        self.radioShape
            .fill(
                self.colorScheme == .dark ?
                    Color.black :
                    Color.white
            )
            .frame(
                width : self.radioSize,
                height: self.radioSize
            )
            .overlayPolyfill {
                self.RadioBorderView()
            }
            .overlayPolyfill {
                if (self.isSelected) {
                    self.RadioIndicatorView()
                }
            }
    }

    @ViewBuilder private func RadioBorderView() -> some View {
        self.radioShape
            .stroke(
                self.colorScheme == .dark ?
                    Color.white.opacity(0.3) :
                    Color.black.opacity(0.3),
                lineWidth: 2
            )
            .frame(
                width : self.radioSize,
                height: self.radioSize
            )
    }

    @ViewBuilder private func RadioIndicatorView() -> some View {
        self.radioShape
            .fill(Color.accentColor)
            .frame(
                width : self.indicatoorSize,
                height: self.indicatoorSize
            )
    }

    @ViewBuilder private func LebelView() -> some View {
        AnyView(self.lebel)
            .opacity(self.isEnabled ? 1.0 : 0.3)
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
