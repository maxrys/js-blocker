
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import AppKit

struct ExportImportItems: Codable {

    public struct Item: Codable {
        let name    : String
        let isGlobal: Bool /* isWildcard */
    }

    public private(set) var items: [Item] = []

    init(_ items: [Item]) {
        self.items = items
    }

    init?(decode json: String) {
        do {
            guard let data = json.data(using: .utf8) else {
                return nil
            }
            self = try JSONDecoder().decode(
                Self.self,
                from: data
            )
        } catch {
            return nil
        }
    }

    func encode() -> String? {
        let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
        guard let data = try? jsonEncoder.encode(self) else {
            return nil
        }
        return String(
            data: data,
            encoding: .utf8
        )
    }

}

final class Features {

    static public func export(items: ADFetchCollection) {
        do {

            let openPanel = NSOpenPanel()
            openPanel.allowsMultipleSelection = false
            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
            openPanel.canCreateDirectories = true
            openPanel.prompt = NSLocalizedString("Export", comment: "")

            guard openPanel.runModal() == .OK else {
                return
            }
            guard let directoryURL = openPanel.url else {
                return
            }

            /* MARK: Generate export JSON */

            let exportStruct = ExportImportItems(
                items.reduce(into: [ExportImportItems.Item]()) { result, item in
                    result.append(
                        ExportImportItems.Item(
                            name    : item.name,
                            isGlobal: item.isWildcard,
                        )
                    )
                }
            )

            guard let jsonData = exportStruct.encode() else {
                return
            }

            /* MARK: Generate export URL */

            let formattedDate = Date().formatCustom("yyyyMMdd-HHmmss")
            let exportFileURL = directoryURL.appendingPathComponent(
                "JSBlocker-\(formattedDate).json"
            )

            /* MARK: Write to file */

            try jsonData.write(
                to: exportFileURL,
                atomically: false,
                encoding: .utf8
            )

            /* MARK: Message */

            MessageBox.insert(
                type: .ok,
                title: String(format: NSLocalizedString("%d records have been exported", comment: ""), exportStruct.items.count),
                lifeTime: .time(3)
            )

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

            guard openPanel.runModal() == .OK else {
                return
            }
            guard let fileURL = openPanel.url else {
                return
            }

            /* MARK: Read and Parse JSON data */

            guard let importStruct = ExportImportItems(
                decode: try String(
                    contentsOf: fileURL,
                    encoding: .utf8
                )
            ) else {
                MessageBox.insert(
                    type: .error,
                    title: NSLocalizedString("Invalid JSON format!", comment: ""),
                    lifeTime: .time(3)
                )
                return
            }

            /* MARK: Import to database */

            var invalidDomains: [String] = []
            var updateCount: Int = 0
            var insertCount: Int = 0

            for item in importStruct.items {
                if (item.name.domainNameIsValid()) {
                    if case .success(let affected) = ADModel.delete([item.name]), affected > 0
                         { if (ADModel.insert(name: item.name, isWildcard: item.isGlobal)) { updateCount += 1; Logger.customLog("UPDATE ITEM: isWildcard = \(item.isGlobal) | name = \(item.name)") } else { invalidDomains.append(item.name); Logger.customLog("INVALID ITEM: isWildcard = \(item.isGlobal) | name = \(item.name)") } }
                    else { if (ADModel.insert(name: item.name, isWildcard: item.isGlobal)) { insertCount += 1; Logger.customLog("INSERT ITEM: isWildcard = \(item.isGlobal) | name = \(item.name)") } else { invalidDomains.append(item.name); Logger.customLog("INVALID ITEM: isWildcard = \(item.isGlobal) | name = \(item.name)") } }
                } else { invalidDomains.append(item.name); Logger.customLog("INVALID ITEM: isWildcard = \(item.isGlobal) | name = \(item.name)") }
            }

            /* MARK: Message */

            if (updateCount > 0) {
                MessageBox.insert(
                    type: .ok,
                    title: String(format: NSLocalizedString("%d existing records have been updated", comment: ""), updateCount),
                    lifeTime: .time(3)
                )
            }
            if (insertCount > 0) {
                MessageBox.insert(
                    type: .ok,
                    title: String(format: NSLocalizedString("%d new records have been added", comment: ""), insertCount),
                    lifeTime: .time(3)
                )
            }
            if (!invalidDomains.isEmpty) {
                MessageBox.insert(
                    type: .warning,
                    title: String(format: NSLocalizedString("Invalid domains were detected:\n%@", comment: ""), invalidDomains.joined(separator: " | ")),
                    isClosable: true,
                    lifeTime: .time(10)
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

}
