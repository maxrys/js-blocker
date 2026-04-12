
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct ButtonCustom: View {

    @Environment(\.colorScheme) private var colorScheme

    private let text: String?
    private let icon: Image?
    private let isDisabled: Bool
    private let colorStyle: Color.ButtonCustomStyle
    private let isFlat: Bool
    private let font: Font
    private let padding: EdgeInsets
    private let flexibility: Flexibility
    private let onClick: () -> Void

    init(
        _ text: String? = "button",
        _ icon: Image? = nil,
        colorStyle: Color.ButtonCustomStyle = .accent,
        font: Font = .system(size: 12.5, weight: .regular),
        padding: EdgeInsets = .init(top: 6, leading: 12, bottom: 6, trailing: 12),
        flexibility: Flexibility = .none,
        isFlat: Bool = false,
        isDisabled: Bool = false,
        onClick: @escaping () -> Void = { }
    ) {
        self.text = text
        self.icon = icon
        self.isDisabled = isDisabled
        self.colorStyle = colorStyle
        self.isFlat = isFlat
        self.font = font
        self.padding = padding
        self.flexibility = flexibility
        self.onClick = onClick
    }

    public var body: some View {
        Button { self.onClick() } label: {
            HStack(spacing: 5) {
                self.IconView()
                self.TextView()
            }
            .flexibility(self.flexibility)
            .foregroundPolyfill(self.colorStyle.text)
            .padding(self.padding)
            .background(
                (self.isFlat ?
                    AnyView(RoundedRectangle(cornerRadius: 5).fill                (self.colorStyle.background)) :
                    AnyView(RoundedRectangle(cornerRadius: 5).fillGradientPolyfill(self.colorStyle.background))
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .focusEffect(RoundedRectangle(cornerRadius: 5))
            .shadow(
                color: self.colorScheme == .dark ?
                    .black.opacity(1.0) :
                    .black.opacity(0.4),
                radius: 0.7,
                y: 0.3
            )
        }
        .buttonStyle(.plain)
        .disabled(self.isDisabled)
        .pointerStyleLinkPolyfill()
    }

    @ViewBuilder private func TextView() -> some View {
        if let text = self.text {
            Text(text)
                .lineLimit(1)
                .font(self.font)
        }
    }

    @ViewBuilder private func IconView() -> some View {
        if let icon = self.icon {
            icon.font(self.font)
        }
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct ButtonCustom_Previews: PreviewProvider {
    static public var previews: some View {
        VStack(spacing: 20) {

            VStack {
                Text("flexibility").font(.headline)
                ButtonCustom()
                ButtonCustom(flexibility: .none)
                ButtonCustom(flexibility: .size(100))
                ButtonCustom(flexibility: .infinity)
            }

            VStack {
                Text("icon + text").font(.headline)
                ButtonCustom("text")
                ButtonCustom(  nil , Image(systemName: "globe"))
                ButtonCustom("text", Image(systemName: "globe"))
            }

            HStack(spacing: 0) {
                VStack {
                    Text("light style").font(.headline)
                    ButtonCustom(colorStyle: .accent)
                    ButtonCustom(colorStyle: .danger)
                    ButtonCustom(colorStyle: .custom(text: nil, background: nil))
                    ButtonCustom(colorStyle: .custom(text: .white, background: .orange))
                }
                .padding(20)
                .environment(\.colorScheme, .light)
                .background(Color.white)

                VStack {
                    Text("dark style").font(.headline)
                    ButtonCustom(colorStyle: .accent)
                    ButtonCustom(colorStyle: .danger)
                    ButtonCustom(colorStyle: .custom(text: nil, background: nil))
                    ButtonCustom(colorStyle: .custom(text: .white, background: .orange))
                }
                .padding(20)
                .environment(\.colorScheme, .dark)
                .background(Color.NS[\.darkGray])
            }

        }
        .frame(width: 210)
        .padding(20)
    }
}
