
import Foundation

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        var rules: [String] = []

        for domain in WhiteDomains.selectAll() {
            if domain.withSubdomains == true {rules.append("*\(domain.name)")}
            else                             {rules.append( "\(domain.name)")}
        }

        var result: Any = []

        if !rules.isEmpty {
            result = [[
                "action": [
                    "type": "block"
                ],
                "trigger": [
                    "url-filter": ".*",
                    "url-filter-is-case-sensitivity": true,
                    "resource-type": ["script"],
                    "unless-domain": rules
                ]
            ]]
        } else {
            result = [[
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

        let JSON = try! JSONSerialization.data(withJSONObject: result)
        let attachment = NSItemProvider(item: JSON as NSSecureCoding?, typeIdentifier: "public.json")
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
