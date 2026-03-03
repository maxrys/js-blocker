
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import AppKit

final class Features {

    struct ExportImportItem: Codable {
        let name    : String
        let isGlobal: Bool /* isWildcard */
    }

    static public func export(items: ADFetchCollection) {
        do {

            let openPanel = NSOpenPanel()
            openPanel.allowsMultipleSelection = false
            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
            openPanel.canCreateDirectories = true
            openPanel.prompt = NSLocalizedString("Export", comment: "")

            if (openPanel.runModal() == .OK), let directoryURL = openPanel.url {

                /* MARK: Generate export JSON */

                var jsonObject: [ExportImportItem] = []
                for item in items {
                    jsonObject.append(
                        ExportImportItem(
                            name    : item.name,
                            isGlobal: item.isWildcard
                        )
                    )
                }

                let jsonEncoder = JSONEncoder()
                jsonEncoder.outputFormatting = .prettyPrinted

                let jsonData = try! jsonEncoder.encode(
                    jsonObject
                )

                /* MARK: Generate export URL */

                let formattedDate = Date().formatCustom("yyyyMMdd-HHmmss")
                let exportFileURL = directoryURL.appendingPathComponent(
                    "JSBlocker-\(formattedDate).json"
                )

                /* MARK: Write to file */

                try jsonData.stringUTF8!.write(
                    to: exportFileURL,
                    atomically: false,
                    encoding: .utf8
                )

                /* MARK: message */

                MessageBox.insert(
                    type: .ok,
                    title: String(format: NSLocalizedString("%d records have been exported", comment: ""), jsonObject.count),
                    lifeTime: .time(3)
                )

            }

        } catch {
            MessageBox.insert(
                type: .error,
                title: String("\(error)"),
                lifeTime: .time(3)
            )
        }
    }

    static public func `import`() {
        do {

            let openPanel = NSOpenPanel()
            openPanel.allowsMultipleSelection = false
            openPanel.canChooseFiles = true
            openPanel.canChooseDirectories = false
            openPanel.canCreateDirectories = false
            openPanel.allowedContentTypes = [.json]
            openPanel.prompt = NSLocalizedString("Import", comment: "")

            if (openPanel.runModal() == .OK), let fileURL = openPanel.url {

                let JSONString = try String(
                    contentsOf: fileURL,
                    encoding: .utf8
                )

                let JSONObject = try? JSONDecoder().decode(
                    [ExportImportItem].self,
                    from: JSONString.data(using: .utf8)!
                )

                if (JSONObject == nil) {
                    MessageBox.insert(
                        type: .error,
                        title: NSLocalizedString("Invalid JSON format!", comment: ""),
                        lifeTime: .time(3)
                    )
                    return
                }

                /* MARK: Import to database */

                var processed: Int = 0
                var invalidDomains: [String] = []
                if let items = JSONObject {
                    for item in items {
                        if (item.name.domainNameIsValid()) {
                            let _ = AllowedDomains.delete([item.name])
                            if (AllowedDomains.insert(name: item.name, isWildcard: item.isGlobal)) {
                                processed += 1
                                Logger.customLog("IMPORT ITEM: isWildcard = \(item.isGlobal) | name = \(item.name)")
                            } else { invalidDomains.append(item.name) }
                        }     else { invalidDomains.append(item.name) }
                    }
                }

                /* MARK: Message */

                MessageBox.insert(
                    type: .ok,
                    title: String(format: NSLocalizedString("%d records have been imported", comment: ""), processed),
                    lifeTime: .time(3)
                )
                if (!invalidDomains.isEmpty) {
                    MessageBox.insert(
                        type: .warning,
                        title: String(format: NSLocalizedString("Invalid domains were detected:\n%@", comment: ""), invalidDomains.joined(separator: " | ")),
                        isClosable: true,
                        lifeTime: .time(10)
                    )
                }

            }

        } catch {
            MessageBox.insert(
                type: .error,
                title: String("\(error)"),
                lifeTime: .time(3)
            )
        }
    }

}
