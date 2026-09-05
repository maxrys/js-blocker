
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import AppKit
import CoreData

public class AllowedScripts: NSManagedObject {

    typealias SELF = AllowedScripts

    static let stringName = "AllowedScripts"

    @NSManaged var domain: DomainName
    @NSManaged var frameDomain: DomainName
    @NSManaged var url: String
    @NSManaged var createdAt: Int64

    convenience init() {
        self.init(context: Storage.context)
    }

    static func selectAll() -> ASFetchCollection {
        do {
            let request = NSFetchRequest<SELF>(entityName: SELF.stringName)
            request.fetchLimit = Int.max
            request.sortDescriptors = [
                NSSortDescriptor(key: #keyPath(SELF.domain     ), ascending: false),
                NSSortDescriptor(key: #keyPath(SELF.frameDomain), ascending: false)
            ]
            return try Storage.context.fetch(request).reduce(into: ASFetchCollection()) { result, modelItem in
                result.appendUnique(modelItem)
            }
        } catch {
            Logger.customLog("Model \(SELF.stringName).selectAll() error: \(error).")
            return []
        }
    }

    static func selectByDomain(domain: DomainName, frameDomain: DomainName? = nil) -> ASFetchCollection {
        do {
            let request = NSFetchRequest<SELF>(entityName: SELF.stringName)
            request.fetchLimit = Int.max
            request.predicate = {
                var result = [ NSPredicate(format: "domain == %@", domain) ]
                if let frameDomain { result.append(NSPredicate(format: "frameDomain == %@", frameDomain)) }
                return NSCompoundPredicate(
                    andPredicateWithSubpredicates: result
                )
            }()
            return try Storage.context.fetch(request).reduce(into: ASFetchCollection()) { result, modelItem in
                result.appendUnique(modelItem)
            }
        } catch {
            Logger.customLog("Model \(SELF.stringName).selectByDomain() error: \(error).")
            return []
        }
    }

    static func insert(domain: DomainName, frameDomain: DomainName, url: String, createdAt: Int64? = nil) -> ExecuteResult {
        let newObject = SELF()
            newObject.domain      = domain
            newObject.frameDomain = frameDomain
            newObject.url         = url
            newObject.createdAt   = createdAt ?? Int64(Date.now)
        do {
            try Storage.context.save()
            _ = EntityVersions.versionIncrement(SELF.stringName)
                EntityVersions.dump()
            return .success(affected: 1)
        } catch {
            Storage.context.delete(newObject)
            Logger.customLog("Model \(SELF.stringName).insert() error: \(error).")
            return .failure
        }
    }

    static func delete(domain: DomainName, frameDomain: DomainName? = nil, url: String? = nil) -> ExecuteResult {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: SELF.stringName)
            request.predicate = {
                var result = [ NSPredicate(format: "domain == %@", domain) ]
                if let frameDomain { result.append(NSPredicate(format: "frameDomain == %@", frameDomain)) }
                if let url         { result.append(NSPredicate(format: "url == %@", url)) }
                return NSCompoundPredicate(
                    andPredicateWithSubpredicates: result
                )
            }()
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

    static func dump() {
        #if DEBUG
            let items = SELF.selectAll()
            if (!items.isEmpty) {

                let rows: [String] = items.reduce(into: []) { result, item in
                    let formattedDomain      = item.domain
                    let formattedFrameDomain = item.frameDomain
                    let formattedURL         = item.url
                    let formattedCreatedAt   = String(item.createdAt)
                    result.append(">> " +
                        "\(formattedDomain     .toWidth(30)) | " +
                        "\(formattedFrameDomain.toWidth(30)) | " +
                        "\(formattedCreatedAt  .toWidth(18)) | " +
                        "\(formattedURL        .toWidth(50))"
                    )
                }

                Logger.customLog("""

                Storage Dump for \"\(SELF.stringName)\":
                >> =================================================================================================
                >> domain                        |          frame domain        |    created at    |      url   
                >> =================================================================================================
                \(rows.joined(separator: "\n"))
                >> -------------------------------------------------------------------------------------------------

                """)
            } else {
                Logger.customLog("""

                Storage Dump for \"\(SELF.stringName)\":
                >> -------------------------------------------------------------------------------------------------
                >>                                          ... no data ...
                >> -------------------------------------------------------------------------------------------------

                """)
            }
        #endif
    }

}
