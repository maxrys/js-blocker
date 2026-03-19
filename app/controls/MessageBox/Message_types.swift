
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

typealias MessageID = UInt
typealias MessageProgressPair = (message: Message, progress: Double)

enum MessageType {

    case info
    case ok
    case warning
    case error

    var colorTitleBackground: Color {
        switch self {
            case .info   : return Color.messageBox.infoTitleBackground
            case .ok     : return Color.messageBox.okTitleBackground
            case .warning: return Color.messageBox.warningTitleBackground
            case .error  : return Color.messageBox.errorTitleBackground
        }
    }

    var colorDescriptionBackground: Color {
        switch self {
            case .info   : return Color.messageBox.infoDescriptionBackground
            case .ok     : return Color.messageBox.okDescriptionBackground
            case .warning: return Color.messageBox.warningDescriptionBackground
            case .error  : return Color.messageBox.errorDescriptionBackground
        }
    }

}

enum MessageStatus {

    case persistent
    case inProgress(Double)
    case expired

}

enum MessageLifeTime {

    static let LIFE_TIME_DEFAULT: CFTimeInterval = 1.0

    case time(Double)
    case infinity

}
