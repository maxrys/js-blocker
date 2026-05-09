
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct ButtonCapsule: View {

    @Environment(\.isEnabled) private var isEnabled

    private let title: String
    private let style: Color.ButtonCapsuleStyle
    private let minWidth: CGFloat
    private let onClick: () -> Void

    init(
        title: String,
        style: Color.ButtonCapsuleStyle = .violet,
        minWidth: CGFloat = 150,
        onClick: @escaping () -> Void
    ) {
        self.title = title
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
                )
                .clipShape   (Capsule())
                .contentShape(Capsule())
                .focusEffect (Capsule())
        }
        .buttonStyle(.plain)
        .pointerStyleLinkPolyfill(self.isEnabled)
    }
}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct ButtonCapsule_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {

            ButtonCapsule(
                title: NSLocalizedString("allow", comment: ""),
                style: .violet,
                minWidth: 150,
                onClick: {
                    print("onClick: ButtonCapsule #1")
                }
            )

            ButtonCapsule(
                title: NSLocalizedString("allow", comment: ""),
                style: .violet,
                minWidth: 150,
                onClick: {
                    print("onClick: ButtonCapsule #2")
                }
            ).disabled(true)

            ButtonCapsule(
                title: NSLocalizedString("cancel rule", comment: ""),
                style: .blue,
                minWidth: 250,
                onClick: {
                    print("onClick: ButtonCapsule #3")
                }
            )

            ButtonCapsule(
                title: NSLocalizedString("cancel rule", comment: ""),
                style: .blue,
                minWidth: 250,
                onClick: {
                    print("onClick: ButtonCapsule #4")
                }
            ).disabled(true)

        }.padding(10)
    }
}
