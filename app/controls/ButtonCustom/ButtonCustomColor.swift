
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

extension Color {

    struct ButtonCustomColorSet {

        enum Style {

            case accent
            case danger
            case custom (
                text      : Color?,
                background: Color?
            )

            public var text: Color {
                switch self {
                    case .accent: Color.white
                    case .danger: Color.white
                    case .custom(let textValue, _):
                        if let textValue { textValue }
                        else { Color("color ButtonCustom Text") }
                }
            }

            public var background: Color {
                switch self {
                    case .accent: Color.accentColor
                    case .danger: Color("color ButtonCustom Background Danger")
                    case .custom(_, let backgroundValue):
                        if let backgroundValue { backgroundValue }
                        else { Color("color ButtonCustom Background") }
                }
            }
        }

    }

}
