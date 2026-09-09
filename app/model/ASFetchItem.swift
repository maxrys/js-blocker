
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

struct ASFetchItem: Equatable {

    let domain: DomainName
    let frameDomain: DomainName
    let url: String
    let createdAt: Int64


    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.domain      == rhs.domain &&
        lhs.frameDomain == rhs.frameDomain &&
        lhs.url         == rhs.url
    }

    init(
        domain: DomainName,
        frameDomain: DomainName,
        url: String,
        createdAt: Int64,
    ) {
        self.domain      = domain
        self.frameDomain = frameDomain
        self.url         = url
        self.createdAt   = createdAt
    }

    init(item: AllowedScripts) {
        self.domain      = item.domain
        self.frameDomain = item.frameDomain
        self.url         = item.url
        self.createdAt   = item.createdAt
    }

    public var strictJSON: String {
        "{" +
            "\"domain\":\"\(self.domain.JSONEscaped())\"," +
            "\"frameDomain\":\"\(self.frameDomain.JSONEscaped())\"," +
            "\"url\":\"\(self.url.JSONEscaped())\"," +
            "\"createdAt\":\(self.createdAt)" +
        "}"
    }

}
