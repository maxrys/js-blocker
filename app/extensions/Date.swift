
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

extension Date {

    enum Format: String {
        case iso8601         = "yyyy-MM-dd HH:mm:ss"
        case iso8601Timezone = "yyyy-MM-dd HH:mm:ss Z"
        case convenientDate  = "d MMM yyyy"
        case convenientTime  = "HH:mm:ss"
    }

    static var now: TimeInterval {
        Self().timeIntervalSince1970
    }

    func formatCustom(_ format: String = "yyyy-MM-dd HH:mm:ss", timeZoneOffset: Int = 0, locale: String = "en_US_POSIX") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: locale)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timeZoneOffset)
        return dateFormatter.string(from: self)
    }

    var formatConvenient: String {
        let formatter = DateFormatter()
        formatter.dateFormat = String(
            format: NSLocalizedString("%@ 'at' %@", comment: ""),
            Self.Format.convenientDate.rawValue,
            Self.Format.convenientTime.rawValue )
        return formatter.string(from: self)
    }

    var formatISO8601: String {
        let formatter = DateFormatter()
        formatter.dateFormat = Self.Format.iso8601.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }

    var formatISO8601tz: String {
        let formatter = DateFormatter()
        formatter.dateFormat = Self.Format.iso8601Timezone.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }

    var formatISO8601tzUTC: String {
        let formatter = DateFormatter()
        formatter.dateFormat = Self.Format.iso8601Timezone.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }

}
