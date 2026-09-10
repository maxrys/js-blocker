
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

struct ADFetchItem: Equatable {

    let name: DomainName
    let nameDecoded: DomainName
    let isWildcard: Bool
    let createdAt: Int64
    let expiresAt: Int64

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }

    init(
        name: DomainName,
        nameDecoded: DomainName,
        isWildcard: Bool,
        createdAt: Int64,
        expiresAt: Int64,
    ) {
        self.name        = name
        self.nameDecoded = nameDecoded
        self.isWildcard  = isWildcard
        self.createdAt   = createdAt
        self.expiresAt   = expiresAt
    }

    init(item: ADModel) {
        self.name        = item.name
        self.nameDecoded = item.nameDecoded
        self.isWildcard  = item.isWildcard
        self.createdAt   = item.createdAt
        self.expiresAt   = item.expiresAt
    }

    public var strictJSON: String {
        "{" +
            "\"name\":\"\(self.name.JSONEscaped())\"," +
            "\"isWildcard\":\(self.isWildcard)," +
            "\"createdAt\":\(self.createdAt)," +
            "\"expiresAt\":\(self.expiresAt)" +
        "}"
    }

}
