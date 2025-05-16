
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
    @IBOutlet var tableDomains: TableDomainsController!
    @IBOutlet var buttonTableDomainsDelete: NSButtonCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        #if DEBUG
            WhiteDomains.dump()
        #endif

        self.tableDomains.onChange      = self.onChangeData_tableDomains
        self.tableDomains.onClickToLink = self.onClickToLink
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
            name: TableDomainsController.selectionDidChangeNotification,
            object: nil
        )
    }

    @objc func viewDidBecomeActive() {
        self.tableDomains.reload()
    }

    func onClickToLink(name: String) {
        if let url = URL(string: "https://\(name)") {
            NSWorkspace.shared.open(url)
        }
    }

    func onChangeData_tableDomains() {
        self.buttonExport.isEnabled = !self.tableDomains.data.isEmpty
    }

    @objc func onChangeSelection_tableDomains() {
        self.buttonTableDomainsDelete.isEnabled = !self.tableDomains.selectedRowIndexes.isEmpty
    }

    @IBAction func onUpdateValue_searchField(_ field: NSSearchField) {
        if (field.stringValue == "") { self.tableDomains.filterByName = nil }
        if (field.stringValue != "") { self.tableDomains.filterByName = field.stringValue }
        self.tableDomains.reload()
    }

    @IBAction func onClick_buttonTableDomainsDelete(_ button: NSButton) {
        self.tableDomains.deleteItems(rowNums: self.tableDomains.selectedRowIndexes)
        self.tableDomains.reload()
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
            for domain in WhiteDomains.selectAll(filter: self.tableDomains.filterByName) {
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

            /* generate export URL */
            let formattedDate = Date().formatCustom("yyyyMMdd-HHmmss")
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
                        let _ = WhiteDomains.selectByName(item.name)?.delete()
                        if (WhiteDomains.insert(name: item.name, isGlobal: item.isGlobal)) {
                            processed += 1
                            #if DEBUG
                                print("IMPORT ITEM: isGlobal = \(item.isGlobal) | name = \(item.name)")
                            #endif
                        } else { invalidDomains.append(item.name) }
                    }     else { invalidDomains.append(item.name) }
                }
            }

            /* table reload */
            self.tableDomains.reload()

            /* message */
            let alert: NSAlert = NSAlert()
                alert.messageText = NSLocalizedString("Import", comment: "")
                if (invalidDomains.isEmpty)
                     { alert.informativeText = String(format: NSLocalizedString("%d records have been processed", comment: ""), processed) }
                else { alert.informativeText = String(format: NSLocalizedString("%d records have been processed", comment: ""), processed) + "\n\n" + String(format: NSLocalizedString("Invalid domains were detected:\n%@", comment: ""), invalidDomains.joined(separator: "\n")) }
                alert.alertStyle = .informational
                alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
                alert.runModal()

        }} catch {} }

    }

}
