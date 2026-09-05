
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

    var crc32: String {
        var crc: UInt32 = 0xffffffff
        for byte in self.utf8 {
            crc ^= UInt32(byte)
            for _ in 0 ..< 8 {
                if crc & 1 == 1 {
                    crc = (crc >> 1) ^ 0xedb88320
                } else {
                    crc >>= 1
                }
            }
        }
        return String(format: "%08x", crc ^ 0xffffffff)
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
