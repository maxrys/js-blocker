
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

let MATCH_TYPE_STRING_NO_ONE = "noOne"
let MATCH_TYPE_STRING_EXACT = "exact"
let MATCH_TYPE_STRING_WILDCARD = "wildcard"

enum MatchType {

    case exact   (item: ADFetchItem)
    case wildcard(item: ADFetchItem)
    case noOne

    public var isExact    : Bool { if case .exact    = self { true } else { false } }
    public var isWildcard : Bool { if case .wildcard = self { true } else { false } }
    public var isNoOne    : Bool { if case .noOne    = self { true } else { false } }

    public var isSome: Bool {
        self.isExact ||
        self.isWildcard
    }

    public var item: ADFetchItem? {
        switch self {
            case .exact   (let item): return item
            case .wildcard(let item): return item
            case .noOne             : return nil
        }
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

    public var strictJSON: String {
        switch self {
            case .exact   (let item): return "{\"match\":\"\(MATCH_TYPE_STRING_EXACT)\","    + "\"item\":\(item.strictJSON)}"
            case .wildcard(let item): return "{\"match\":\"\(MATCH_TYPE_STRING_WILDCARD)\"," + "\"item\":\(item.strictJSON)}"
            case .noOne             : return "{\"match\":\"\(MATCH_TYPE_STRING_NO_ONE)\"}"
        }
    }

}
