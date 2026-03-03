
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

typealias ADFetchCollection = Array<ADFetchItem>
extension ADFetchCollection {

    func hash() -> Int {
        if (!self.isEmpty) {
            var hasher = Hasher()
            for item in self {
                hasher.combine(item.name)
                hasher.combine(item.nameDecoded)
                hasher.combine(item.isWildcard) }
            return hasher.finalize()
        }
        return 0
    }

    mutating func appendUnique(_ item: AllowedDomains) {
        let newItem = ADFetchItem(
            name       : item.name,
            nameDecoded: item.nameDecoded,
            isWildcard : item.isWildcard )
        if (!self.contains(newItem)) { self.append(newItem) }
    }

}

struct ADFetchItem: Equatable {

    let name: String
    let nameDecoded: String
    let isWildcard: Bool

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }

}
