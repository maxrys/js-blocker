
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

extension Color {

    struct TableCustomColorsSet {

        public let headBackground        = Color("color TableCustom Head Background")
        public let bodyBackground        = Color("color TableCustom Body Background")
        public let bodyRowOddBackground  = Color("color TableCustom Body Row Odd Background")
        public let bodyRowEvenBackground = Color("color TableCustom Body Row Even Background")

        public func rowTextColor(_ isSelected: Bool, _ appIsFocused: Bool) -> Color {
            if (isSelected == true && appIsFocused == true) { return .white }
            if (isSelected != true && appIsFocused == true) { return .label }
            if (isSelected == true && appIsFocused != true) { return .label }
            if (isSelected != true && appIsFocused != true) { return .label }
            return .clear
        }

        public func rowBackgroundColor(_ isSelected: Bool, _ isEven: Bool, _ appIsFocused: Bool) -> Color {
            if (isSelected != true && isEven != true                        ) { return .tableCustom.bodyRowOddBackground }
            if (isSelected != true && isEven == true                        ) { return .tableCustom.bodyRowEvenBackground }
            if (isSelected == true && isEven != true && appIsFocused == true) { return .selectedContentBackground.opacity(0.9) }
            if (isSelected == true && isEven == true && appIsFocused == true) { return .selectedContentBackground }
            if (isSelected == true && isEven != true && appIsFocused != true) { return .selectedContentUnactiveBackground.opacity(0.9) }
            if (isSelected == true && isEven == true && appIsFocused != true) { return .selectedContentUnactiveBackground }
            return .clear
        }

    }

    static let tableCustom = TableCustomColorsSet()

}
