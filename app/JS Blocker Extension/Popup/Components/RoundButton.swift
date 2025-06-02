
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct RoundButton: View {

    enum ColorNames: String {
        case text         = "color Button Text"
        case blueTop      = "color Button Blue Top"
        case blueBottom   = "color Button Blue Bottom"
        case violetTop    = "color Button Violet Top"
        case violetBottom = "color Button Violet Bottom"
    }

    enum Colors {

        case violet
        case blue

        var colorTop: Color {
            switch self {
                case .violet: return Color(ColorNames.violetTop.rawValue)
                case .blue  : return Color(ColorNames.blueTop.rawValue)
            }
        }

        var colorBottom: Color {
            switch self {
                case .violet: return Color(ColorNames.violetBottom.rawValue)
                case .blue  : return Color(ColorNames.blueBottom.rawValue)
            }
        }

    }

    var title: String
    var color: Colors = .violet
    var minWidth: CGFloat = 150
    var onClick: () -> Void

    var body: some View {

        Button {
            self.onClick()
        } label: {
            Text(NSLocalizedString(self.title, comment: ""))
                .color(Color(Self.ColorNames.text.rawValue))
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
        .onHoverCursor()

    }
}

struct RoundButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {

            RoundButton(
                title: "allow",
                color: .violet,
                minWidth: 150,
                onClick: {
                    print("onClick: RoundButton #1")
                }
            )

            RoundButton(
                title: "allow",
                color: .violet,
                minWidth: 150,
                onClick: {
                    print("onClick: RoundButton #2")
                }
            ).disabled(true)

            RoundButton(
                title: "cancel permission",
                color: .blue,
                minWidth: 250,
                onClick: {
                    print("onClick: RoundButton #3")
                }
            )

            RoundButton(
                title: "cancel permission",
                color: .blue,
                minWidth: 250,
                onClick: {
                    print("onClick: RoundButton #4")
                }
            ).disabled(true)

        }.padding(10)
    }
}
