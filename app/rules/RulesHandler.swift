
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

class RulesHandler: NSObject, NSExtensionRequestHandling {

    static var JSON: Data {
        var unlessDomains: [String] = []

        for domain in AllowedDomains.selectAll() {
            if (domain.isWildcard != true) { unlessDomains.append( "\(domain.name)") }
            if (domain.isWildcard == true) { unlessDomains.append("*\(domain.name)") }
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

    func beginRequest(with context: NSExtensionContext) {
        let attachment = NSItemProvider(item: Self.JSON as NSSecureCoding?, typeIdentifier: "public.json")
        let item = NSExtensionItem()
        item.attachments = [attachment]
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }

}

/*

    ################################################
    ### RESEARCH OF THE RULES IN REAL CONDITIONS ###
    ################################################

    Rule: "js-blocker.com":

       Domain "js-blocker.com":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from subdomain.js-blocker.com: !!! ON !!!
       - JS from js-blocker:               !!! ON !!!
       Domain "subdomain.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from subdomain.js-blocker.com: off
       - JS from js-blocker:               off
       Domain "js-blocker":
       - JS from js-blocker.com:           off
       - JS from subdomain.js-blocker.com: off
       - JS from js-blocker:               off

    Rule: "*js-blocker.com":

       Domain "js-blocker.com":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from subdomain.js-blocker.com: !!! ON !!!
       - JS from js-blocker:               !!! ON !!!
       Domain "subdomain.js-blocker.com":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from subdomain.js-blocker.com: !!! ON !!!
       - JS from js-blocker:               !!! ON !!!
       Domain "js-blocker":
       - JS from js-blocker.com:           off
       - JS from subdomain.js-blocker.com: off
       - JS from js-blocker:               off

    Rule: "subdomain.js-blocker.com":

       Domain "js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from subdomain.js-blocker.com: off
       - JS from js-blocker:               off
       Domain "subdomain.js-blocker.com":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from subdomain.js-blocker.com: !!! ON !!!
       - JS from js-blocker:               !!! ON !!!
       Domain "js-blocker":
       - JS from js-blocker.com:           off
       - JS from subdomain.js-blocker.com: off
       - JS from js-blocker:               off

    Rule: "*subdomain.js-blocker.com":

       Domain "js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from subdomain.js-blocker.com: off
       - JS from js-blocker:               off
       Domain "subdomain.js-blocker.com":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from subdomain.js-blocker.com: !!! ON !!!
       - JS from js-blocker:               !!! ON !!!
       Domain "js-blocker":
       - JS from js-blocker.com:           off
       - JS from subdomain.js-blocker.com: off
       - JS from js-blocker:               off

    Rule: "js-blocker":

       Domain "js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from subdomain.js-blocker.com: off
       - JS from js-blocker:               off
       Domain "subdomain.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from subdomain.js-blocker.com: off
       - JS from js-blocker:               off
       Domain "js-blocker":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from subdomain.js-blocker.com: !!! ON !!!
       - JS from js-blocker:               !!! ON !!!

    Rule: "*js-blocker":

       Domain "js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from subdomain.js-blocker.com: off
       - JS from js-blocker:               off
       Domain "subdomain.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from subdomain.js-blocker.com: off
       - JS from js-blocker:               off
       Domain "js-blocker":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from subdomain.js-blocker.com: !!! ON !!!
       - JS from js-blocker:               !!! ON !!!

*/
