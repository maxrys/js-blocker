
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

    convenience init() {
        self.init(context: Storage.context)
    }

    static func selectCount() -> Int {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: SELF.stringName)
            return try Storage.context.count(for: request)
        } catch {
            Logger.customLog("Model \(SELF.stringName).selectCount() error: \(error).")
            return 0
        }
    }

    static func selectAll() -> [SELF] {
        do {
            let request = NSFetchRequest<SELF>(entityName: SELF.stringName)
            request.fetchLimit = Int.max
            return try Storage.context.fetch(request)
        } catch {
            Logger.customLog("Model \(SELF.stringName).selectAll() error: \(error).")
            return []
        }
    }

}
