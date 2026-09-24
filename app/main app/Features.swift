
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
    var scripts: [FrameDomainName: [URLString]]? { get }
}

public struct ExportImportItemV3: ExportImportItemProtocol, Codable {
    let name: DomainName
    let type: String
    let expiresAt: Int64
    var scripts: [FrameDomainName: [URLString]]?
}

public struct ExportImportItemV2: ExportImportItemProtocol, Codable {
    let name: DomainName
    let isWildcard: Bool
    let expiresAt: Int64
    var scripts: [FrameDomainName: [URLString]]? = nil
    var type: String {
        self.isWildcard ? MATCH_TYPE_STRING_WILDCARD : MATCH_TYPE_STRING_EXACT
    }
}

public struct ExportImportItemV1: ExportImportItemProtocol, Codable {
    let name: DomainName
    let isGlobal: Bool
    let expiresAt: Int64
    var scripts: [FrameDomainName: [URLString]]? = nil
    var type: String {
        self.isGlobal ? MATCH_TYPE_STRING_WILDCARD : MATCH_TYPE_STRING_EXACT
    }
}

struct ExportImportItems<Item>: Codable where Item: ExportImportItemProtocol & Codable {

    var version: Double? = 3.0

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

            let exportStruct = ExportImportItems<ExportImportItemV3>(
                items.reduce(into: [ExportImportItemV3]()) { result, item in
                    switch item.type {
                        case MATCH_TYPE_STRING_EXACT, MATCH_TYPE_STRING_WILDCARD:
                            result.append(
                                ExportImportItemV3(
                                    name     : item.name,
                                    type     : item.type,
                                    expiresAt: item.expiresAt,
                                )
                            )
                        case MATCH_TYPE_STRING_EXACT_SCRIPT, MATCH_TYPE_STRING_WILDCARD_SCRIPT:
                            let scripts = AllowedScripts.selectByDomain(domain: item.name).reduce(
                                into: [FrameDomainName: [URLString]](), { result, item in
                                    result[item.frameDomain, default: []].append(item.url)
                                }
                            )
                            result.append(
                                ExportImportItemV3(
                                    name     : item.name,
                                    type     : item.type,
                                    expiresAt: item.expiresAt,
                                    scripts  : scripts
                                )
                            )
                        default: break
                    }
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

            MessageBox.insert(address: ThisApp.messageBoxAddress, .init(
                ID: ThisApp.messageIDForCurrentOperation,
                type: .ok,
                title: String(format: NSLocalizedString("%d records have been exported", comment: ""), exportStruct.items.count)
            ))

        } catch {
            MessageBox.insert(address: ThisApp.messageBoxAddress, .init(
                ID: ThisApp.messageIDForCurrentOperation,
                type: .error,
                title: String("\(error)")
            ))
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
                    Logger.customLog("Import | INVALID DOMAIN: name = \(item.name) | type = \(item.type)")
                    return
                }
                if (item.expiresAt != 0 && item.expiresAt < Date.timestamp.int64) {
                    expiredDomains.append(item.name)
                    Logger.customLog("Import | EXPIRED DOMAIN: name = \(item.name) | type = \(item.type)")
                    return
                }
                let deleteResult = AllowedDomains.delete(
                    [item.name]
                )
                let insertResult = AllowedDomains.insert(
                    name: item.name,
                    type: item.type,
                    expiresAt: item.expiresAt
                )

                /* report */
                if case .success(let affected) = deleteResult, affected > 0
                     { if case .success = insertResult { updateCount += 1; Logger.customLog("Import | UPDATE DOMAIN | success: name = \(item.name) | type = \(item.type)") } else { invalidDomains.append(item.name); Logger.customLog("Import | UPDATE DOMAIN | FAILURE: name = \(item.name) | type = \(item.type)") } }
                else { if case .success = insertResult { insertCount += 1; Logger.customLog("Import | INSERT DOMAIN | success: name = \(item.name) | type = \(item.type)") } else { invalidDomains.append(item.name); Logger.customLog("Import | INSERT DOMAIN | FAILURE: name = \(item.name) | type = \(item.type)") } }

                /* import scripts */
                if (item.type == MATCH_TYPE_STRING_EXACT_SCRIPT ||
                    item.type == MATCH_TYPE_STRING_WILDCARD_SCRIPT) {
                    _ = AllowedScripts.delete(domain: item.name)
                    item.scripts?.forEach { (frameDomain: FrameDomainName, urls: [URLString]) in
                        urls.forEach { url in
                            let insertScriptResult = AllowedScripts.insert(
                                domain: item.name,
                                frameDomain: frameDomain,
                                url: url
                            )
                            /* report */
                            if case .success = insertScriptResult
                                 { Logger.customLog("Import | INSERT SCRIPT | success: domain = \(item.name) | frameDomain = \(frameDomain) | url = \(url)") }
                            else { Logger.customLog("Import | INSERT SCRIPT | FAILURE: domain = \(item.name) | frameDomain = \(frameDomain) | url = \(url)") }
                        }
                    }
                }
            }

