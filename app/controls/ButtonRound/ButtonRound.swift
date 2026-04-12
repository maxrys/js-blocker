
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct ButtonRound: View {

    private let title: String
    private let isDisabled: Bool
    private let style: Color.ButtonRoundStyle
    private let minWidth: CGFloat
    private let onClick: () -> Void

    init(
        title: String,
        isDisabled: Bool = false,
        style: Color.ButtonRoundStyle = .violet,
        minWidth: CGFloat = 150,
        onClick: @escaping () -> Void
    ) {
        self.title = title
        self.isDisabled = isDisabled
        self.style = style
        self.minWidth = minWidth
        self.onClick = onClick
    }

    public var body: some View {
        Button {
            self.onClick()
        } label: {
            Text(self.title)
                .foregroundPolyfill(self.style.colorText)
                .padding(11)
                .frame(minWidth: self.minWidth)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [self.style.colorTop, self.style.colorBottom],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                ).focusEffect(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(self.isDisabled)
        .pointerStyleLinkPolyfill()
    }
}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct ButtonRound_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {

            ButtonRound(
                title: NSLocalizedString("allow", comment: ""),
                style: .violet,
                minWidth: 150,
                onClick: {
                    print("onClick: ButtonRound #1")
                }
            )

            ButtonRound(
                title: NSLocalizedString("allow", comment: ""),
                isDisabled: true,
                style: .violet,
                minWidth: 150,
                onClick: {
                    print("onClick: ButtonRound #2")
                }
            )

            ButtonRound(
                title: NSLocalizedString("cancel rule", comment: ""),
                style: .blue,
                minWidth: 250,
                onClick: {
                    print("onClick: ButtonRound #3")
                }
            )

            ButtonRound(
                title: NSLocalizedString("cancel rule", comment: ""),
                isDisabled: true,
                style: .blue,
                minWidth: 250,
                onClick: {
                    print("onClick: ButtonRound #4")
                }
            )

        }.padding(10)
    }
}
