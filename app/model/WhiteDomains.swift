
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import AppKit
import CoreData

public class WhiteDomains: NSManagedObject {

    typealias SELF = WhiteDomains

    static let stringName = "WhiteDomains"

    @NSManaged var name: DomainName
    @NSManaged var nameDecoded: DomainName
    @NSManaged var isGlobal: Bool
    @NSManaged var expiresAt: Int64
    @NSManaged var createdAt: Int64

    var isWildcard: Bool {
        get { self.isGlobal }
        set { self.isGlobal = newValue }
    }

    convenience init() {
        self.init(context: Storage.context)
    }

}
