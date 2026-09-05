
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import AppKit
import CoreData

public class AllowedDomains: NSManagedObject {

    typealias SELF = AllowedDomains

    static let stringName = "AllowedDomains"

    @NSManaged var name: DomainName
    @NSManaged var nameDecoded: DomainName
    @NSManaged var type: String
    @NSManaged var expiresAt: Int64
    @NSManaged var createdAt: Int64

    convenience init() {
        self.init(context: Storage.context)
    }

    static func hasDomain(name: DomainName) -> Bool {
        SELF.select(name) != nil
    }

    static func matchType(name: DomainName) -> MatchType {
        if let domainItem = SELF.select(name) {
            if (domainItem.type == MATCH_TYPE_STRING_EXACT   ) { return .exact   (item: domainItem) }
            if (domainItem.type == MATCH_TYPE_STRING_WILDCARD) { return .wildcard(item: domainItem) }
        }
        let wildcardDomains = SELF.selectWildcardDomains(name)
        if let first = wildcardDomains.first {
            return .wildcard(item: first)
        }
        return .noOne
    }

    static func selectWildcardDomains(_ name: DomainName, ascending: Bool = false) -> ADFetchCollection {
        do {
            let names = [name] + name.topDomains(isDeleteTLD: true)
            let request = NSFetchRequest<SELF>(entityName: SELF.stringName)
            request.fetchLimit = Int.max
            request.sortDescriptors = [ NSSortDescriptor(key: #keyPath(SELF.name), ascending: ascending) ]
            request.predicate = NSPredicate(format: "(name IN %@) AND (type == \"\(MATCH_TYPE_STRING_WILDCARD)\")", names)
            return try Storage.context.fetch(request).reduce(into: ADFetchCollection()) { result, modelItem in
                result.appendUnique(modelItem)
            }
        } catch {
            Logger.customLog("Model \(SELF.stringName).selectWildcardDomains() error: \(error).")
            return []
        }
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

    static func select(_ name: DomainName) -> ADFetchItem? {
        do {
            let request = NSFetchRequest<SELF>(entityName: SELF.stringName)
            request.fetchLimit = 1
            request.sortDescriptors = [ NSSortDescriptor(key: #keyPath(SELF.createdAt), ascending: false) ]
            request.predicate = NSPredicate(format: "name ==[c] %@", name)
            let result = try Storage.context.fetch(request)
            return result.first.ifNil(defaultValue: nil) { first in
                ADFetchItem(item: first)
            }
        } catch {
            Logger.customLog("Model \(SELF.stringName).select() error: \(error).")
            return nil
        }
    }

    static func selectAll(
        _ filterByName: String? = nil,
        skipExpired: Bool = true,
        orderBy: String = #keyPath(SELF.nameDecoded),
        ascending: Bool = true
    ) -> ADFetchCollection {
        do {
            let request = NSFetchRequest<SELF>(entityName: SELF.stringName)
            request.fetchLimit = Int.max
            request.predicate = {
                var result:[NSPredicate] = []
                if let filterByName { result.append(NSPredicate(format: "nameDecoded CONTAINS[cd] %@", filterByName)) }
                if (skipExpired)    { result.append(NSPredicate(format: "(expiresAt == 0) OR (expiresAt > %@)", NSNumber(value: Date.now.int64))) }
                return NSCompoundPredicate(
                    andPredicateWithSubpredicates: result
                )
            }()
            request.sortDescriptors = [
                NSSortDescriptor(key: orderBy, ascending: ascending),
                NSSortDescriptor(key: #keyPath(SELF.createdAt), ascending: false)
            ]
            return try Storage.context.fetch(request).reduce(into: ADFetchCollection()) { result, modelItem in
                result.appendUnique(modelItem)
            }
        } catch {
            Logger.customLog("Model \(SELF.stringName).selectAll() error: \(error).")
            return []
        }
    }

    static func insert(name: DomainName, type: String = MATCH_TYPE_STRING_EXACT, expiresAt: Int64 = 0, createdAt: Int64? = nil, isVersioningDisabled: Bool = false) -> ExecuteResult {
        let newObject = SELF()
            newObject.name        = name
            newObject.nameDecoded = name.decodePunycode()
            newObject.type        = type
            newObject.expiresAt   = expiresAt
            newObject.createdAt   = createdAt ?? Int64(Date.now)
        do {
            try Storage.context.save()
            if (!isVersioningDisabled) {
            _ = EntityVersions.versionIncrement(SELF.stringName)
                EntityVersions.dump()
            }
            return .success(affected: 1)
        } catch {
            Storage.context.delete(newObject)
            Logger.customLog("Model \(SELF.stringName).insert() error: \(error).")
            return .failure
        }
    }

    static func delete(_ names: [DomainName]) -> ExecuteResult {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: SELF.stringName)
            request.predicate = NSPredicate(format: "name IN %@", names)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            deleteRequest.resultType = .resultTypeObjectIDs
            let result = try Storage.context.execute(deleteRequest) as? NSBatchDeleteResult
            let affectedIDs = result?.result as? [NSManagedObjectID] ?? []
            if (affectedIDs.count > 0) {
                NSManagedObjectContext.mergeChanges(
                    fromRemoteContextSave: [NSDeletedObjectsKey: affectedIDs],
                    into: [Storage.context]
                )
            _ = EntityVersions.versionIncrement(SELF.stringName)
                EntityVersions.dump()
            }
            return .success(
                affected: affectedIDs.count
            )
        } catch {
            Logger.customLog("Model \(SELF.stringName).delete() error: \(error).")
            return .failure
        }
    }

    static func sanitize() -> ExecuteResult {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: SELF.stringName)
            request.predicate = NSPredicate(format: "(expiresAt <> 0) AND (expiresAt < %@)", NSNumber(value: Date.now.int64))
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            deleteRequest.resultType = .resultTypeObjectIDs
            let result = try Storage.context.execute(deleteRequest) as? NSBatchDeleteResult
            let affectedIDs = result?.result as? [NSManagedObjectID] ?? []
            if (affectedIDs.count > 0) {
                NSManagedObjectContext.mergeChanges(
                    fromRemoteContextSave: [NSDeletedObjectsKey: affectedIDs],
                    into: [Storage.context]
                )
            _ = EntityVersions.versionIncrement(SELF.stringName)
                EntityVersions.dump()
            }
            return .success(
                affected: affectedIDs.count
            )
        } catch {
            Logger.customLog("Model \(SELF.stringName).sanitize() error: \(error).")
            return .failure
        }
    }

    static func dump() {
        #if DEBUG
            let items = SELF.selectAll(skipExpired: false)
            if (!items.isEmpty) {

                let rows: [String] = items.reduce(into: []) { result, item in
                    let formattedName      = item.name
                    let formattedExpiresAt = item.expiresAt != 0 ? Date(timeIntervalSince1970: TimeInterval(item.expiresAt)).formatISO8601 : NOT_APPLICABLE
                    let formattedType      = item.type
                    result.append(">> " +
                        "\(formattedName     .toWidth(48)) | " +
                        "\(formattedExpiresAt.toWidth(19)) | " +
                        "\(formattedType     .toWidth(11))"
                    )
                }

                Logger.customLog("""

                Storage Dump for \"\(SELF.stringName)\":
                >> ------------------------------------------------------------------------------------
                >> name                                             |     expires at      |    type
                >> ====================================================================================
                \(rows.joined(separator: "\n"))
                >> ------------------------------------------------------------------------------------

                """)
            } else {
                Logger.customLog("""

                Storage Dump for \"\(SELF.stringName)\":
                >> ------------------------------------------------------------------------------------
                >>                                    ... no data ...
                >> ------------------------------------------------------------------------------------

                """)
            }
        #endif
    }

}
