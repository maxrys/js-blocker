
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

let NOT_APPLICABLE   = "—"
let GROUP_NAME       = "97CZR6J379.maxrys.js-blocker"
let EXTENSION_NAME   = "maxrys.js-blocker.extension"
let ZERO_WIDTH_SPACE = "\u{200B}"

let DEMO_RULE__EXACT_TOPDOMAIN = "example.com"
let DEMO_RULES__WILDCARD_TOPDOMAIN = [
    "*.example.com"
]

let DEMO_RULE__EXACT_SUBDOMAIN = "sub3.sub2.sub1.example.com"
let DEMO_RULES__WILDCARD_SUBDOMAIN = [
    "*.sub3.sub2.sub1.example.com",
         "*.sub2.sub1.example.com",
              "*.sub1.example.com",
                   "*.example.com"
]

let DEMO_ITEM__EXACT__EXPIRE_NO_LIMIT = ADFetchItem(
    name: "example.com",
    nameDecoded: "example.com",
    isWildcard: false,
    createdAt: Date.now.int64,
    expiresAt: 0
)

let DEMO_ITEM__WILDCARD__EXPIRE_NO_LIMIT = ADFetchItem(
    name: "example.com",
    nameDecoded: "example.com",
    isWildcard: true,
    createdAt: Date.now.int64,
    expiresAt: 0
)

let DEMO_ITEM__EXACT__EXPIRE_VALID = ADFetchItem(
    name: "example.com",
    nameDecoded: "example.com",
    isWildcard: false,
    createdAt: Date.now.int64,
    expiresAt: Date.now.int64 + 1_000_000_000
)

let DEMO_ITEM__EXACT__EXPIRE_EXPIRED = ADFetchItem(
    name: "example.com",
    nameDecoded: "example.com",
    isWildcard: false,
    createdAt: Date.now.int64,
    expiresAt: Date.now.int64
)
