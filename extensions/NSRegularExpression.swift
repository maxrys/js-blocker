
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

extension NSRegularExpression {

    func findRanges(string: String, rangeNames: [String]) -> [String: String] {
        var result: [String: String] = [:]
        if let matchesResult = self.firstMatch(in: string, range: NSRange(location: 0, length: string.count)) {
            for rangeName in rangeNames {
                let matchesRange = matchesResult.range(withName: rangeName)
                if matchesRange.location != NSNotFound {
                    if let finalRange = Range(matchesRange, in: string) {
                        result[rangeName] = String(
                            string[finalRange]
                        )
                    }
                }
            }
        }
        return result
    }

}
