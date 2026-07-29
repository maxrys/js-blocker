
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import AppKit
import CoreData

public class EntityVersions: NSManagedObject {

    typealias SELF = EntityVersions

    static let stringName = "EntityVersions"
    static let fetchRequest: NSFetchRequest<SELF> = {
        NSFetchRequest<SELF>(entityName: SELF.stringName)
    }()

    @NSManaged var name: String
    @NSManaged var version: Int64

    convenience init() {
        self.init(context: Storage.context)
    }

    static func selectAll(
        orderBy: String = #keyPath(SELF.name),
        ascending: Bool = true
    ) -> [SELF] {
        do {
            let request = Self.fetchRequest
            request.fetchLimit = Int.max
            let orderBy = NSSortDescriptor(key: orderBy, ascending: ascending)
            request.sortDescriptors = [orderBy]
            return try Storage.context.fetch(request)
        } catch {
            Logger.customLog("Model EntityVersions.selectAll() error: \(error).")
            return []
        }
    }

    static func versionGet(_ name: String) -> Int64? {
        do {
            let request = Self.fetchRequest
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "name ==[c] %@", name)
            let result = try Storage.context.fetch(request)
            return result.first?.version ?? nil
        } catch {
            Logger.customLog("Model EntityVersions.versionGet() error: \(error).")
            return nil
        }
    }

    static func versionIncrement(_ name: String) ->Int64? {
        do {
            let request = Self.fetchRequest
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "name ==[c] %@", name)
            let result = try Storage.context.fetch(request)
            if let entity = result.first {
                entity.version += 1
                try Storage.context.save()
                return entity.version
            } else {
                let newObject = SELF()
                    newObject.name = name
                    newObject.version = 0
                try Storage.context.save()
                return 0
            }
        } catch {
            Logger.customLog("Model EntityVersions.versionIncrement() error: \(error).")
            return nil
        }
    }

    static func dump() {
        #if DEBUG
            let items = Self.selectAll()
            if (!items.isEmpty) {

                let rows: [String] = items.reduce(into: []) { result, item in
                    let formattedName    = item.name
                    let formattedVersion = String(item.version)
                    result.append(">> " +
                        "\(formattedName   .toWidth(48)) | " +
                        "\(formattedVersion.toWidth(19))"
                    )
                }

                Logger.customLog("""

                Storage Dump for \"Entity Versions\":
                >> --------------------------------------------------------------------
                >> name                                             |     version      
                >> ====================================================================
                \(rows.joined(separator: "\n"))
                >> --------------------------------------------------------------------

                """)
            } else {
                Logger.customLog("""

                Storage Dump for \"Entity Versions\":
                >> --------------------------------------------------------------------
                >>                           ... no data ...
                >> --------------------------------------------------------------------

                """)
            }
        #endif
    }

}
