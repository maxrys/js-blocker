
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices

struct ExportImportItem: Codable {
    let name    : String
    let isGlobal: Bool
}

class ViewRules: NSViewController {

    @IBOutlet var buttonExport: NSButton!
    @IBOutlet var buttonImport: NSButton!
    @IBOutlet var fieldSearch: NSSearchField!
    @IBOutlet var tableDomains: NSTableView!
    @IBOutlet var buttonTableDomainsDelete: NSButtonCell!

    var tableDomainsController: ViewTableDomains!

    override func viewDidLoad() {
        super.viewDidLoad()

        #if DEBUG
            print("viewDidLoad(): DB path = \(WhiteDomains.storeURL)")
            WhiteDomains.dump()
        #endif

        self.tableDomainsController = ViewTableDomains()
        self.tableDomainsController.onChange = self.onChangeData_tableDomains
        self.tableDomainsController.relateWithOutlet(outlet: self.tableDomains)
        self.tableDomainsController.reload()
        self.tableDomains.relateWithController(
            delegate  : tableDomainsController,
            dataSource: tableDomainsController
        )

        self.onChangeSelection_tableDomains()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.viewDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onChangeSelection_tableDomains),
            name: ViewTableDomains.selectionDidChangeNotification,
            object: nil
        )
    }

    @objc func viewDidBecomeActive() {
        self.tableDomainsController.reload()
    }

    func onChangeData_tableDomains() {
        self.buttonExport.isEnabled = !self.tableDomainsController.data.isEmpty
    }

    @objc func onChangeSelection_tableDomains() {
        self.buttonTableDomainsDelete.isEnabled = !self.tableDomains.selectedRowIndexes.isEmpty
    }

    @IBAction func onClick_buttonExport(_ button: NSButton) {

        let openPanel = NSOpenPanel()
            openPanel.allowsMultipleSelection = false
            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
            openPanel.canCreateDirectories = true
            openPanel.prompt = NSLocalizedString("Export", comment: "")

        if (openPanel.runModal() == .OK) { do { if let directoryURL = openPanel.url {

            /* generate export JSON */
            var jsonObject: [ExportImportItem] = []
            for domain in WhiteDomains.selectAll(filter: self.tableDomainsController.filterByName) {
                jsonObject.append(
                    ExportImportItem(
                        name    : domain.name,
                        isGlobal: domain.isGlobal
                    )
                )
            }

            let jsonEncoder = JSONEncoder()
                jsonEncoder.outputFormatting = .prettyPrinted
            let jsonData = try! jsonEncoder.encode(
                jsonObject
            )

            /* generate export date */
            let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd-HHmmss"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

            let formattedDate = dateFormatter.string(
                from: Date()
            )

            /* generate export URL */
            let exportFileURL = directoryURL.appendingPathComponent(
                "JSBlocker-\(formattedDate).json"
            )

            /* write to file */
            try jsonData.stringUTF8!.write(
                to: exportFileURL,
                atomically: false,
                encoding: .utf8
            )

            /* message */
            let alert: NSAlert = NSAlert()
                alert.messageText = NSLocalizedString("Export", comment: "")
                alert.informativeText = String(format: NSLocalizedString("%d records have been processed", comment: ""), jsonObject.count)
                alert.alertStyle = .informational
                alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
                alert.runModal()

        }} catch {} }

    }

    @IBAction func onClick_buttonImport(_ button: NSButton) {

        let openPanel = NSOpenPanel()
            openPanel.allowsMultipleSelection = false
            openPanel.canChooseFiles = true
            openPanel.canChooseDirectories = false
            openPanel.canCreateDirectories = false
            openPanel.allowedContentTypes = [.json]
            openPanel.prompt = NSLocalizedString("Import", comment: "")

        if (openPanel.runModal() == .OK) { do { if let fileURL = openPanel.url {

            let JSONString = try String(
                contentsOf: fileURL,
                encoding: .utf8
            )
            let JSONObject = try? JSONDecoder().decode(
                [ExportImportItem].self,
                from: JSONString.data(using: .utf8)!
            )

            if (JSONObject == nil) {
                let alert: NSAlert = NSAlert()
                    alert.messageText = NSLocalizedString("Import", comment: "")
                    alert.informativeText = NSLocalizedString("Invalid JSON format!", comment: "")
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
                    alert.runModal()
                return
            }

            /* import to database */
            var processed: Int = 0
            var invalidDomains: [String] = []
            if let items = JSONObject {
                for item in items {
                    if (item.name.domainNameIsValid()) {
                        WhiteDomains.selectByName(item.name)?.delete()
                        WhiteDomains.insert(
                            name    : item.name,
                            isGlobal: item.isGlobal
                        )
                        processed += 1
                        #if DEBUG
                            print("IMPORT ITEM: isGlobal = \(item.isGlobal) | name = \(item.name)")
                        #endif
                    } else {
                        invalidDomains.append(
                            item.name
                        )
                    }
                }
            }

            /* table reload */
            self.tableDomainsController.reload()

            /* message */
            let alert: NSAlert = NSAlert()
                alert.messageText = NSLocalizedString("Import", comment: "")
                if (invalidDomains.isEmpty)
                     { alert.informativeText = String(format: NSLocalizedString("%d records have been processed", comment: ""), processed) }
                else { alert.informativeText = String(format: NSLocalizedString("%d records have been processed", comment: ""), processed) + "\n\n" + String(format: NSLocalizedString("Invalid domains were detected:\n%s", comment: ""), invalidDomains.joined(separator: "\n")) }
                alert.alertStyle = .informational
                alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
                alert.runModal()

        }} catch {} }

    }

    @IBAction func onUpdateValue_searchField(_ field: NSSearchField) {
        if (field.stringValue == "") { self.tableDomainsController.filterByName = nil }
        if (field.stringValue != "") { self.tableDomainsController.filterByName = field.stringValue }
        self.tableDomainsController.reload()
    }

    @IBAction func onClick_buttonTableDomainsDelete(_ button: NSButton) {
        self.tableDomainsController.deleteItems(rowNums: self.tableDomains.selectedRowIndexes)
        self.tableDomainsController.reload()
    }

}
