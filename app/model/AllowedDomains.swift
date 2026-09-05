
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import AppKit
import CoreData

typealias AllowedDomains = WhiteDomains

extension AllowedDomains {

    static func hasDomain(name: DomainName) -> Bool {
        SELF.select(name) != nil
    }

    static func matchType(name: DomainName) -> MatchType {
        if let domainItem = SELF.select(name) {
            if (domainItem.isWildcard != true) { return .exact   (item: domainItem) }
            if (domainItem.isWildcard == true) { return .wildcard(item: domainItem) }
        }
        let wildcardDomains = SELF.selectWildcardDomains(name)
        if let first = wildcardDomains.first {
            return .wildcard(item: first)
        }
        return .noOne
    }

    static func selectWildcardDomains(_ name: DomainName, ascending: Bool = false) -> ADFetchCollection {
        do {
            let orderBy = NSSortDescriptor(key: #keyPath(SELF.name), ascending: ascending)
            let names = [name] + name.topDomains(isDeleteTLD: true)
            let request = NSFetchRequest<SELF>(entityName: SELF.stringName)
            request.fetchLimit = Int.max
            request.sortDescriptors = [orderBy]
            request.predicate = NSPredicate(format: "(name IN %@) AND (isGlobal == true)", names)
            return try Storage.context.fetch(request).reduce(into: ADFetchCollection()) { result, modelItem in
                result.appendUnique(modelItem)
            }
        } catch {
            Logger.customLog("Model \(SELF.stringName).selectWildcardDomains() error: \(error).")
            return []
        }
    }

    static func select(_ name: DomainName) -> ADFetchItem? {
        do {
            let orderBy = NSSortDescriptor(key: #keyPath(SELF.createdAt), ascending: false)
            let request = NSFetchRequest<SELF>(entityName: SELF.stringName)
            request.fetchLimit = 1
            request.sortDescriptors = [orderBy]
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
        skipWithExpiration: Bool = false,
        skipExpired: Bool = true,
        orderBy: String = #keyPath(SELF.nameDecoded),
        ascending: Bool = true
    ) -> ADFetchCollection {
        do {
            let request = NSFetchRequest<SELF>(entityName: SELF.stringName)
            request.fetchLimit = Int.max
            var predicates: [NSPredicate] = []
            if let filterByName = filterByName { predicates.append(NSPredicate(format: "nameDecoded CONTAINS[cd] %@", filterByName)) }
            if (skipWithExpiration) { predicates.append(NSPredicate(format: "(expiresAt == 0)")) }
            if (skipExpired       ) { predicates.append(NSPredicate(format: "(expiresAt == 0) OR (expiresAt > %@)", NSNumber(value: Date.now.int64))) }
            if (predicates.isEmpty == false) { request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates) }
            let orderByDefault = NSSortDescriptor(key: orderBy, ascending: ascending)
            let orderByCreated = NSSortDescriptor(key: #keyPath(SELF.createdAt), ascending: false)
            request.sortDescriptors = [orderByDefault, orderByCreated]
            return try Storage.context.fetch(request).reduce(into: ADFetchCollection()) { result, modelItem in
                result.appendUnique(modelItem)
            }
        } catch {
            Logger.customLog("Model \(SELF.stringName).selectAll() error: \(error).")
            return []
        }
    }

    static func insert(name: DomainName, isWildcard: Bool = false, expiresAt: Int64 = 0) -> ExecuteResult {
        do {
            let newObject = SELF()
                newObject.name        = name
                newObject.nameDecoded = name.decodePunycode()
                newObject.isWildcard  = isWildcard
                newObject.expiresAt   = expiresAt
                newObject.createdAt   = Int64(Date.now)
            try Storage.context.save()
            _ = EntityVersions.versionIncrement(SELF.stringName)
                EntityVersions.dump()
            return .success(affected: 1)
        } catch {
            Logger.customLog("Model \(SELF.stringName).insert() error: \(error).")
            return .failure
        }
    }

    static func delete(_ names: [DomainName]) -> ExecuteResult {
        do {
            let request = NSFetchRequest<SELF>(entityName: SELF.stringName)
            request.fetchLimit = Int.max
            request.predicate = NSPredicate(format: "name IN %@", names)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
            deleteRequest.resultType = .resultTypeCount
            let result = try Storage.context.execute(deleteRequest) as? NSBatchDeleteResult
            let affected = result?.result as? Int ?? 0
            try Storage.context.save()
            if (affected > 0) {
            _ = EntityVersions.versionIncrement(SELF.stringName)
                EntityVersions.dump()
            }
            return .success(
                affected: affected
            )
        } catch {
            Logger.customLog("Model \(SELF.stringName).delete() error: \(error).")
            return .failure
        }
    }

    static func sanitize() -> ExecuteResult {
        do {
            let request = NSFetchRequest<SELF>(entityName: SELF.stringName)
            request.fetchLimit = Int.max
            request.predicate = NSPredicate(format: "(expiresAt <> 0) AND (expiresAt < %@)", NSNumber(value: Date.now.int64))
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
            deleteRequest.resultType = .resultTypeCount
            let result = try Storage.context.execute(deleteRequest) as? NSBatchDeleteResult
            let affected = result?.result as? Int ?? 0
            try Storage.context.save()
            if (affected > 0) {
            _ = EntityVersions.versionIncrement(SELF.stringName)
                EntityVersions.dump()
            }
            return .success(
                affected: affected
            )
        } catch {
            Logger.customLog("Model \(SELF.stringName).sanitize() error: \(error).")
            return .failure
        }
    }

    static func dump() {
        #if DEBUG
            let items = SELF.selectAll(
                skipWithExpiration: false,
                skipExpired: false
            )
            if (!items.isEmpty) {

                let rows: [String] = items.reduce(into: []) { result, item in
                    let formattedName       = item.name
                    let formattedExpiresAt  = item.expiresAt != 0 ? Date(timeIntervalSince1970: TimeInterval(item.expiresAt)).formatISO8601 : NOT_APPLICABLE
                    let formattedIsWildcard = item.isWildcard ? "yes" : "no"
                    result.append(">> " +
                        "\(formattedName      .toWidth(48)) | " +
                        "\(formattedExpiresAt .toWidth(19)) | " +
                        "\(formattedIsWildcard.toWidth(11))"
                    )
                }

                Logger.customLog("""

                Storage Dump for \"\(SELF.stringName)\":
                >> ------------------------------------------------------------------------------------
                >> name                                             |     expires at      | is wildcard
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
