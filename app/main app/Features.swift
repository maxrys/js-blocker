
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import AppKit
import SafariServices

protocol ExportImportItemProtocol {
    var name: DomainName { get }
    var type: String     { get }
    var expiresAt: Int64 { get }
}

public struct ExportImportItemV3: ExportImportItemProtocol, Codable {
    let name: DomainName
    let type: String
    let expiresAt: Int64
}

public struct ExportImportItemV2: ExportImportItemProtocol, Codable {
    let name: DomainName
    let isWildcard: Bool
    let expiresAt: Int64
    var type: String {
        self.isWildcard ? MATCH_TYPE_STRING_WILDCARD : MATCH_TYPE_STRING_EXACT
    }
}

public struct ExportImportItemV1: ExportImportItemProtocol, Codable {
    let name: DomainName
    let isGlobal: Bool
    let expiresAt: Int64
    var type: String {
        self.isGlobal ? MATCH_TYPE_STRING_WILDCARD : MATCH_TYPE_STRING_EXACT
    }
}

struct ExportImportItems<Item>: Codable where Item: ExportImportItemProtocol & Codable {

    var version: Double?

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

            let exportStruct = ExportImportItems<ExportImportItemV2>(
                items.reduce(into: [ExportImportItemV2]()) { result, item in
                    result.append(
                        ExportImportItemV2(
                            name      : item.name,
                            isWildcard: item.isWildcard,
                            expiresAt : item.expiresAt
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
                "\(APP_ID)-\(formattedDate).json"
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

            let JSONString = try String(
                contentsOf: fileURL,
                encoding: .utf8
            )

            /* MARK: Read and Parse JSON data | Import to database */

            var invalidDomains: [DomainName] = []
            var expiredDomains: [DomainName] = []
            var updateCount: Int = 0
            var insertCount: Int = 0

            let itemImporter: (ExportImportItemProtocol) -> Void = { item in
                if (item.name.isCanonical == false) {
                    invalidDomains.append(item.name)
                    Logger.customLog("INVALID ITEM: type = \(item.type) | name = \(item.name)")
                    return
                }
                if (item.expiresAt != 0 && item.expiresAt < Date.now.int64) {
                    expiredDomains.append(item.name)
                    Logger.customLog("EXPIRED ITEM: type = \(item.type) | name = \(item.name)")
                    return
                }
                if case .success(let affected) = AllowedDomains.delete([item.name]), affected > 0
                     { if case .success = AllowedDomains.insert(name: item.name, isWildcard: item.type == "wildcard" || item.type == "wildcardScript", expiresAt: item.expiresAt) { updateCount += 1; Logger.customLog("UPDATE ITEM: type = \(item.type) | name = \(item.name)") } else { invalidDomains.append(item.name); Logger.customLog("INVALID ITEM: type = \(item.type) | name = \(item.name)") } }
                else { if case .success = AllowedDomains.insert(name: item.name, isWildcard: item.type == "wildcard" || item.type == "wildcardScript", expiresAt: item.expiresAt) { insertCount += 1; Logger.customLog("INSERT ITEM: type = \(item.type) | name = \(item.name)") } else { invalidDomains.append(item.name); Logger.customLog("INVALID ITEM: type = \(item.type) | name = \(item.name)") } }
            }

            if      let importStruct = ExportImportItems<ExportImportItemV3>(decode: JSONString) { for item in importStruct.items { itemImporter(item); }}
            else if let importStruct = ExportImportItems<ExportImportItemV2>(decode: JSONString) { for item in importStruct.items { itemImporter(item); }}
            else if let importStruct = ExportImportItems<ExportImportItemV1>(decode: JSONString) { for item in importStruct.items { itemImporter(item); }}
            else {
                MessageBox.insert(
                    type: .error,
                    title: NSLocalizedString("Invalid JSON format!", comment: ""),
                    lifeTime: .time(3)
                )
                return
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
            if (!expiredDomains.isEmpty) {
                MessageBox.insert(
                    type: .warning,
                    title: String(format: NSLocalizedString("Expired domains were detected:\n%@", comment: ""), expiredDomains.joined(separator: " | ")),
                    isClosable: true,
                    lifeTime: .time(10)
                )
            }

            /* MARK: Reload Rules */

            if (updateCount > 0 || insertCount > 0) {
                SFSafariApplication.reloadRules()
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
