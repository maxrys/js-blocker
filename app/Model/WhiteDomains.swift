
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation
import CoreData

public class WhiteDomains: NSManagedObject {

    typealias SELF = WhiteDomains

    static let ENTITY_NAME = "WhiteDomains"

    @NSManaged var name: String
    @NSManaged var nameDecoded: String
    @NSManaged var isGlobal: Bool
    @NSManaged var expiredAt: Int64
    @NSManaged var createdAt: Int64
    @NSManaged var updatedAt: Int64

    static let storeURL: URL = {
        let storeDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: App.GROUP_NAME)!
        let storeURL = storeDirectory.appendingPathComponent(App.STORAGE_NAME)
        return storeURL
    }()

    static var container: NSPersistentCloudKitContainer?

    static var context: NSManagedObjectContext {
        if (SELF.container == nil) { SELF.containerInit() }
        return SELF.container!.viewContext
    }

    static func containerInit() {
        let description = NSPersistentStoreDescription()
            description.url = SELF.storeURL
            description.configuration = "CloudKit"
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            description.cloudKitContainerOptions = App.isCloudEnabled ? NSPersistentCloudKitContainerOptions(containerIdentifier: App.STORAGE_CLOUD_NAME) : nil
            description.shouldInferMappingModelAutomatically = true
            description.shouldMigrateStoreAutomatically = true
        let container = NSPersistentCloudKitContainer(name: "Model")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("LoadPersistentStores() error \(error), \(error.userInfo)")
            } else {
                #if DEBUG
                    print("DB containerInit() | cloud = \(App.isCloudEnabled)")
                #endif
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

    static func selectAll(filter filterByName: String? = nil, orderBy: String = #keyPath(SELF.nameDecoded), ascending: Bool = true) -> [SELF] {
        do {
            let fetchRequest = NSFetchRequest<SELF>(entityName: SELF.ENTITY_NAME)
            if let filterByName = filterByName { fetchRequest.predicate = NSPredicate(format: "(name like[cd] %@) OR (nameDecoded like[cd] %@)", "*\(filterByName)*", filterByName) }
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: orderBy, ascending: ascending)]
            return try SELF.context.fetch(fetchRequest)
        } catch {
            print("DB selectAll() error: \(error).")
        }
        return []
    }

    static func selectByName(_ name: String) -> SELF? {
        do {
            let fetchRequest = NSFetchRequest<SELF>(entityName: SELF.ENTITY_NAME)
            fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", name)
            let result = try SELF.context.fetch(fetchRequest)
            return result.isEmpty ? nil : result.first
        } catch {
            print("DB selectByName() error: \(error).")
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
            let fetchRequest = NSFetchRequest<SELF>(entityName: SELF.ENTITY_NAME)
            if (withSelf == false) { fetchRequest.predicate = NSPredicate(format: "(name like[c] %@)"                   , "*?.\(name)", name) }
            if (withSelf != false) { fetchRequest.predicate = NSPredicate(format: "(name like[c] %@) OR (name ==[c] %@)", "*?.\(name)", name) }
            return try SELF.context.fetch(fetchRequest)
        } catch {
            print("DB selectSubDomains() error: \(error).")
        }
        return []
    }

    static func selectGlobalDomains(_ name: String) -> [SELF] {
        do {
            let names = [name] + name.topDomains()
            let fetchRequest = NSFetchRequest<SELF>(entityName: SELF.ENTITY_NAME)
            fetchRequest.predicate = NSPredicate(
                format: "(name IN %@) AND (isGlobal == true)", names
            )
            return try SELF.context.fetch(fetchRequest)
        } catch {
            print("DB selectGlobalDomains() error: \(error).")
        }
        return []
    }

    static func insert(name: String, isGlobal: Bool = false, expiredAt: Int64 = 0) -> Bool {
        do {
            let domain = SELF()
                domain.name        = name
                domain.nameDecoded = name.decodePunycode()
                domain.isGlobal    = isGlobal
                domain.expiredAt   = expiredAt
                domain.createdAt   = Int64(Date().timeIntervalSince1970)
                domain.updatedAt   = Int64(Date().timeIntervalSince1970)
            try SELF.context.save()
            return true
        } catch {
            print("DB insert() error: \(error).")
        }
        return false
    }

    static func deleteByNames(names: [String]) -> Bool {
        do {
            let fetchRequest = NSFetchRequest<SELF>(entityName: SELF.ENTITY_NAME)
            fetchRequest.predicate = NSPredicate(format: "(name IN %@)", names)
            fetchRequest.includesPropertyValues = false
            let items = try SELF.context.fetch(fetchRequest)
            items.forEach { item in
                let _ = item.delete()
            }
            try SELF.context.save()
            return true
        } catch {
            print("DB deleteByNames() error: \(error).")
        }
        return false
    }

    func delete() -> Bool {
        do {
            SELF.context.delete(self)
            try SELF.context.save()
            return true
        } catch {
            print("DB delete() error: \(error).")
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

    #if DEBUG

    static func dump() {
        var renderedRows: [String] = []
        SELF.selectAll().forEach { domain in
            let name = domain.name.padding(toLength: 60, withPad: " ", startingAt: 0)
            renderedRows.append(">> - \(name) | \(domain.isGlobal)")
        }
        if (renderedRows.isEmpty) {
            renderedRows.append(
                ">>" + String(repeating: " ", count: 30) + "... no data ..."
            )
        }
        print("""
        
        DB Dump for \"\(SELF.ENTITY_NAME)\":
        >> --------------------------------------------------------------------------
        >> name                                                           | is global
        >> ==========================================================================
        \(renderedRows.joined(separator: "\n"))
        >> --------------------------------------------------------------------------
        
        """)
    }

    #endif

}
