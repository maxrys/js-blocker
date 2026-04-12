
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct FieldSearchCustom: View {

    static let TEXT_PLACEHOLDER_LOCALIZED = NSLocalizedString("Search", comment: "")

    @Environment(\.colorScheme) private var colorScheme
    @Binding private var text: String

    private let padding: EdgeInsets

    init(
        text: Binding<String>,
        padding: EdgeInsets = .init(top: 9, leading: 32, bottom: 9, trailing: 32)
    ) {
        self._text = text
        self.padding = padding
    }

    var body: some View {
        TextField(
            NSLocalizedString(Self.TEXT_PLACEHOLDER_LOCALIZED, comment: ""),
            text: self.$text
        )
        .textFieldStyle(.plain)
        .padding(self.padding)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.fieldSearch.background)
                .shadow(
                    color: .black.opacity(0.5),
                    radius: 1,
                    y: 0
                )
        )
        .focusEffect(RoundedRectangle(cornerRadius: 5))
        .overlayPolyfill(alignment: .leading) { self.IconView() }
        .overlayPolyfill(alignment: .trailing) {
            if (!self.text.isEmpty) {
                self.ButtonResetView()
                    .offset(x: -5)
            }
        }
    }

    @ViewBuilder private func IconView() -> some View {
        Image(systemName: "magnifyingglass")
            .font(.system(size: 16))
            .foregroundPolyfill(Color.fieldSearch.icon)
            .offset(x: 8)
    }

    @ViewBuilder private func ButtonResetView() -> some View {
        Button { self.text = "" } label: {
            Image(systemName: "xmark.circle")
                .font(.system(size: 16))
                .foregroundPolyfill(Color.fieldSearch.buttonReset)
                .background(
                    self.colorScheme == .dark ?
                        Color.fieldSearch.buttonResetBackgroundDark :
                        Color.fieldSearch.buttonResetBackground
                )
                .clipShape(Circle())
                .focusEffect(Circle())
        }
        .buttonStyle(.plain)
        .pointerStyleLinkPolyfill()
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct FieldSearchCustom_Previews: PreviewProvider {
    static var previews: some View {
        FieldSearchCustom(
            text: .constant("")
        )
        .padding(20)
        .frame(width: 200)
    }
}
