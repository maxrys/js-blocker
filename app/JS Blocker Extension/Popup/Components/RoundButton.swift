
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct RoundButton: View {

    static let COLORNAME_TEXT          = "color Button Text"
    static let COLORNAME_BLUE_TOP      = "color Button Blue Top"
    static let COLORNAME_BLUE_BOTTOM   = "color Button Blue Bottom"
    static let COLORNAME_VIOLET_TOP    = "color Button Violet Top"
    static let COLORNAME_VIOLET_BOTTOM = "color Button Violet Bottom"

    enum Colors {

        case violet
        case blue

        var colorTop: Color {
            switch self {
                case .violet: return Color(COLORNAME_VIOLET_TOP)
                case .blue  : return Color(COLORNAME_BLUE_TOP)
            }
        }

        var colorBottom: Color {
            switch self {
                case .violet: return Color(COLORNAME_VIOLET_BOTTOM)
                case .blue  : return Color(COLORNAME_BLUE_BOTTOM)
            }
        }
    }

    var title: String
    var color: Colors = .violet
    var isEnabled: Bool = true
    var minWidth: CGFloat = 150
    var onClick: () -> Void

    var body: some View {

        Button {
            self.onClick()
        } label: {
            Text(NSLocalizedString(self.title, comment: ""))
                .color(Color(Self.COLORNAME_TEXT))
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
        .disabled(!self.isEnabled)
        .onHover { isInView in
            if (self.isEnabled) {
                if (isInView) { NSCursor.pointingHand.push() }
                else          { NSCursor.pop() }
            }   else          { NSCursor.pop() }
        }

    }
}

struct RoundButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {

            RoundButton(
                title: "allow",
                color: .violet,
                isEnabled: true,
                minWidth: 150,
                onClick: {
                    print("onClick: RoundButton #1")
                }
            )

            RoundButton(
                title: "allow",
                color: .violet,
                isEnabled: false,
                minWidth: 150,
                onClick: {
                    print("onClick: RoundButton #2")
                }
            )

            RoundButton(
                title: "cancel permission",
                color: .blue,
                isEnabled: true,
                minWidth: 250,
                onClick: {
                    print("onClick: RoundButton #3")
                }
            )

            RoundButton(
                title: "cancel permission",
                color: .blue,
                isEnabled: false,
                minWidth: 250,
                onClick: {
                    print("onClick: RoundButton #4")
                }
            )

        }.padding(10)
    }
}
