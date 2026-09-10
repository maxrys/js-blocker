
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import AppKit
import CoreData

enum ExecuteResult {
    case success(affected: Int)
    case failure
}

public class Storage {

    typealias SELF = Storage

    static let FILE_NAME = "\(APP_ID).sqlite"

    static let directoryURL: URL = {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: GROUP_NAME
        )!
    }()

    static let URL: URL = {
        SELF.directoryURL.appendingPathComponent(SELF.FILE_NAME)
    }()

    static let container: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.url = SELF.URL
        description.configuration = "Default"
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true

        var result = NSPersistentContainer(name: "Model")
        result.persistentStoreDescriptions = [description]
        result.viewContext.automaticallyMergesChangesFromParent = true
        result.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error as NSError? {
                let alert = NSAlert()
                alert.messageText = "The application will be force closed."
                alert.informativeText =
                    "Error: \(error.localizedDescription)\n\n" +
                    "You can:\n\n" +
                    "Revert to the previous version of the app\n\n" +
                    "or Try to transfer the data manually\n\n" +
                    "or Delete the conflicting storage at\n\(SELF.URL.path)\n" +
                    "!!! All app data will be lost !!!"
                alert.alertStyle = .critical
                alert.addButton(withTitle: "ОК")
                alert.runModal()
                NSApp.terminate(nil)
            } else {
                Logger.customLog("Storage path: \(SELF.URL.path)")
            }
        })
        return result
    }()

    static public var context: NSManagedObjectContext {
        SELF.container.viewContext
    }

}
