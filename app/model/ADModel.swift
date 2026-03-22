
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

/*
    CloudKit debug:
        log stream --info --debug --predicate 'process = "cloudd" and message contains[cd] "containerID=iCloud.jsblocker"'
        log stream --info --debug --predicate 'process = "JS Blocker" and (subsystem = "com.apple.coredata" or subsystem = "com.apple.cloudkit")'
*/

import os
import AppKit
import CoreData

enum ExecuteResult {
    case success(affected: Int)
    case failure
}

typealias ADModel = WhiteDomains; public class WhiteDomains: NSManagedObject {

    typealias SELF = WhiteDomains

    @NSManaged var name: String
    @NSManaged var nameDecoded: String
    @NSManaged var isGlobal: Bool
    @NSManaged var expiredAt: Int64
    @NSManaged var createdAt: Int64
    @NSManaged var updatedAt: Int64
    var isWildcard: Bool {
        get { self.isGlobal }
        set { self.isGlobal = newValue }
    }

    static let storageDirectoryURL: URL = {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: GROUP_NAME
        )!
    }()

    static let storageURL: URL = {
        storageDirectoryURL.appendingPathComponent(STORAGE_NAME)
    }()

    static var container: NSPersistentCloudKitContainer!

    static var context: NSManagedObjectContext {
        if (Self.container == nil) { Self.containerInit() }
        return Self.container.viewContext
    }

    static func fetchRequest() -> NSFetchRequest<SELF> {
        return NSFetchRequest<SELF>(entityName: "WhiteDomains")
    }

    convenience init() {
        self.init(context: Self.context)
    }

    static func containerInit() {
        let description = NSPersistentStoreDescription()
        description.url = Self.storageURL
        description.configuration = "CloudKit"
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        description.cloudKitContainerOptions = UserDefaultsState.icloudStatus_direct ? NSPersistentCloudKitContainerOptions(containerIdentifier: STORAGE_CLOUD_NAME) : nil
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true

        Self.container = NSPersistentCloudKitContainer(name: "Model")
        Self.container.persistentStoreDescriptions = [description]
        Self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        Self.container.viewContext.automaticallyMergesChangesFromParent = true
        Self.container.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error as NSError? {
                let alert = NSAlert()
                alert.messageText = "The application will be force closed."
                alert.informativeText =
                    "Error: \(error.localizedDescription)\n\n" +
                    "You can:\n\n" +
                    "Revert to the previous version of the app\n\n" +
                    "or Try to transfer the data manually\n\n" +
                    "or Delete the conflicting storage at\n\(Self.storageURL.path)\n" +
                    "!!! All app data will be lost !!!"
                alert.alertStyle = .critical
                alert.addButton(withTitle: "ОК")
                alert.runModal()
                NSApp.terminate(nil)
            } else {
                Logger.customLog("Storage path = \"\(Self.storageURL.path)\"")
                Logger.customLog("Model ADModel.containerInit() | cloud = \(UserDefaultsState.icloudStatus_direct)")
            }
        })
    }

    static func hasDomain(name: String) -> Bool {
        return Self.select(name) != nil
    }

    static func select(_ name: String) -> SELF? {
        do {
            let orderByUpdated = NSSortDescriptor(key: #keyPath(SELF.updatedAt), ascending: false)
            let fetchRequest = Self.fetchRequest()
            fetchRequest.sortDescriptors = [orderByUpdated]
            fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", name)
            let result = try Self.context.fetch(fetchRequest)
            return result.isEmpty ? nil : result.first
        } catch {
            Logger.customLog("Model ADModel.select() error: \(error).")
            return nil
        }
    }

    static func selectAll(_ filterByName: String? = nil, orderBy: String = #keyPath(SELF.nameDecoded), ascending: Bool = true) -> ADFetchCollection {
        do {
            let fetchRequest = Self.fetchRequest()
            if let filterByName = filterByName { fetchRequest.predicate = NSPredicate(format: "nameDecoded CONTAINS[cd] %@", filterByName, filterByName) }
            let orderByDefault = NSSortDescriptor(key: orderBy, ascending: ascending)
            let orderByUpdated = NSSortDescriptor(key: #keyPath(SELF.updatedAt), ascending: false)
            fetchRequest.sortDescriptors = [orderByDefault, orderByUpdated]
            return try Self.context.fetch(fetchRequest).reduce(into: ADFetchCollection()) { result, modelItem in
                result.appendUnique(modelItem)
            }
        } catch {
            Logger.customLog("Model ADModel.selectAll() error: \(error).")
            return []
        }
    }

    static func selectWildcardDomains(_ name: String) -> ADFetchCollection {
        do {
            let orderByUpdated = NSSortDescriptor(key: #keyPath(SELF.updatedAt), ascending: false)
            let names = [name] + name.topDomains()
            let fetchRequest = Self.fetchRequest()
            fetchRequest.sortDescriptors = [orderByUpdated]
            fetchRequest.predicate = NSPredicate(format: "(name IN %@) AND (isGlobal == true)", names)
            return try Self.context.fetch(fetchRequest).reduce(into: ADFetchCollection()) { result, modelItem in
                result.appendUnique(modelItem)
            }
        } catch {
            Logger.customLog("Model ADModel.selectWildcardDomains() error: \(error).")
            return []
        }
    }

    static func insert(name: String, isWildcard: Bool = false, expiredAt: Int64 = 0) -> Bool {
        do {
            let newObject = SELF()
                newObject.name        = name
                newObject.nameDecoded = name.decodePunycode()
                newObject.isWildcard  = isWildcard
                newObject.expiredAt   = expiredAt
                newObject.createdAt   = Int64(Date().timeIntervalSince1970)
                newObject.updatedAt   = Int64(Date().timeIntervalSince1970)
            try Self.context.save()
            return true
        } catch {
            Logger.customLog("Model ADModel.insert() error: \(error).")
            return false
        }
    }

    static func delete(_ names: [String]) -> ExecuteResult {
        do {
            let fetchRequest = Self.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name IN %@", names)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            deleteRequest.resultType = .resultTypeCount
            let result = try Self.context.execute(deleteRequest) as? NSBatchDeleteResult
            let affected = result?.result as? Int ?? 0
            try Self.context.save()
            return .success(affected: affected)
        } catch {
            Logger.customLog("Model ADModel.delete() error: \(error).")
            return .failure
        }
    }

    static func matchType(name: String) -> MatchType {
        if let domainInfo = Self.select(name) {
            if (domainInfo.isWildcard != true) { return .exact }
            if (domainInfo.isWildcard == true) { return .wildcard }
        }
        if Self.selectWildcardDomains(name).count > 0 {
            return .wildcard
        }
        return .none
    }

    static func dump() {
        #if DEBUG
            let items = Self.selectAll()
            if (!items.isEmpty) {

                let rows: [String] = items.reduce(into: []) { result, item in
                    let formattedName = item.name.padding(toLength: 60, withPad: " ", startingAt: 0)
                    let formattedIsWildcard = item.isWildcard ? "yes" : "no"
                    result.append(">> - \(formattedName) | \(formattedIsWildcard)")
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
