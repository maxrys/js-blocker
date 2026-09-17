
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

typealias ADFetchCollection = Array<ADFetchItem>
extension ADFetchCollection {

    mutating func appendUnique(_ item: AllowedDomains) {
        let newItem = ADFetchItem(item: item)
        if !self.contains(newItem) {
            self.append  (newItem)
        }
    }

    public var blockingRulesJSON: Data {
        var unlessDomains: [String] = []

        for domainItem in self {
            if (domainItem.type == MATCH_TYPE_STRING_EXACT   ) { unlessDomains.append( "\(domainItem.name)") }
            if (domainItem.type == MATCH_TYPE_STRING_WILDCARD) { unlessDomains.append("*\(domainItem.name)") }
        }

        var JSONObject: Any = []

        if !unlessDomains.isEmpty {
            JSONObject = [[
                "action": [
                    "type": "block"
                ],
                "trigger": [
                    "url-filter": ".*",
                    "url-filter-is-case-sensitivity": true,
                    "resource-type": ["script"],
                    "unless-domain": unlessDomains
                ]
            ]]
        } else {
            JSONObject = [[
                "action": [
                    "type": "block"
                ],
                "trigger": [
                    "url-filter": ".*",
                    "url-filter-is-case-sensitivity": true,
                    "resource-type": ["script"]
                ]
            ]]
        }

        return try! JSONSerialization.data(
            withJSONObject: JSONObject
        )
    }


}
