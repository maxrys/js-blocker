
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import AppKit
import CoreData

/*
    CloudKit debug:
        log stream --info --debug --predicate 'process = "cloudd" and message contains[cd] "containerID=iCloud.jsblocker"'
        log stream --info --debug --predicate 'process = "JS Blocker" and (subsystem = "com.apple.coredata" or subsystem = "com.apple.cloudkit")'
*/

public class WhiteDomains: NSManagedObject {

    typealias SELF = WhiteDomains

    static let ENTITY_NAME = "WhiteDomains"

    @NSManaged var name: String
    @NSManaged var nameDecoded: String
    @NSManaged var isGlobal: Bool
    @NSManaged var expiredAt: Int64
    @NSManaged var createdAt: Int64
    @NSManaged var updatedAt: Int64

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

    static func containerInit() {
        let description = NSPersistentStoreDescription()
        description.url = SELF.storageURL
        description.configuration = "CloudKit"
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        description.cloudKitContainerOptions = UserDefaultsState.icloudStatusDirect ? NSPersistentCloudKitContainerOptions(containerIdentifier: STORAGE_CLOUD_NAME) : nil
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
                Logger.customLog("Model containerInit() | cloud = \(UserDefaultsState.icloudStatusDirect)")
            }
        })

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        SELF.container = container
    }

    convenience init() {
        self.init(context: SELF.context)
    }

    static func hashOfSet(_ domains: [SELF]) -> Int {
        if (domains.isEmpty == false) {
            var hasher = Hasher()
            for domain in domains {
                hasher.combine(domain.name)
                hasher.combine(domain.nameDecoded)
                hasher.combine(domain.isGlobal)
                hasher.combine(domain.expiredAt)
                hasher.combine(domain.createdAt)
                hasher.combine(domain.updatedAt) }
            return hasher.finalize()
        }
        return 0
    }

    static func hasDomain(name: String) -> Bool {
        return SELF.selectByName(name) != nil
    }

    static func fetchRequest() -> NSFetchRequest<SELF> {
        return NSFetchRequest<SELF>(entityName: SELF.ENTITY_NAME)
    }

    static func selectAll(_ filterByName: String? = nil, orderBy: String = #keyPath(SELF.nameDecoded), ascending: Bool = true) -> [SELF] {
        do {
            let fetchRequest = SELF.fetchRequest()
            if let filterByName { fetchRequest.predicate = NSPredicate(format: "nameDecoded CONTAINS[cd] %@", filterByName, filterByName) }
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: orderBy, ascending: ascending) ]
            return try SELF.context.fetch(fetchRequest)
        } catch {
            Logger.customLog("Model selectAll() error: \(error).")
        }
        return []
    }

    static func selectByName(_ name: String) -> SELF? {
        do {
            let fetchRequest = SELF.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", name)
            let result = try SELF.context.fetch(fetchRequest)
            return result.isEmpty ? nil : result.first
        } catch {
            Logger.customLog("Model selectByName() error: \(error).")
        }
        return nil
    }

    static func selectSubDomains(name: String, withSelf: Bool = false) -> [SELF] {
        /*
        ### withSelf == false | WHERE (`ZNAME` like '%_.domain')
        ┌──────────────┬────────┐ ┌──────────────┬────────┐ ┌────────┬────────┐
        │ row          │ found  │ │ row          │ found  │ │ row    │ found  │
        ├──────────────┼────────┤ ├──────────────┼────────┤ ├────────┼────────┤
        │ "xyz.domain" │ YES    │ │ "xyz.doMain" │ YES    │ │ "main" │ IGNORE │
        │  "xy.domain" │ YES    │ │  "xy.doMain" │ YES    │ │ "Main" │ IGNORE │
        │   "x.domain" │ YES    │ │   "x.doMain" │ YES    │ └────────┴────────┘
        │    ".domain" │ IGNORE │ │    ".doMain" │ IGNORE │
        │     "domain" │ IGNORE │ │     "doMain" │ IGNORE │
        └──────────────┴────────┘ └──────────────┴────────┘
        ### withSelf != false | WHERE (`ZNAME` like '%_.domain') OR (`ZNAME` = 'domain' COLLATE NOCASE)
        ┌──────────────┬────────┐ ┌──────────────┬────────┐ ┌────────┬────────┐
        │ row          │ found  │ │ row          │ found  │ │ row    │ found  │
        ├──────────────┼────────┤ ├──────────────┼────────┤ ├────────┼────────┤
        │ "xyz.domain" │ YES    │ │ "xyz.doMain" │ YES    │ │ "main" │ IGNORE │
        │  "xy.domain" │ YES    │ │  "xy.doMain" │ YES    │ │ "Main" │ IGNORE │
        │   "x.domain" │ YES    │ │   "x.doMain" │ YES    │ └────────┴────────┘
        │    ".domain" │ IGNORE │ │    ".doMain" │ IGNORE │
        │     "domain" │ YES    │ │     "doMain" │ YES    │
        └──────────────┴────────┘ └──────────────┴────────┘
        */
        do {
            let fetchRequest = SELF.fetchRequest()
            if (withSelf == false) { fetchRequest.predicate = NSPredicate(format: "(name like[c] %@)"                   , "*?.\(name)", name) }
            if (withSelf != false) { fetchRequest.predicate = NSPredicate(format: "(name like[c] %@) OR (name ==[c] %@)", "*?.\(name)", name) }
            return try SELF.context.fetch(fetchRequest)
        } catch {
            Logger.customLog("Model selectSubDomains() error: \(error).")
        }
        return []
    }

    static func selectGlobalDomains(_ name: String) -> [SELF] {
        do {
            let names = [name] + name.topDomains()
            let fetchRequest = SELF.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "(name IN %@) AND (isGlobal == true)", names
            )
            return try SELF.context.fetch(fetchRequest)
        } catch {
            Logger.customLog("Model selectGlobalDomains() error: \(error).")
        }
        return []
    }

    static func insert(name: String, isGlobal: Bool = false, expiredAt: Int64 = 0) -> Bool {
        do {
            let newObject = SELF()
                newObject.name        = name
                newObject.nameDecoded = name.decodePunycode()
                newObject.isGlobal    = isGlobal
                newObject.expiredAt   = expiredAt
                newObject.createdAt   = Int64(Date().timeIntervalSince1970)
                newObject.updatedAt   = Int64(Date().timeIntervalSince1970)
            try SELF.context.save()
            return true
        } catch {
            Logger.customLog("Model insert() error: \(error).")
        }
        return false
    }

    static func deleteByNames(names: [String]) -> Bool {
        do {
            let fetchRequest = SELF.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "(name IN %@)", names)
            fetchRequest.includesPropertyValues = false
            let items = try SELF.context.fetch(fetchRequest)
            items.forEach { item in
                let _ = item.delete()
            }
            try SELF.context.save()
            return true
        } catch {
            Logger.customLog("Model deleteByNames() error: \(error).")
        }
        return false
    }

    func delete() -> Bool {
        do {
            SELF.context.delete(self)
            try SELF.context.save()
            return true
        } catch {
            Logger.customLog("Model delete() error: \(error).")
        }
        return false
    }

    static func blockingState(name: String) -> BlockingType {
        if let domainInfo = SELF.selectByName(name) {
            if (domainInfo.isGlobal != true) { return .local  }
            if (domainInfo.isGlobal == true) { return .global }
        }
        if SELF.selectGlobalDomains(name).count > 0 {
            return .global
        }
        return .none
    }

    static func dump() {
        #if DEBUG
        var renderedRows: [String] = []
        SELF.selectAll().forEach { object in
            let name = object.name.padding(toLength: 60, withPad: " ", startingAt: 0)
            let isGlobal = object.isGlobal ? "yes" : "no"
            renderedRows.append(">> - \(name) | \(isGlobal)")
        }
        if (renderedRows.isEmpty) {
            renderedRows.append(
                ">>" + String(repeating: " ", count: 30) + "... no data ..."
            )
        }
        Logger.customLog("""
        
        Model Dump for \"\(SELF.ENTITY_NAME)\":
        >> --------------------------------------------------------------------------
        >> name                                                           | is global
        >> ==========================================================================
        \(renderedRows.joined(separator: "\n"))
        >> --------------------------------------------------------------------------
        
        """)
        #endif
    }

}
