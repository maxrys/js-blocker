
import Foundation

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        let domains = [
            "js-blocker.com",
            "www.js-blocker.com",
            "sub2.sub1.js-blocker.com",
            "js-blocker.net",
            "js-blocker.org",
            "*youtube.com"
        ]

        let result = [[
            "action": [
                "type": "block"
            ],
            "trigger": [
                "url-filter": ".*",
                "url-filter-is-case-sensitivity": true,
                "resource-type": ["script"],
                "unless-domain": domains
            ]
        ]]

        let JSON = try! JSONSerialization.data(withJSONObject: result)
        let attachment = NSItemProvider(item: JSON as NSSecureCoding?, typeIdentifier: "public.json")
        let item = NSExtensionItem()
        item.attachments = [attachment]
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }

}
