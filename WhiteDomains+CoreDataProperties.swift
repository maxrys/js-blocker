
import Foundation
import CoreData

extension WhiteDomains {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WhiteDomains> {
        return NSFetchRequest<WhiteDomains>(entityName: "WhiteDomains")
    }

    @NSManaged public var name: String
    @NSManaged public var nameDecoded: String
    @NSManaged public var withSubdomains: Bool
    @NSManaged public var skippedWww: Bool
    @NSManaged public var expiredAt: Int64
    @NSManaged public var createdAt: Int64
    @NSManaged public var updatedAt: Int64

}

extension WhiteDomains : Identifiable {

}
