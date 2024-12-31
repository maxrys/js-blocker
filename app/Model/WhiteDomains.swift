
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import Foundation
import CoreData

public class WhiteDomains: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var nameDecoded: String
    @NSManaged var withSubdomains: Bool
    @NSManaged var skippedWww: Bool
    @NSManaged var expiredAt: Int64
    @NSManaged var createdAt: Int64
    @NSManaged var updatedAt: Int64

    static let storeURL: URL = {
        let storeDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ENV.APP_GROUP_NAME)!
        let storeURL = storeDirectory.appendingPathComponent(ENV.APP_DB_LOCAL_NAME)
        return storeURL
    }()

    static let context: NSManagedObjectContext = {
        let storeDescription = NSPersistentStoreDescription(url: WhiteDomains.storeURL)
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
        self.init(context: WhiteDomains.context)
    }

    static func hasDomain(name: String) -> Bool {
        return self.selectByName(name: name) != nil
    }

    static func selectAll(orderBy: String = #keyPath(WhiteDomains.nameDecoded), ascending: Bool = true) -> [WhiteDomains] {
        let fetchRequest = NSFetchRequest<WhiteDomains>(entityName: "WhiteDomains")
        let sortDescriptorKey = NSSortDescriptor(key: orderBy, ascending: ascending)
        fetchRequest.sortDescriptors = [sortDescriptorKey]
        return try! self.context.fetch(
            fetchRequest
        )
    }

    static func selectByName(name: String) -> WhiteDomains? {
        let fetchRequest = NSFetchRequest<WhiteDomains>(entityName: "WhiteDomains")
        fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", name)
        let result = try! self.context.fetch(fetchRequest)
        return !result.isEmpty ? result[0] : nil
    }

    static func selectChildren(name: String, withYourself: Bool = false) -> [WhiteDomains] {
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
        let fetchRequest = NSFetchRequest<WhiteDomains>(entityName: "WhiteDomains")
        if withYourself == false {fetchRequest.predicate = NSPredicate(format: "(name like[c] %@)"                   , "*?.\(name)", name)}
        if withYourself != false {fetchRequest.predicate = NSPredicate(format: "(name like[c] %@) OR (name ==[c] %@)", "*?.\(name)", name)}
        return try! self.context.fetch(
            fetchRequest
        )
    }

    static func selectParents(name: String, ignoreWithSubdomains: Bool = false) -> [WhiteDomains] {
        let nameParts = name.split(separator: ".")
        if (nameParts.count > 1) {
            var inItems: [String] = []
            for index in 1..<nameParts.endIndex {
                let cParent = nameParts[index...].joined(separator: ".");
                inItems.append(cParent)
            }
            let fetchRequest = NSFetchRequest<WhiteDomains>(entityName: "WhiteDomains")
            if ignoreWithSubdomains == true {fetchRequest.predicate = NSPredicate(format: "(name IN %@)"                             , inItems)}
            if ignoreWithSubdomains != true {fetchRequest.predicate = NSPredicate(format: "(name IN %@) AND (withSubdomains == true)", inItems)}
            return try! self.context.fetch(
                fetchRequest
            )
        } else {
            return []
        }
    }

    static func insert(name: String, withSubdomains: Bool = false, skippedWww: Bool = false, expiredAt: Int64 = 0) {
        let domain = WhiteDomains()
            domain.name           = name
            domain.nameDecoded    = name.decodePunycode()
            domain.withSubdomains = withSubdomains
            domain.skippedWww     = skippedWww
            domain.expiredAt      = expiredAt
            domain.createdAt      = Int64(Date().timeIntervalSince1970)
            domain.updatedAt      = Int64(Date().timeIntervalSince1970)
        try! WhiteDomains.context.save()
    }

    static func deleteByNames(names: [String]) {
        let fetchRequest = NSFetchRequest<WhiteDomains>(entityName: "WhiteDomains")
        fetchRequest.predicate = NSPredicate(format: "(name IN %@)", names)
        fetchRequest.includesPropertyValues = false
        let items = try! self.context.fetch(
            fetchRequest
        )
        for item in items {
            item.delete()
        }
        return try! WhiteDomains.context.save()
    }

    func delete() {
        WhiteDomains.context.delete(self)
        try! WhiteDomains.context.save()
    }

    static func hashSimpleCalculate(domains: [WhiteDomains]) -> Int {
        if !domains.isEmpty {
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

    static func blockingStateInfoGet(domainName: String) -> (BlockingState, WhiteDomains?) {
        if let domainInfo = WhiteDomains.selectByName(name: domainName) {
            if domainInfo.withSubdomains != true {return (state: .domain              , info: domainInfo)}
            if domainInfo.withSubdomains == true {return (state: .domainWithSubdomains, info: domainInfo)}
        } else if let domainInfo = WhiteDomains.selectByName(name: domainName.deleteWwwPrefixIfExists()) {
            if domainInfo.withSubdomains == true {
                return (state: .domainWithSubdomains, info: domainInfo)
            }
        }
        return (state: .nothing, info: nil)
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

        let domains = WhiteDomains.selectAll()
        if !domains.isEmpty {
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

        // delete objects
        for domain in WhiteDomains.selectAll() {
            domain.delete()
        }

        // insert objects
        var names = [
            "js-blocker",
            "js-blocker.com",
            "www.js-blocker.com",
            "sub1.js-blocker.com",
            "sub2.sub1.js-blocker.com",
            "sub3.sub2.sub1.js-blocker.com",
            "js-blocker.net",
        ]

        for i in 1...count-names.count {
            var domainParts: [String] = []
            for j in 1...Int.random(in: 1..<10) {
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
            if name ==           "js-blocker.com" {withSubdomains = true}
            if name ==      "sub1.js-blocker.com" {withSubdomains = true}
            if name == "sub2.sub1.js-blocker.com" {withSubdomains = true}
            WhiteDomains.insert(
                name          : name,
                withSubdomains: withSubdomains
            )
        }

        // select objects
        var result: [String] = []
        for domain in WhiteDomains.selectAll() {
            if domain.withSubdomains == true {result.append("*\(domain.name)")}
            else                             {result.append( "\(domain.name)")}
        }
        return result;

    }

    #endif

}
