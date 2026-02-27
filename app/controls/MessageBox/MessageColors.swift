
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

extension Color {

    struct MessageBoxCustomColorSet {
        public let text                         = Color("color MessageBox Text")
        public let infoTitleBackground          = Color("color MessageBox Info Title Background")
        public let infoDescriptionBackground    = Color("color MessageBox Info Description Background")
        public let okTitleBackground            = Color("color MessageBox Ok Title Background")
        public let okDescriptionBackground      = Color("color MessageBox Ok Description Background")
        public let warningTitleBackground       = Color("color MessageBox Warning Title Background")
        public let warningDescriptionBackground = Color("color MessageBox Warning Description Background")
        public let errorTitleBackground         = Color("color MessageBox Error Title Background")
        public let errorDescriptionBackground   = Color("color MessageBox Error Description Background")
    }

    static let messageBox = MessageBoxCustomColorSet()

}
