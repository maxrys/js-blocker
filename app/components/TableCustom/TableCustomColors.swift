
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

extension Color {

    enum TableCustomColorsSet {

        static let headBackground        = Color("color TableCustom Head Background")
        static let bodyBackground        = Color("color TableCustom Body Background")
        static let bodyRowOddBackground  = Color("color TableCustom Body Row Odd Background")
        static let bodyRowEvenBackground = Color("color TableCustom Body Row Even Background")

        static func rowTextColor(_ isSelected: Bool, _ appIsFocused: Bool) -> Color {
            if (isSelected == true && appIsFocused == true) { return .white }
            if (isSelected != true && appIsFocused == true) { return .label }
            if (isSelected == true && appIsFocused != true) { return .label }
            if (isSelected != true && appIsFocused != true) { return .label }
            return .clear
        }

        static func rowBackgroundColor(_ isSelected: Bool, _ isEven: Bool, _ appIsFocused: Bool) -> Color {
            if (isSelected != true && isEven != true                        ) { return .tableCustom.bodyRowOddBackground }
            if (isSelected != true && isEven == true                        ) { return .tableCustom.bodyRowEvenBackground }
            if (isSelected == true && isEven != true && appIsFocused == true) { return .selectedContentBackground.opacity(0.9) }
            if (isSelected == true && isEven == true && appIsFocused == true) { return .selectedContentBackground }
            if (isSelected == true && isEven != true && appIsFocused != true) { return .selectedContentUnactiveBackground.opacity(0.9) }
            if (isSelected == true && isEven == true && appIsFocused != true) { return .selectedContentUnactiveBackground }
            return .clear
        }

    }

    static let tableCustom = TableCustomColorsSet.self

}
