
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import os
import Foundation

extension Logger {

    static func customLog(_ message: String) {
        #if DEBUG
            NSLog(message)
        #endif
    }

}
