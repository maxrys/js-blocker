
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

typealias CurrentDomainName = DomainName
typealias FrameDomainName   = DomainName
typealias Matrix2dArrOfStr  = Dictionary<String, [String]>.Matrix2D
typealias Matrix3dBool      = Dictionary<String, Bool>.Matrix3D

let NOT_APPLICABLE       = "—"
let APP_ID               = "JSBlocker"
let GROUP_NAME           = "97CZR6J379.maxrys.js-blocker"
let EXTENSION_POPUP_NAME = "maxrys.js-blocker.popup"
let EXTENSION_RULES_NAME = "maxrys.js-blocker.rules"
let ZERO_WIDTH_SPACE     = "\u{200B}"
let WITH_RULES_EXTENSION = false

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
    type: MATCH_TYPE_STRING_EXACT,
    createdAt: Date.now.int64,
    expiresAt: 0
)

let DEMO_ITEM__WILDCARD__EXPIRE_NO_LIMIT = ADFetchItem(
    name: "example.com",
    nameDecoded: "example.com",
    type: MATCH_TYPE_STRING_WILDCARD,
    createdAt: Date.now.int64,
    expiresAt: 0
)

let DEMO_ITEM__EXACT__EXPIRE_VALID = ADFetchItem(
    name: "example.com",
    nameDecoded: "example.com",
    type: MATCH_TYPE_STRING_EXACT,
    createdAt: Date.now.int64,
    expiresAt: Date.now.int64 + 1_000_000_000
)

let DEMO_ITEM__EXACT__EXPIRE_EXPIRED = ADFetchItem(
    name: "example.com",
    nameDecoded: "example.com",
    type: MATCH_TYPE_STRING_EXACT,
    createdAt: Date.now.int64,
    expiresAt: Date.now.int64
)
