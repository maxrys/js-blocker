
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

enum MatchType {

    case exact   (item: ADFetchItem)
    case wildcard(item: ADFetchItem)
    case noOne

    public var isExact   : Bool { if case .exact    = self { true } else { false } }
    public var isWildcard: Bool { if case .wildcard = self { true } else { false } }
    public var isNoOne   : Bool { if case .noOne    = self { true } else { false } }
    public var isSome    : Bool { self.isExact || self.isWildcard }

    public var item: ADFetchItem? {
        if case .exact   (let item) = self { return item }
        if case .wildcard(let item) = self { return item }
        return nil
    }

    public var expireStatus: ExpireStatus {
        if let item = self.item {
            let now = Date.now
            if (item.expiresAt == 0                               ) { return .noLimit }
            if (item.expiresAt != 0 && item.expiresAt <= now.int64) { return .expired }
            if (item.expiresAt != 0 && item.expiresAt  > now.int64) {
                return .valid(
                    timeLeft: TimeInterval(item.expiresAt - now.int64),
                    progress: now.int64.progress(
                        min: item.createdAt,
                        max: item.expiresAt
                    )
                )
            }
        }
        return .notSetted
    }

    public var isAllowedJS: Bool {
        return self.isExact ||
               self.isWildcard
    }

    public var toStrictJS: String {
        switch self {
            case .exact   (let item): return "{\"match\":\"exact\",\"item\":\(item.toStrictJS())}"
            case .wildcard(let item): return "{\"match\":\"wildcard\",\"item\":\(item.toStrictJS())}"
            case .noOne             : return "{\"match\":\"noOne\"}"
        }
    }

}
