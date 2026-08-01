
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

extension Color {

    struct LifetimeColorSet {
        public let infoOpener                    = Color("color Lifetime Info Opener")
        public let openerBackground              = Color("color Lifetime Opener Background")
        public let openerActiveBackground        = Color("color Lifetime Opener Active Background")
        public var popupTitle                    = Color("color Lifetime Popup Title")
        public let popupTitleBackground          = Color("color Lifetime Popup Title Background")
        public var popupTitleBorder              = Color("color Lifetime Popup Title Border")
        public let popupValueUnlimitBackground   = Color("color Lifetime Popup Value-Unlimit Background")
        public let popupListItemBackground       = Color("color Lifetime Popup List Item Background")
        public let popupListItemActiveBackground = Color("color Lifetime Popup List Item Active Background")
    }

    static let lifetime = LifetimeColorSet()

}
