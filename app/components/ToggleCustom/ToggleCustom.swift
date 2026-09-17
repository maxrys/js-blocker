
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct ToggleCustom: View {

    @Binding private var isOn: Bool

    private let text: String?
    private let isFlexible: Bool
    private let size: CGSize
    private let innerPadding: CGFloat
    private let font: Font

    init(
        text: String? = nil,
        isOn: Binding<Bool>,
        isFlexible: Bool = false,
        size: CGSize = CGSize(width: 40, height: 16),
        innerPadding: CGFloat = 3,
        font: Font = .headline
    ) {
        self.text = text
        self._isOn = isOn
        self.isFlexible = isFlexible
        self.size = size
        self.innerPadding = innerPadding
        self.font = font
    }

    public var body: some View {
        if let text = self.text {
            if (self.isFlexible) {
                HStack {
                    self.TextView(text); Spacer()
                    self.SwitcherView()
                }.frame(maxWidth: .infinity)
            } else {
                HStack {
                    self.TextView(text)
                    self.SwitcherView()
                }
            }
        } else {
            self.SwitcherView()
        }
    }

    @ViewBuilder private func TextView(_ text: String) -> some View {
        Text(text)
            .font(self.font)
    }

    @ViewBuilder private func SwitcherView() -> some View {
        ToggleCustom_Switcher(
            isOn: self.$isOn,
            size: self.size,
            innerPadding: self.innerPadding
        )
    }

}

fileprivate struct ToggleCustom_Switcher: View {

    @Environment(\.colorScheme) private var colorScheme
    @Binding fileprivate var isOn: Bool

    private let size: CGSize
    private let innerPadding: CGFloat

    init(
        isOn: Binding<Bool>,
        size: CGSize = CGSize(width: 40, height: 16),
        innerPadding: CGFloat = 3
    ) {
        self._isOn = isOn
        self.size = size
        self.innerPadding = innerPadding
    }

    public var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.1)) {
                self.isOn.toggle()
            }
        } label: {
            Capsule()
                .fill(self.isOn ? .green : .black.opacity(self.colorScheme == .dark ? 0.7 : 0.3))
                .frame(width: self.size.width, height: self.size.height)
                .overlayPolyfill(alignment: self.isOn ? .trailing : .leading) {
                    Capsule()
                        .fill(.white)
                        .frame(
                            width: (self.size.height * 1.5) - (self.innerPadding * 2),
                            height: self.size.height        - (self.innerPadding * 2))
                        .padding(self.innerPadding)
                        .shadow(
                            color: .black.opacity(0.5),
                            radius: 2.0
                        )
                }.focusEffect(Capsule())
        }
        .buttonStyle(.plain)
        .pointerStyleLinkPolyfill()
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct ToggleCustom_Previews: PreviewProvider {
    struct ViewWithState: View {
        @State private var isOn: Bool = false
        public var body: some View {
            Previewer(padding: 20) {
                VStack(alignment: .trailing) {
                    ToggleCustom(text: "Test", isOn: self.$isOn, isFlexible: true)
                    ToggleCustom(text: "Test", isOn: self.$isOn, isFlexible: false)
                    ToggleCustom(isOn: self.$isOn).disabled(true)
                }.frame(width: 200)
            }
        }
    }
    static public var previews: some View {
        ViewWithState()
    }
}
