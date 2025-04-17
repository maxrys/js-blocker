
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

class RulesHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        var unlessDomains: [String] = []

        for domain in WhiteDomains.selectAll() {
            if (domain.withSubdomains == true) { unlessDomains.append("*\(domain.name)") }
            else                               { unlessDomains.append( "\(domain.name)") }
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

        let JSONData = try! JSONSerialization.data(withJSONObject: JSONObject)
        let attachment = NSItemProvider(item: JSONData as NSSecureCoding?, typeIdentifier: "public.json")
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
       - JS from www.js-blocker.com:       !!! ON !!!
       - JS from sub1.js-blocker.com:      !!! ON !!!
       - JS from sub2.sub1.js-blocker.com: !!! ON !!!
       - JS from js-blocker.net:           !!! ON !!!
       Domain "www.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "sub1.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "sub2.sub1.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "js-blocker.net":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off

    Rule: "*js-blocker.com":

       Domain "js-blocker.com":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from www.js-blocker.com:       !!! ON !!!
       - JS from sub1.js-blocker.com:      !!! ON !!!
       - JS from sub2.sub1.js-blocker.com: !!! ON !!!
       - JS from js-blocker.net:           !!! ON !!!
       Domain "www.js-blocker.com":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from www.js-blocker.com:       !!! ON !!!
       - JS from sub1.js-blocker.com:      !!! ON !!!
       - JS from sub2.sub1.js-blocker.com: !!! ON !!!
       - JS from js-blocker.net:           !!! ON !!!
       Domain "sub1.js-blocker.com":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from www.js-blocker.com:       !!! ON !!!
       - JS from sub1.js-blocker.com:      !!! ON !!!
       - JS from sub2.sub1.js-blocker.com: !!! ON !!!
       - JS from js-blocker.net:           !!! ON !!!
       Domain "sub2.sub1.js-blocker.com":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from www.js-blocker.com:       !!! ON !!!
       - JS from sub1.js-blocker.com:      !!! ON !!!
       - JS from sub2.sub1.js-blocker.com: !!! ON !!!
       - JS from js-blocker.net:           !!! ON !!!
       Domain "js-blocker.net":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off

    Rule: "www.js-blocker.com":

       Domain "js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "www.js-blocker.com":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from www.js-blocker.com:       !!! ON !!!
       - JS from sub1.js-blocker.com:      !!! ON !!!
       - JS from sub2.sub1.js-blocker.com: !!! ON !!!
       - JS from js-blocker.net:           !!! ON !!!
       Domain "sub1.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "sub2.sub1.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "js-blocker.net":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off

    Rule: "*www.js-blocker.com":

       Domain "js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "www.js-blocker.com":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from www.js-blocker.com:       !!! ON !!!
       - JS from sub1.js-blocker.com:      !!! ON !!!
       - JS from sub2.sub1.js-blocker.com: !!! ON !!!
       - JS from js-blocker.net:           !!! ON !!!
       Domain "sub1.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "sub2.sub1.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "js-blocker.net":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off

    Rule: "sub1.js-blocker.com":

       Domain "js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "www.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "sub1.js-blocker.com":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from www.js-blocker.com:       !!! ON !!!
       - JS from sub1.js-blocker.com:      !!! ON !!!
       - JS from sub2.sub1.js-blocker.com: !!! ON !!!
       - JS from js-blocker.net:           !!! ON !!!
       Domain "sub2.sub1.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "js-blocker.net":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off

    Rule: "*sub1.js-blocker.com":

       Domain "js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "www.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "sub1.js-blocker.com":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from www.js-blocker.com:       !!! ON !!!
       - JS from sub1.js-blocker.com:      !!! ON !!!
       - JS from sub2.sub1.js-blocker.com: !!! ON !!!
       - JS from js-blocker.net:           !!! ON !!!
       Domain "sub2.sub1.js-blocker.com":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from www.js-blocker.com:       !!! ON !!!
       - JS from sub1.js-blocker.com:      !!! ON !!!
       - JS from sub2.sub1.js-blocker.com: !!! ON !!!
       - JS from js-blocker.net:           !!! ON !!!
       Domain "js-blocker.net":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off

    Rule: "sub2.sub1.js-blocker.com":

       Domain "js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "www.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "sub1.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "sub2.sub1.js-blocker.com":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from www.js-blocker.com:       !!! ON !!!
       - JS from sub1.js-blocker.com:      !!! ON !!!
       - JS from sub2.sub1.js-blocker.com: !!! ON !!!
       - JS from js-blocker.net:           !!! ON !!!
       Domain "js-blocker.net":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off

    Rule: "*sub2.sub1.js-blocker.com":

       Domain "js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "www.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "sub1.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "sub2.sub1.js-blocker.com":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from www.js-blocker.com:       !!! ON !!!
       - JS from sub1.js-blocker.com:      !!! ON !!!
       - JS from sub2.sub1.js-blocker.com: !!! ON !!!
       - JS from js-blocker.net:           !!! ON !!!
       Domain "js-blocker.net":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off

    Rule: "js-blocker.net":

       Domain "js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "www.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "sub1.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "sub2.sub1.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "js-blocker.net":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from www.js-blocker.com:       !!! ON !!!
       - JS from sub1.js-blocker.com:      !!! ON !!!
       - JS from sub2.sub1.js-blocker.com: !!! ON !!!
       - JS from js-blocker.net:           !!! ON !!!

    Rule: "*js-blocker.net":

       Domain "js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "www.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "sub1.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "sub2.sub1.js-blocker.com":
       - JS from js-blocker.com:           off
       - JS from www.js-blocker.com:       off
       - JS from sub1.js-blocker.com:      off
       - JS from sub2.sub1.js-blocker.com: off
       - JS from js-blocker.net:           off
       Domain "js-blocker.net":
       - JS from js-blocker.com:           !!! ON !!!
       - JS from www.js-blocker.com:       !!! ON !!!
       - JS from sub1.js-blocker.com:      !!! ON !!!
       - JS from sub2.sub1.js-blocker.com: !!! ON !!!
       - JS from js-blocker.net:           !!! ON !!!

*/
