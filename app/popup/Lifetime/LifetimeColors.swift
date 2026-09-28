
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

extension Color {

    enum LifetimeColorSet {
        static let infoOpener                  = Color("color Lifetime Info Opener")
        static let openerIcon                  = Color("color Lifetime Opener Icon")
        static let openerIconActive            = Color("color Lifetime Opener Icon Active")
        static let openerBackground            = Color("color Lifetime Opener Background")
        static let openerBorder                = Color("color Lifetime Opener Border")
        static let openerBorderActive          = Color("color Lifetime Opener Border Active")
        static var popupTitle                  = Color("color Lifetime Popup Title")
        static let popupTitleBackground        = Color("color Lifetime Popup Title Background")
        static var popupTitleBorder            = Color("color Lifetime Popup Title Border")
        static let popupValueUnlimitBackground = Color("color Lifetime Popup Value-Unlimit Background")
    }

    static let lifetime = LifetimeColorSet.self

}
