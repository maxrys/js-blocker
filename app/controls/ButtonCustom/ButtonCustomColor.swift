
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

extension Color {

    enum ButtonCustomStyle {

        case accent
        case danger
        case custom (
            text      : Color?,
            background: Color?
        )

        public var text: Color {
            switch self {
                case .accent: return Color.white
                case .danger: return Color.white
                case .custom(let textValue, _):
                    if let textValue = textValue { return textValue }
                    else { return Color("color ButtonCustom Text") }
            }
        }

        public var background: Color {
            switch self {
                case .accent: return Color.accentColor
                case .danger: return Color("color ButtonCustom Background Danger")
                case .custom(_, let backgroundValue):
                    if let backgroundValue = backgroundValue { return backgroundValue }
                    else { return Color("color ButtonCustom Background") }
            }
        }
    }

}
