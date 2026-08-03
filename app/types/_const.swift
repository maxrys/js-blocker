
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

let NOT_APPLICABLE     = "—"
let GROUP_NAME         = "97CZR6J379.maxrys.js-blocker"
let EXTENSION_NAME     = "maxrys.js-blocker.extension"
let STORAGE_NAME       = "JSBlocker.sqlite"
let STORAGE_CLOUD_NAME = "iCloud.jsblocker"
let ZERO_WIDTH_SPACE   = "\u{200B}"

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

let DEMO_ITEM__EXACT = ADFetchItem(
    name: "example.com",
    nameDecoded: "example.com",
    isWildcard: false,
    createdAt: Int64(Date.now)
)

let DEMO_ITEM__WILDCARD = ADFetchItem(
    name: "example.com",
    nameDecoded: "example.com",
    isWildcard: true,
    createdAt: Int64(Date.now)
)
