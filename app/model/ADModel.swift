
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import AppKit
import CoreData

typealias ADModel = WhiteDomains

public class WhiteDomains: NSManagedObject {

    typealias SELF = WhiteDomains

    static let stringName = "WhiteDomains"
    static let fetchRequest: NSFetchRequest<SELF> = {
        NSFetchRequest<SELF>(entityName: SELF.stringName)
    }()

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

    static func hasDomain(name: DomainName) -> Bool {
        Self.select(name) != nil
    }

    static func matchType(name: DomainName) -> MatchType {
        if let domainItem = Self.select(name) {
            if (domainItem.isWildcard != true) { return .exact   (item: ADFetchItem(item: domainItem)) }
            if (domainItem.isWildcard == true) { return .wildcard(item: ADFetchItem(item: domainItem)) }
        }
        let wildcardDomains = Self.selectWildcardDomains(name)
        if (wildcardDomains.count > 0) {
            return .wildcard(item: wildcardDomains[0])
        }
        return .noOne
    }

    static func select(_ name: DomainName) -> SELF? {
        do {
            let orderBy = NSSortDescriptor(key: #keyPath(SELF.createdAt), ascending: false)
            let request = Self.fetchRequest
            request.fetchLimit = 1
            request.sortDescriptors = [orderBy]
            request.predicate = NSPredicate(format: "name ==[c] %@", name)
            let result = try Storage.context.fetch(request)
            return result.isEmpty ? nil : result.first
        } catch {
            Logger.customLog("Model ADModel.select() error: \(error).")
            return nil
        }
    }

    static func selectAll(
        _ filterByName: String? = nil,
        orderBy: String = #keyPath(SELF.nameDecoded),
        ascending: Bool = true
    ) -> ADFetchCollection {
        do {
            let request = Self.fetchRequest
            request.fetchLimit = Int.max
            if let filterByName = filterByName { fetchRequest.predicate = NSPredicate(format: "nameDecoded CONTAINS[cd] %@", filterByName, filterByName) }
            let orderByDefault = NSSortDescriptor(key: orderBy, ascending: ascending)
            let orderByCreated = NSSortDescriptor(key: #keyPath(SELF.createdAt), ascending: false)
            request.sortDescriptors = [orderByDefault, orderByCreated]
            return try Storage.context.fetch(request).reduce(into: ADFetchCollection()) { result, modelItem in
                result.appendUnique(modelItem)
            }
        } catch {
            Logger.customLog("Model ADModel.selectAll() error: \(error).")
            return []
        }
    }

    static func selectWildcardDomains(_ name: DomainName) -> ADFetchCollection {
        do {
            let orderBy = NSSortDescriptor(key: #keyPath(SELF.name), ascending: false)
            let names = [name] + name.topDomains(isDeleteTLD: true)
            let request = Self.fetchRequest
            request.fetchLimit = Int.max
            request.sortDescriptors = [orderBy]
            request.predicate = NSPredicate(format: "(name IN %@) AND (isGlobal == true)", names)
            return try Storage.context.fetch(request).reduce(into: ADFetchCollection()) { result, modelItem in
                result.appendUnique(modelItem)
            }
        } catch {
            Logger.customLog("Model ADModel.selectWildcardDomains() error: \(error).")
            return []
        }
    }

    static func insert(name: DomainName, isWildcard: Bool = false, expiresAt: Int64 = 0) -> Bool {
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
            return true
        } catch {
            Logger.customLog("Model ADModel.insert() error: \(error).")
            return false
        }
    }

    static func delete(_ names: [DomainName]) -> ExecuteResult {
        do {
            let request = Self.fetchRequest
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
            Logger.customLog("Model ADModel.delete() error: \(error).")
            return .failure
        }
    }

    static func dump() {
        #if DEBUG
            let items = Self.selectAll()
            if (!items.isEmpty) {

                let rows: [String] = items.reduce(into: []) { result, item in
                    let formattedName       = item.name
                    let formattedIsWildcard = item.isWildcard ? "yes" : "no"
                    result.append(">> " +
                        "\(formattedName      .toWidth(62)) | " +
                        "\(formattedIsWildcard.toWidth(11))"
                    )
                }

                Logger.customLog("""

                Storage Dump for \"Allowed Domains\":
                >> ---------------------------------------------------------------------------
                >> name                                                           | isWildcard
                >> ===========================================================================
                \(rows.joined(separator: "\n"))
                >> ---------------------------------------------------------------------------

                """)
            } else {
                Logger.customLog("""

                Storage Dump for \"Allowed Domains\":
                >> ---------------------------------------------------------------------------
                >>                              ... no data ...
                >> ---------------------------------------------------------------------------

                """)
            }
        #endif
    }

}
