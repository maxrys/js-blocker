
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices

class ViewRules: NSViewController {

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
        self.tableDomainsController.relateWithOutlet(outlet: self.tableDomains)
        self.tableDomainsController.reload()
        self.tableDomains.relateWithController(
            delegate  : tableDomainsController,
            dataSource: tableDomainsController
        )

        self.buttonTableDomainsDelete.isEnabled = !self.tableDomains.selectedRowIndexes.isEmpty

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.viewDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.tableDomainsSelectionDidChange),
            name: ViewTableDomains.selectionDidChangeNotification,
            object: nil
        )
    }

    @objc func viewDidBecomeActive() {
        self.tableDomainsController.reload()
    }

    @objc func tableDomainsSelectionDidChange() {
        self.buttonTableDomainsDelete.isEnabled = !self.tableDomains.selectedRowIndexes.isEmpty
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
