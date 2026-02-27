
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct ButtonRound: View {

    enum Colors {

        case violet
        case blue

        var colorTop: Color {
            switch self {
                case .violet: return Color.buttonRound.violetTop
                case .blue  : return Color.buttonRound.blueTop
            }
        }

        var colorBottom: Color {
            switch self {
                case .violet: return Color.buttonRound.violetBottom
                case .blue  : return Color.buttonRound.blueBottom
            }
        }

    }

    private let title: String
    private let color: Colors
    private let minWidth: CGFloat
    private let onClick: () -> Void

    init(
        title: String,
        color: Colors = .violet,
        minWidth: CGFloat = 150,
        onClick: @escaping () -> Void
    ) {
        self.title = title
        self.color = color
        self.minWidth = minWidth
        self.onClick = onClick
    }

    public var body: some View {
        Button {
            self.onClick()
        } label: {
            Text(self.title)
                .foregroundPolyfill(Color.buttonRound.text)
                .padding(11)
                .frame(minWidth: self.minWidth)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [self.color.colorTop, self.color.colorBottom],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
        }
        .buttonStyle(.plain)
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
                color: .violet,
                minWidth: 150,
                onClick: {
                    print("onClick: ButtonRound #1")
                }
            )

            ButtonRound(
                title: NSLocalizedString("allow", comment: ""),
                color: .violet,
                minWidth: 150,
                onClick: {
                    print("onClick: ButtonRound #2")
                }
            ).disabled(true)

            ButtonRound(
                title: NSLocalizedString("cancel permission", comment: ""),
                color: .blue,
                minWidth: 250,
                onClick: {
                    print("onClick: ButtonRound #3")
                }
            )

            ButtonRound(
                title: NSLocalizedString("cancel permission", comment: ""),
                color: .blue,
                minWidth: 250,
                onClick: {
                    print("onClick: ButtonRound #4")
                }
            ).disabled(true)

        }.padding(10)
    }
}
