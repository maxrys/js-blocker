
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

extension Color {

    enum ButtonRoundStyle {

        case violet
        case blue

        var colorTop: Color {
            switch self {
                case .violet: return Color("color ButtonRound Violet Top")
                case .blue  : return Color("color ButtonRound Blue Top")
            }
        }

        var colorBottom: Color {
            switch self {
                case .violet: return Color("color ButtonRound Violet Bottom")
                case .blue  : return Color("color ButtonRound Blue Bottom")
            }
        }

        var colorText: Color {
            return Color("color ButtonRound Text")
        }

    }

}
