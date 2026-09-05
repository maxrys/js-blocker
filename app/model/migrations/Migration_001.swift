
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import AppKit
import CoreData

public class Migration_001: NSManagedObject {

    typealias SELF = Migration_001

    static let stringName = "Migration_001"

    @NSManaged var isCompleted: Bool

    convenience init() {
        self.init(context: Storage.context)
    }

    static func selectIsCompleted() -> ExecuteResult {
        do {
            let request = NSFetchRequest<SELF>(entityName: SELF.stringName)
            request.fetchLimit = 1
            let result = try Storage.context.fetch(request)
            if (result.first?.isCompleted == true)
                 { return .success(affected: 1) }
            else { return .failure }
        } catch {
            Logger.customLog("Model \(SELF.stringName).selectIsCompleted() error: \(error).")
            return .failure
        }
    }

    static func insertIsCompleted() -> ExecuteResult {
        let newObject = SELF()
            newObject.isCompleted = true
        do {
            try Storage.context.save()
            return .success(affected: 1)
        } catch {
            Storage.context.delete(newObject)
            Logger.customLog("Model \(SELF.stringName).insertIsCompleted() error: \(error).")
            return .failure
        }
    }

}
