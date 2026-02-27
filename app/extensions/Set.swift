
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

extension Set {

    mutating func toggle(_ element: Element) {
        if (self.contains(element)) { self.remove(element) }
        else                        { self.insert(element) }
    }

}
