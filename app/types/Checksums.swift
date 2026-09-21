
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation

enum Checksums {

    static func crc32(_ value: String) -> UInt32 {
        var result: UInt32 = 0xffff_ffff
        for byte in value.utf8 {
            result ^= UInt32(byte)
            for _ in 0 ..< 8 {
                if (result & 1 != 0)
                     { result = (result >> 1) ^ 0xedb8_8320 }
                else { result = (result >> 1) }
            }
        }
        return result ^ 0xffff_ffff
    }

}