            if      let importStruct = ExportImportItems<ExportImportItemV3>(decode: JSONString) { Logger.customLog("Import start: version = \(importStruct.version, default: NOT_APPLICABLE)"); for item in importStruct.items { itemImporter(item) }}
            else if let importStruct = ExportImportItems<ExportImportItemV2>(decode: JSONString) { Logger.customLog("Import start: version = \(importStruct.version, default: NOT_APPLICABLE)"); for item in importStruct.items { itemImporter(item) }}
            else if let importStruct = ExportImportItems<ExportImportItemV1>(decode: JSONString) { Logger.customLog("Import start: version = \(importStruct.version, default: NOT_APPLICABLE)"); for item in importStruct.items { itemImporter(item) }}
            else {
                MessageBox.insert(address: ThisApp.messageBoxAddress, .init(
                    ID: ThisApp.messageIDForCurrentOperation,
                    type: .error,
                    title: NSLocalizedString("Invalid JSON format!", comment: "")
                ))
                return
            }

            /* MARK: Message */

            if (updateCount > 0 || insertCount > 0) {
                var descriptions: [String] = []
                if (updateCount > 0) { descriptions.append(String(format: NSLocalizedString("%d existing records have been updated", comment: ""), updateCount)) }
                if (insertCount > 0) { descriptions.append(String(format: NSLocalizedString("%d new records have been added"       , comment: ""), insertCount)) }
                MessageBox.insert(address: ThisApp.messageBoxAddress, .init(
                    ID: ThisApp.messageIDForCurrentOperation,
                    type: .ok,
                    title: NSLocalizedString("Import", comment: ""),
                    description: descriptions.joined(separator: "\n\n")
                ))
            }
            if (invalidDomains.count > 0 || expiredDomains.count > 0) {
                var descriptions: [String] = []
                let listFormatter: ([String]) -> String = { values in
                    if (values.count > 10)
                         { return values.prefix(10).joined(separator: " | ") + " ..." }
                    else { return values           .joined(separator: " | ") }
                }
                if (invalidDomains.count > 0) { descriptions.append(String(format: NSLocalizedString("Invalid domains were detected:\n%@", comment: ""), listFormatter(invalidDomains))) }
                if (expiredDomains.count > 0) { descriptions.append(String(format: NSLocalizedString("Expired domains were detected:\n%@", comment: ""), listFormatter(expiredDomains))) }
                MessageBox.insert(address: ThisApp.messageBoxAddress, .init(
                    ID: ThisApp.messageIDForImportWarning,
                    type: .warning,
                    lifetime: .time(duration: 10),
                    mergePolicy: .replaceOrInsertAtTop,
                    title: NSLocalizedString("Import", comment: ""),
                    description: descriptions.joined(separator: "\n\n")
                ))
            }

            /* MARK: Reload Rules */

            if (updateCount > 0 || insertCount > 0) {
                SFSafariApplication.reloadRules()
            }

        } catch {
            MessageBox.insert(address: ThisApp.messageBoxAddress, .init(
                ID: ThisApp.messageIDForCurrentOperation,
                type: .error,
                title: String("\(error)")
            ))
        }
    }

}
