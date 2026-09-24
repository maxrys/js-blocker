
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import Foundation

extension Numeric {

    func fixBounds(min: Self = 0, max: Self) -> Self where Self: Comparable {
        if (self < min) { return min }
        if (self > max) { return max }
        return self
    }

}

extension BinaryInteger {

    func progress(begin: Self, end: Self) -> Double {
        guard end > begin else { return 0 }
        return ((Double(self) - Double(begin)) / (Double(end) - Double(begin))).fixBounds(
            min: 0.0,
            max: 1.0
        )
    }

}

extension BinaryFloatingPoint {

    func progress(begin: Self, end: Self) -> Double {
        guard isFinite, begin.isFinite, end.isFinite, end > begin else { return 0 }
        return Double((self - begin) / (end - begin)).fixBounds(
            min: 0.0,
            max: 1.0
        )
    }

}
