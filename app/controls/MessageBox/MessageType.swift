
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

enum MessageType {

    case info
    case ok
    case warning
    case error

    var colorTitleBackground: Color {
        switch self {
            case .info   : Color.messageBox.infoTitleBackground
            case .ok     : Color.messageBox.okTitleBackground
            case .warning: Color.messageBox.warningTitleBackground
            case .error  : Color.messageBox.errorTitleBackground
        }
    }

    var colorDescriptionBackground: Color {
        switch self {
            case .info   : Color.messageBox.infoDescriptionBackground
            case .ok     : Color.messageBox.okDescriptionBackground
            case .warning: Color.messageBox.warningDescriptionBackground
            case .error  : Color.messageBox.errorDescriptionBackground
        }
    }

}
