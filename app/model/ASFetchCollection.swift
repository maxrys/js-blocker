
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

typealias ASFetchCollection = Array<ASFetchItem>
extension ASFetchCollection {

    mutating func appendUnique(_ item: AllowedScripts) {
        let newItem = ASFetchItem(item: item)
        if !self.contains(newItem) {
            self.append  (newItem)
        }
    }

    public var strictJSON: String {
        "[" +
            self.reduce(into: [String]()) { buffer, item in
                buffer.append(item.strictJSON)
            }.joined(separator: ",") +
        "]"
    }

}
