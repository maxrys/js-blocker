
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

struct CheckSum {

    static func crc32(_ value: String) -> UInt32 {
        var result: UInt32 = 0xffffffff
        for byte in value.utf8 {
            result ^= UInt32(byte)
            for _ in 0 ..< 8 {
                if result & 1 == 1 {
                    result = (result >> 1) ^ 0xedb88320
                } else {
                    result >>= 1
                }
            }
        }
        return result
    }

}
