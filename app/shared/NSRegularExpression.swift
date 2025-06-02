
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

extension NSRegularExpression {

    func findInGroups(in string: String, groups: [String]) -> [String: String] {
        var result: [String: String] = [:]
        if let matchesResult = self.firstMatch(in: string, range: NSRange(location: 0, length: string.count)) {
            for group in groups {
                let matchesRange = matchesResult.range(withName: group)
                if (matchesRange.location != NSNotFound) {
                    if let finalRange = Range(matchesRange, in: string) {
                        result[group] = String(
                            string[finalRange]
                        )
                    }
                }
            }
        }
        return result
    }

}
