
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

class RulesHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        let items = AllowedDomains.selectAll()
        let attachment = NSItemProvider(
            item: items.blockingRulesJSON as NSSecureCoding?,
            typeIdentifier: "public.json"
        )
        let item = NSExtensionItem()
        item.attachments = [attachment]
        context.completeRequest(
            returningItems: [item],
            completionHandler: nil
        )
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
