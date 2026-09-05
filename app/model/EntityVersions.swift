
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import AppKit
import CoreData

extension EntityVersions {

    static let EVENT_NAME_FOR_ENTITY_CHANGE = "\(APP_ID)-onChangeEntity"

    struct DistributedMessasge {

        let name: String
        let version: Int64

        init(name: String, version: Int64) {
            self.name = name
            self.version = version
        }

        init?(decode data: String) {
            let parts = data.split(separator: "|", omittingEmptySubsequences: false)
            guard parts.count == 2 else { return nil }
            let name = String(parts[0])
            guard let version = Int64(parts[1]) else { return nil }
            self.name = name
            self.version = version
        }

        public func encode() -> String {
            return "\(name)|\(version)"
        }

        public static func post(name: String, version: Int64) {
            DistributedNotificationCenter.default().postNotificationName(
                Notification.Name(EVENT_NAME_FOR_ENTITY_CHANGE),
                object: Self(name: name, version: version).encode(),
                deliverImmediately: true
            )
        }

    }

}


public class EntityVersions: NSManagedObject {

    typealias SELF = EntityVersions

    static let stringName = "EntityVersions"

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
            let request = NSFetchRequest<SELF>(entityName: SELF.stringName)
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
            let request = NSFetchRequest<SELF>(entityName: SELF.stringName)
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
            var version: Int64 = 0
            let request = NSFetchRequest<SELF>(entityName: SELF.stringName)
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "name ==[c] %@", name)
            if let entity = (try Storage.context.fetch(request)).first {
                entity.version += 1
                try Storage.context.save()
                version = entity.version
            } else {
                let newObject = SELF()
                    newObject.name = name
                    newObject.version = 0
                try Storage.context.save()
                version = 0
            }
            DistributedMessasge.post(
                name: name,
                version: version
            )
            return version
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
