
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation
import CoreData

public class WhiteDomains: NSManagedObject {

    typealias SELF = WhiteDomains

    static let DB_LOCAL_NAME = "JSBlocker.sqlite"
    static let DB_LOCAL_TABLE_NAME = "WhiteDomains"

    @NSManaged var name: String
    @NSManaged var nameDecoded: String
    @NSManaged var isGlobal: Bool
    @NSManaged var expiredAt: Int64
    @NSManaged var createdAt: Int64
    @NSManaged var updatedAt: Int64

    static let storeURL: URL = {
        let storeDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: App.GROUP_NAME)!
        let storeURL = storeDirectory.appendingPathComponent(SELF.DB_LOCAL_NAME)
        return storeURL
    }()

    static let context: NSManagedObjectContext = {
        let description = NSPersistentStoreDescription(url: SELF.storeURL)
        let container = NSPersistentContainer(name: "Model")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container.viewContext
    }()

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
        return self.selectByName(name) != nil
    }

    static func selectAll(filter filterByName: String? = nil, orderBy: String = #keyPath(SELF.nameDecoded), ascending: Bool = true) -> [SELF] {
        let fetchRequest = NSFetchRequest<SELF>(entityName: SELF.DB_LOCAL_TABLE_NAME)
        if let filterByName = filterByName { fetchRequest.predicate = NSPredicate(format: "(name like[cd] %@) OR (nameDecoded like[cd] %@)", "*\(filterByName)*", filterByName) }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: orderBy, ascending: ascending)]
        return try! self.context.fetch(
            fetchRequest
        )
    }

    static func selectByName(_ name: String) -> SELF? {
        let fetchRequest = NSFetchRequest<SELF>(entityName: SELF.DB_LOCAL_TABLE_NAME)
        fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", name)
        let result = try! self.context.fetch(fetchRequest)
        return result.isEmpty ? nil : result.first
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
        let fetchRequest = NSFetchRequest<SELF>(entityName: SELF.DB_LOCAL_TABLE_NAME)
        if (withSelf == false) { fetchRequest.predicate = NSPredicate(format: "(name like[c] %@)"                   , "*?.\(name)", name) }
        if (withSelf != false) { fetchRequest.predicate = NSPredicate(format: "(name like[c] %@) OR (name ==[c] %@)", "*?.\(name)", name) }
        return try! self.context.fetch(
            fetchRequest
        )
    }

    static func selectGlobalDomains(_ name: String) -> [SELF] {
        let names = [name] + name.topDomains()
        let fetchRequest = NSFetchRequest<SELF>(entityName: SELF.DB_LOCAL_TABLE_NAME)
        fetchRequest.predicate = NSPredicate(
            format: "(name IN %@) AND (isGlobal == true)", names
        )
        return try! self.context.fetch(
            fetchRequest
        )
    }

    static func insert(name: String, isGlobal: Bool = false, expiredAt: Int64 = 0) {
        let domain = SELF()
            domain.name        = name
            domain.nameDecoded = name.decodePunycode()
            domain.isGlobal    = isGlobal
            domain.expiredAt   = expiredAt
            domain.createdAt   = Int64(Date().timeIntervalSince1970)
            domain.updatedAt   = Int64(Date().timeIntervalSince1970)
        try! SELF.context.save()
    }

    static func deleteByNames(names: [String]) {
        let fetchRequest = NSFetchRequest<SELF>(entityName: SELF.DB_LOCAL_TABLE_NAME)
        fetchRequest.predicate = NSPredicate(format: "(name IN %@)", names)
        fetchRequest.includesPropertyValues = false
        let items = try! self.context.fetch(
            fetchRequest
        )
        for item in items {
            item.delete()
        }
        return try! SELF.context.save()
    }

    func delete() {
        SELF.context.delete(self)
        try! SELF.context.save()
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



 /* ###################
    ### DEVELOPMENT ###
    ################### */

    #if DEBUG

    static func dump() {
        print("")
        print("DUMP \"White Domains\":")
        print(">> --------------------------------------------------------------------------")
        print(">> name                                                           | is global")
        print(">> ==========================================================================")

        let domains = SELF.selectAll()
        if (domains.isEmpty == false) {
            for domain in domains {
                let cellDomain   = domain.name.padding(toLength: 60, withPad: " ", startingAt: 0)
                let cellIsGlobal = domain.isGlobal
                print(">> - \(cellDomain) | \(cellIsGlobal)")
            }
        } else {
            print(">> no data")
        }

        print(">> --------------------------------------------------------------------------")
        print("")
    }

    static func seed(count: Int = 100) -> [String] {

        /* delete objects */
        for domain in SELF.selectAll() {
            domain.delete()
        }

        /* insert objects */
        var names = [
            "js-blocker",
            "js-blocker.com",
            "www.js-blocker.com",
            "sub1.js-blocker.com",
            "sub2.sub1.js-blocker.com",
            "sub3.sub2.sub1.js-blocker.com",
            "js-blocker.net",
        ]

        for i in 1 ... count-names.count {
            var domainParts: [String] = []
            for j in 1 ... Int.random(in: 1 ..< 10) {
                domainParts.append("sub\(j)")
            }
            domainParts.reverse()
            domainParts.append("domain-\(i).com")
            names.append(
                domainParts.joined(
                    separator: "."
                )
            )
        }

        for name in names {
            var isGlobal = Bool.random()
            if (name ==           "js-blocker.com") { isGlobal = true }
            if (name ==      "sub1.js-blocker.com") { isGlobal = true }
            if (name == "sub2.sub1.js-blocker.com") { isGlobal = true }
            SELF.insert(
                name    : name,
                isGlobal: isGlobal
            )
        }

        /* select objects */
        var result: [String] = []
        for domain in SELF.selectAll() {
            if (domain.isGlobal) { result.append("*\(domain.name)") }
            else                 { result.append( "\(domain.name)") }
        }
        return result

    }

    #endif

}
