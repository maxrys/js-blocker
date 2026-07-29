
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

typealias ADFetchCollection = Array<ADFetchItem>
extension ADFetchCollection {

    mutating func appendUnique(_ item: ADModel) {
        let newItem = ADFetchItem(item: item)
        if !self.contains(newItem) {
            self.append  (newItem)
        }
    }

}
