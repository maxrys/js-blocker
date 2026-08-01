
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import Foundation

extension TimeInterval {

    enum ScaleSize: String {

        case second
        case minute
        case hour
        case day
        case week

        init(interval: TimeInterval) {
            if      (interval / TimeInterval.PERIOD_1_WEEK   >= 1) { self = .week }
            else if (interval / TimeInterval.PERIOD_1_DAY    >= 1) { self = .day }
            else if (interval / TimeInterval.PERIOD_1_HOUR   >= 1) { self = .hour }
            else if (interval / TimeInterval.PERIOD_1_MINUTE >= 1) { self = .minute }
            else                                                   { self = .second }
        }

    }

    static let PERIOD_1_SECOND : Self = 1
    static let PERIOD_1_MINUTE : Self = Self.PERIOD_1_SECOND * 60
    static let PERIOD_5_MINUTES: Self = Self.PERIOD_1_MINUTE * 5
    static let PERIOD_1_HOUR   : Self = Self.PERIOD_1_MINUTE * 60
    static let PERIOD_1_DAY    : Self = Self.PERIOD_1_HOUR * 24
    static let PERIOD_1_WEEK   : Self = Self.PERIOD_1_DAY * 7

    struct PeriodsCountResult: Equatable {
        var weeks  : Int64 = 0
        var days   : Int64 = 0
        var hours  : Int64 = 0
        var minutes: Int64 = 0
        var seconds: Int64 = 0
    }

    static func wholeParts(interval: TimeInterval) -> PeriodsCountResult? {
        guard interval >= 0 else { return nil }
        let wholeWeeks   = (interval.int64                                                                                                                                                                                                          ) / TimeInterval.PERIOD_1_WEEK.int64
        let wholeDays    = (interval.int64 - (wholeWeeks * TimeInterval.PERIOD_1_WEEK.int64)                                                                                                                                                        ) / TimeInterval.PERIOD_1_DAY.int64
        let wholeHours   = (interval.int64 - (wholeWeeks * TimeInterval.PERIOD_1_WEEK.int64) - (wholeDays * TimeInterval.PERIOD_1_DAY.int64)                                                                                                        ) / TimeInterval.PERIOD_1_HOUR.int64
        let wholeMinutes = (interval.int64 - (wholeWeeks * TimeInterval.PERIOD_1_WEEK.int64) - (wholeDays * TimeInterval.PERIOD_1_DAY.int64) - (wholeHours * TimeInterval.PERIOD_1_HOUR.int64)                                                      ) / TimeInterval.PERIOD_1_MINUTE.int64
        let wholeSeconds = (interval.int64 - (wholeWeeks * TimeInterval.PERIOD_1_WEEK.int64) - (wholeDays * TimeInterval.PERIOD_1_DAY.int64) - (wholeHours * TimeInterval.PERIOD_1_HOUR.int64) - (wholeMinutes * TimeInterval.PERIOD_1_MINUTE.int64))
        return PeriodsCountResult(
            weeks  : wholeWeeks,
            days   : wholeDays,
            hours  : wholeHours,
            minutes: wholeMinutes,
            seconds: wholeSeconds,
        )
    }

    public var int64: Int64 {
        Int64(self)
    }

}
