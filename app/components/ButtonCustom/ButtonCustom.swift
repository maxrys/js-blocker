
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct ButtonCustom: View {

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    private let text: String?
    private let icon: Image?
    private let colorStyle: Color.ButtonCustomStyle
    private let fixedColorScheme: ColorScheme?
    private let font: Font
    private let padding: EdgeInsets
    private let flexibility: Flexibility
    private let isTextTrimming: Bool
    private let isFlat: Bool
    private let onClick: () -> Void

    init(
        _ text: String? = "button",
        _ icon: Image? = nil,
        colorStyle: Color.ButtonCustomStyle = .accent,
        fixedColorScheme: ColorScheme? = nil,
        font: Font = .system(size: 12.5, weight: .regular),
        padding: EdgeInsets = .init(top: 6, leading: 12, bottom: 6, trailing: 12),
        flexibility: Flexibility = .none,
        isTextTrimming: Bool = true,
        isFlat: Bool = false,
        onClick: @escaping () -> Void = { }
    ) {
        self.text = text
        self.icon = icon
        self.colorStyle = colorStyle
        self.fixedColorScheme = fixedColorScheme
        self.font = font
        self.padding = padding
        self.flexibility = flexibility
        self.isTextTrimming = isTextTrimming
        self.isFlat = isFlat
        self.onClick = onClick
    }

    public var body: some View {
        if let fixedColorScheme = self.fixedColorScheme
             { self.MainView().environment(\.colorScheme, fixedColorScheme) }
        else { self.MainView() }
    }

    @ViewBuilder private func MainView() -> some View {
        Button { self.onClick() } label: {
            let shape = RoundedRectangle(cornerRadius: 5)
            HStack(spacing: 5) {
                self.IconView()
                self.TextView()
            }
            .flexibility(self.flexibility)
            .foregroundPolyfill(self.colorStyle.text)
            .padding(self.padding)
            .background(
                (self.isFlat ?
                    AnyView(shape.fill                (self.colorStyle.background)) :
                    AnyView(shape.fillGradientPolyfill(self.colorStyle.background))
                )
            )
            .clipShape   (shape)
            .contentShape(shape)
            .focusEffect (shape)
            .shadow(
                color: self.colorScheme == .dark ?
                    .black.opacity(1.0) :
                    .black.opacity(0.4),
                radius: self.isEnabled ? 0.7 : 0.0,
                y: 0.3
            )
        }
        .buttonStyle(.plain)
        .pointerStyleLinkPolyfill(self.isEnabled)
    }

    @ViewBuilder private func TextView() -> some View {
        if let text = self.text {
            Text(text)
                .lineLimit(1)
                .fixedSize(horizontal: !self.isTextTrimming, vertical: false)
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
    static let LONG_TEXT = "long long long long long long long long long long long long long long text"
    static public var previews: some View {
        VStack(spacing: 20) {

            VStack {
                Text("flexibility").font(.headline)
                ButtonCustom()
                ButtonCustom(flexibility: .none)
                ButtonCustom(flexibility: .size(100))
                ButtonCustom(flexibility: .infinity)
                ButtonCustom(Self.LONG_TEXT)
                ButtonCustom(Self.LONG_TEXT, isTextTrimming: false)
            }

            VStack {
                Text("icon + text").font(.headline)
                ButtonCustom("text")
                ButtonCustom(  nil , Image(systemName: "globe"))
                ButtonCustom("text", Image(systemName: "globe"))
            }

            Previewer(axis: .horizontal, spacing: 10, padding: 20) {
                ButtonCustom(colorStyle: .accent)
                ButtonCustom(colorStyle: .danger)
                ButtonCustom(colorStyle: .common)
                ButtonCustom(colorStyle: .common).disabled(true)
                ButtonCustom(colorStyle: .custom(text: .white, background: .orange))
            }.background(
                Rectangle()
                    .fill(Color.NS[.windowBackgroundColor])
                    .shadow(radius: 5)
            )

        }
        .frame(width: 210)
        .padding(20)
    }
}
