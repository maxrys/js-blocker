
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

extension Date {

    func formatCustom(_ format: String = "yyyy-MM-dd HH:mm:ss", timeZoneOffset: Int = 0, locale: String = "en_US_POSIX") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: locale)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timeZoneOffset)
        return dateFormatter.string(from: self)
    }

}
