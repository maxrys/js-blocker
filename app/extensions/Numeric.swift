
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

    func progress(max: Self) -> Double where Self: BinaryInteger {
        guard max  >  0   else { return 0.0 }
        guard self >= 0   else { return 0.0 }
        guard self <= max else { return 1.0 }
        let result = Double(self) / Double(max)
        return result.isNaN ? 0 : result.fixBounds(
            min: 0.0,
            max: 1.0
        )
    }

    func progress(min: Self, max: Self) -> Double where Self: BinaryInteger {
        guard max  >  min else { return 0.0 }
        guard self >= min else { return 0.0 }
        guard self <= max else { return 1.0 }
        let result = Double(self - min) / Double(max - min)
        return result.isNaN ? 0 : result.fixBounds(
            min: 0.0,
            max: 1.0
        )
    }

}
