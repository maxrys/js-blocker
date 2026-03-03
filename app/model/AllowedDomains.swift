
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

typealias AllowedDomains = WhiteDomains; public class WhiteDomains: NSManagedObject {

    typealias SELF = WhiteDomains

    static let ENTITY_NAME = "WhiteDomains"

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

    static let storageURL: URL = {
        let storageDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GROUP_NAME)!
        let storageURL = storageDirectory.appendingPathComponent(STORAGE_NAME)
        return storageURL
    }()

    static var container: NSPersistentCloudKitContainer?

    static var context: NSManagedObjectContext {
        if (SELF.container == nil) { SELF.containerInit() }
        return SELF.container!.viewContext
    }

    static func fetchRequest() -> NSFetchRequest<SELF> {
        return NSFetchRequest<SELF>(entityName: SELF.ENTITY_NAME)
    }

    static func containerInit() {
        let description = NSPersistentStoreDescription()
        description.url = SELF.storageURL
        description.configuration = "CloudKit"
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        description.cloudKitContainerOptions = UserDefaultsState.icloudStatus_direct ? NSPersistentCloudKitContainerOptions(containerIdentifier: STORAGE_CLOUD_NAME) : nil
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true

        let container = NSPersistentCloudKitContainer(name: "Model")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error as NSError? {
                let alert = NSAlert()
                alert.messageText = "The application will be force closed."
                alert.informativeText = "The database schema is outdated.\n\nTo solve the problem please delete the directory manually:\n" + CONTAINER_PATH
                alert.alertStyle = .critical
                alert.addButton(withTitle: "ОК")
                alert.runModal()
                Logger.customLog("Error: \(error)")
                NSApp.terminate(nil)
            } else {
                let storagePath = SELF.storageURL.absoluteString.removingPercentEncoding!
                Logger.customLog("Model path = \"\(storagePath)\"")
                Logger.customLog("Model containerInit() | cloud = \(UserDefaultsState.icloudStatus_direct)")
            }
        })

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        SELF.container = container
    }

    convenience init() {
        self.init(context: SELF.context)
    }

    static func hasDomain(name: String) -> Bool {
        return SELF.select(name) != nil
    }

    static func selectAll(_ filterByName: String? = nil, orderBy: String = #keyPath(SELF.nameDecoded), ascending: Bool = true) -> ADFetchCollection {
        do {
            let fetchRequest = SELF.fetchRequest()
            if let filterByName = filterByName { fetchRequest.predicate = NSPredicate(format: "nameDecoded CONTAINS[cd] %@", filterByName, filterByName) }
            let orderByDefault = NSSortDescriptor(key: orderBy, ascending: ascending)
            let orderByUpdated = NSSortDescriptor(key: #keyPath(SELF.updatedAt), ascending: false)
            fetchRequest.sortDescriptors = [orderByDefault, orderByUpdated]
            let items = try SELF.context.fetch(fetchRequest)
            var result: ADFetchCollection = []
            items.forEach { item in
                result.appendUnique(item)
            }
            return result
        } catch {
            Logger.customLog("Model Self.selectAll() error: \(error).")
        }
        return []
    }

    static func select(_ name: String) -> SELF? {
        do {
            let orderByUpdated = NSSortDescriptor(key: #keyPath(SELF.updatedAt), ascending: false)
            let fetchRequest = SELF.fetchRequest()
            fetchRequest.sortDescriptors = [orderByUpdated]
            fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", name)
            let result = try SELF.context.fetch(fetchRequest)
            return result.isEmpty ? nil : result.first
        } catch {
            Logger.customLog("Model Self.select() error: \(error).")
        }
        return nil
    }

    static func selectWildcardDomains(_ name: String) -> ADFetchCollection {
        do {
            let orderByUpdated = NSSortDescriptor(key: #keyPath(SELF.updatedAt), ascending: false)
            let names = [name] + name.topDomains()
            let fetchRequest = SELF.fetchRequest()
            fetchRequest.sortDescriptors = [orderByUpdated]
            fetchRequest.predicate = NSPredicate(format: "(name IN %@) AND (isGlobal == true)", names)
            let items = try SELF.context.fetch(fetchRequest)
            var result: ADFetchCollection = []
            items.forEach { item in
                result.appendUnique(item)
            }
            return result
        } catch {
            Logger.customLog("Model Self.selectWildcardDomains() error: \(error).")
        }
        return []
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
            try SELF.context.save()
            return true
        } catch {
            Logger.customLog("Model Self.insert() error: \(error).")
        }
        return false
    }

    static func delete(_ names: [String]) -> Bool {
        do {
            let fetchRequest = SELF.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "(name IN %@)", names)
            fetchRequest.includesPropertyValues = false
            let items = try SELF.context.fetch(fetchRequest)
            items.forEach { item in
                let _ = SELF.context.delete(item)
            }
            try SELF.context.save()
            return true
        } catch {
            Logger.customLog("Model Self.delete() error: \(error).")
        }
        return false
    }

    static func matchType(name: String) -> MatchType {
        if let domainInfo = SELF.select(name) {
            if (domainInfo.isWildcard != true) { return .exact }
            if (domainInfo.isWildcard == true) { return .wildcard }
        }
        if SELF.selectWildcardDomains(name).count > 0 {
            return .wildcard
        }
        return .none
    }

    static func dump() {
        #if DEBUG
        var renderedRows: [String] = []
        SELF.selectAll().forEach { object in
            let name = object.name.padding(toLength: 60, withPad: " ", startingAt: 0)
            let isWildcardText = object.isWildcard ? "yes" : "no"
            renderedRows.append(">> - \(name) | \(isWildcardText)")
        }
        if (renderedRows.isEmpty) {
            renderedRows.append(
                ">>" + String(repeating: " ", count: 30) + "... no data ..."
            )
        }
        Logger.customLog("""
        
        Model Dump for \"\(SELF.ENTITY_NAME)\":
        >> ---------------------------------------------------------------------------
        >> name                                                           | isWildcard
        >> ===========================================================================
        \(renderedRows.joined(separator: "\n"))
        >> ---------------------------------------------------------------------------
        
        """)
        #endif
    }

}
