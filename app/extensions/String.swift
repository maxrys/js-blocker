
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

extension String {

    var percentDecode: String {
        self.removingPercentEncoding ?? self
    }

    func JSONEscaped() -> String {
        var result = self
        result = result.replacingOccurrences(of: "\\", with: "\\\\")
        result = result.replacingOccurrences(of: "\"", with: "\\\"")
        result = result.replacingOccurrences(of: "\n", with: "\\n")
        result = result.replacingOccurrences(of: "\r", with: "\\r")
        result = result.replacingOccurrences(of: "\t", with: "\\t")
        return result
    }

    func toWidth(_ width: UInt) -> String {
        self.padding(toLength: Int(width), withPad: " ", startingAt: 0)
    }

    func trimPrefix(_ prefix: String) -> String {
        self.hasPrefix(prefix) ? String(self.dropFirst(prefix.count)) : self
    }

    func trimSuffix(_ suffix: String) -> String {
        self.hasSuffix(suffix) ? String(self.dropLast(suffix.count)) : self
    }

}
