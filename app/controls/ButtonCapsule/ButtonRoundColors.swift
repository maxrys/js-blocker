
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

extension Color {

    enum ButtonCapsuleStyle {

        case violet
        case blue

        var colorTop: Color {
            switch self {
                case .violet: return Color("color ButtonCapsule Violet Top")
                case .blue  : return Color("color ButtonCapsule Blue Top")
            }
        }

        var colorBottom: Color {
            switch self {
                case .violet: return Color("color ButtonCapsule Violet Bottom")
                case .blue  : return Color("color ButtonCapsule Blue Bottom")
            }
        }

        var colorText: Color {
            return Color("color ButtonCapsule Text")
        }

    }

}
