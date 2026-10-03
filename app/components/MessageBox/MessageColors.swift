
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

extension Color {

    enum MessageBoxCustomColorSet {
        static let text                         = Color("color MessageBox Text")
        static let infoTitleBackground          = Color("color MessageBox Info Title Background")
        static let infoDescriptionBackground    = Color("color MessageBox Info Description Background")
        static let infoProgressBackground       = Color("color MessageBox Info Progress Background")
        static let okTitleBackground            = Color("color MessageBox Ok Title Background")
        static let okDescriptionBackground      = Color("color MessageBox Ok Description Background")
        static let okProgressBackground         = Color("color MessageBox Ok Progress Background")
        static let warningTitleBackground       = Color("color MessageBox Warning Title Background")
        static let warningDescriptionBackground = Color("color MessageBox Warning Description Background")
        static let warningProgressBackground    = Color("color MessageBox Warning Progress Background")
        static let errorTitleBackground         = Color("color MessageBox Error Title Background")
        static let errorDescriptionBackground   = Color("color MessageBox Error Description Background")
        static let errorProgressBackground      = Color("color MessageBox Error Progress Background")
    }

    static let messageBox = MessageBoxCustomColorSet.self

}
