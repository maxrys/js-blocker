
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

extension Color {

    struct InstallPopupColorSet {
        public let background                         = Color("color Install Popup Background")
        public let statusSuccessTitleBackground       = Color("color Install Popup Status Success Title Background")
        public let statusSuccessDescriptionBackground = Color("color Install Popup Status Success Description Background")
        public let statusSuccessButtonBackground      = Color("color Install Popup Status Success Button Background")
        public let statusFailureTitleBackground       = Color("color Install Popup Status Failure Title Background")
        public let statusFailureDescriptionBackground = Color("color Install Popup Status Failure Description Background")
        public let statusFailureButtonBackground      = Color("color Install Popup Status Failure Button Background")
    }

    static let installPopup = InstallPopupColorSet()

}
