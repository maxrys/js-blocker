
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

extension Color {

    enum InstallGuideColorSet {
        static let statusTitle                        = Color("color Install Guide Status Title")
        static let statusSuccessTitleBackground       = Color("color Install Guide Status Success Title Background")
        static let statusSuccessDescriptionBackground = Color("color Install Guide Status Success Description Background")
        static let statusSuccessButtonBackground      = Color("color Install Guide Status Success Button Background")
        static let statusFailureTitleBackground       = Color("color Install Guide Status Failure Title Background")
        static let statusFailureDescriptionBackground = Color("color Install Guide Status Failure Description Background")
        static let statusFailureButtonBackground      = Color("color Install Guide Status Failure Button Background")
    }

    static let installGuide = InstallGuideColorSet.self

}
