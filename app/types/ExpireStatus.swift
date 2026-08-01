
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

enum ExpireStatus: Equatable {

    case notSetted
    case noLimit
    case valid(timeLeft: TimeInterval, progress: Double)
    case expired

    public var isSome: Bool {
        switch self {
            case .notSetted: false
            case .noLimit  : true
            case .valid    : true
            case .expired  : true
        }
    }

}
