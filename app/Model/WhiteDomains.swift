
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
    @NSManaged var withSubdomains: Bool
    @NSManaged var skippedWww: Bool
    @NSManaged var expiredAt: Int64
    @NSManaged var createdAt: Int64
    @NSManaged var updatedAt: Int64

    static let storeURL: URL = {
        let storeDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: App.GROUP_NAME)!
        let storeURL = storeDirectory.appendingPathComponent(SELF.DB_LOCAL_NAME)
        return storeURL
    }()

    static let context: NSManagedObjectContext = {
        let storeDescription = NSPersistentStoreDescription(url: SELF.storeURL)
        let container = NSPersistentContainer(name: "Model")
        container.persistentStoreDescriptions = [storeDescription]
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

    static func hasDomain(name: String) -> Bool {
        return self.selectByName(name) != nil
    }

    static func selectAll(orderBy: String = #keyPath(SELF.nameDecoded), ascending: Bool = true) -> [SELF] {
        let fetchRequest = NSFetchRequest<SELF>(entityName: SELF.DB_LOCAL_TABLE_NAME)
        let sortDescriptorKey = NSSortDescriptor(key: orderBy, ascending: ascending)
        fetchRequest.sortDescriptors = [sortDescriptorKey]
        return try! self.context.fetch(
            fetchRequest
        )
    }

    static func selectByName(_ name: String) -> SELF? {
        let fetchRequest = NSFetchRequest<SELF>(entityName: SELF.DB_LOCAL_TABLE_NAME)
        fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", name)
        let result = try! self.context.fetch(fetchRequest)
        return !result.isEmpty ? result[0] : nil
    }

    static func selectChildren(name: String, withYourself: Bool = false) -> [SELF] {
        /*
        ### withYourself == false | WHERE (`ZNAME` like '%_.domain')
        ┌──────────────┬────────┐ ┌──────────────┬────────┐ ┌────────┬────────┐
        │ row          │ found  │ │ row          │ found  │ │ row    │ found  │
        ├──────────────┼────────┤ ├──────────────┼────────┤ ├────────┼────────┤
        │ "xyz.domain" │ YES    │ │ "xyz.doMain" │ YES    │ │ "main" │ IGNORE │
        │  "xy.domain" │ YES    │ │  "xy.doMain" │ YES    │ │ "Main" │ IGNORE │
        │   "x.domain" │ YES    │ │   "x.doMain" │ YES    │ └────────┴────────┘
        │    ".domain" │ IGNORE │ │    ".doMain" │ IGNORE │
        │     "domain" │ IGNORE │ │     "doMain" │ IGNORE │
        └──────────────┴────────┘ └──────────────┴────────┘
        ### withYourself != false | WHERE (`ZNAME` like '%_.domain') OR (`ZNAME` = 'domain' COLLATE NOCASE)
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
        if (withYourself == false) { fetchRequest.predicate = NSPredicate(format: "(name like[c] %@)"                   , "*?.\(name)", name) }
        if (withYourself != false) { fetchRequest.predicate = NSPredicate(format: "(name like[c] %@) OR (name ==[c] %@)", "*?.\(name)", name) }
        return try! self.context.fetch(
            fetchRequest
        )
    }

    static func selectParents(name: String, ignoreGlobal: Bool = false) -> [SELF] {
        let parents = name.domainNameParents()
        if (parents.isEmpty == false) {
            let fetchRequest = NSFetchRequest<SELF>(entityName: SELF.DB_LOCAL_TABLE_NAME)
            if (ignoreGlobal == true) { fetchRequest.predicate = NSPredicate(format: "(name IN %@)"                             , parents) }
            if (ignoreGlobal != true) { fetchRequest.predicate = NSPredicate(format: "(name IN %@) AND (withSubdomains == true)", parents) }
            return try! self.context.fetch(
                fetchRequest
            )
        } else {
            return []
        }
    }

    static func selectParentNames(name: String, ignoreGlobal: Bool = false) -> [String] {
        var result: [String] = []
        for parent in SELF.selectParents(name: name, ignoreGlobal: ignoreGlobal) {
            result.append(
                "*.\(parent.name)"
            )
        }
        return result
    }

    static func insert(name: String, withSubdomains: Bool = false, skippedWww: Bool = false, expiredAt: Int64 = 0) {
        let domain = SELF()
            domain.name           = name
            domain.nameDecoded    = name.decodePunycode()
            domain.withSubdomains = withSubdomains
            domain.skippedWww     = skippedWww
            domain.expiredAt      = expiredAt
            domain.createdAt      = Int64(Date().timeIntervalSince1970)
            domain.updatedAt      = Int64(Date().timeIntervalSince1970)
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

    static func hashSimpleCalculate(domains: [SELF]) -> Int {
        if (domains.isEmpty == false) {
            var hasher = Hasher()
            for domain in domains {
                hasher.combine(domain.name)
                hasher.combine(domain.nameDecoded)
                hasher.combine(domain.withSubdomains)
                hasher.combine(domain.skippedWww)
                hasher.combine(domain.expiredAt)
                hasher.combine(domain.createdAt)
                hasher.combine(domain.updatedAt)
            }
            return hasher.finalize();
        }
        return 0
    }

    static func blockingStateInfoGet(domainName: String) -> (BlockingType, SELF?) {
        if let domainInfo = SELF.selectByName(domainName) {
            if (domainInfo.withSubdomains != true) { return (state: .local , info: domainInfo) }
            if (domainInfo.withSubdomains == true) { return (state: .global, info: domainInfo) }
        } else if let domainInfo = SELF.selectByName(domainName.deleteWwwPrefixIfExists()) {
            if (domainInfo.withSubdomains == true) {
                return (state: .global, info: domainInfo)
            }
        }
        return (state: .none, info: nil)
    }



    /* ###################
       ### DEVELOPMENT ###
       ################### */

    #if DEBUG

    static func dump() {
        print("")
        print("DUMP \"White Domains\":")
        print(">> --------------------------------------------------------------------------------")
        print(">> name                                                           | with subdomains")
        print(">> ================================================================================")

        let domains = SELF.selectAll()
        if (domains.isEmpty == false) {
            for domain in domains {
                let cellDomain         = domain.name.padding(toLength: 60, withPad: " ", startingAt: 0)
                let cellWithSubdomains = domain.withSubdomains == true ? "1" : "0"
                print(">> - \(cellDomain) | \(cellWithSubdomains)")
            }
        } else {
            print(">> no data")
        }

        print(">> --------------------------------------------------------------------------------")
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
            var withSubdomains = Bool.random()
            if (name ==           "js-blocker.com") { withSubdomains = true }
            if (name ==      "sub1.js-blocker.com") { withSubdomains = true }
            if (name == "sub2.sub1.js-blocker.com") { withSubdomains = true }
            SELF.insert(
                name          : name,
                withSubdomains: withSubdomains
            )
        }

        /* select objects */
        var result: [String] = []
        for domain in SELF.selectAll() {
            if (domain.withSubdomains == true) { result.append("*\(domain.name)") }
            else                               { result.append( "\(domain.name)") }
        }
        return result;

    }

    #endif

}
