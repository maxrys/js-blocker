
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices

class ViewController_tableWhiteDomains: NSTableView, NSTableViewDataSource, NSTableViewDelegate {

    let colCount: Int = 2
    var data: [WhiteDomains] = []
    var dataHash: Int? = nil
    var outlet: NSTableView!

    func relateWithOutlet(outlet: NSTableView) {
        self.outlet = outlet
    }

    func updateData() {
        WhiteDomains.context.reset()
        self.data = WhiteDomains.selectAll()

        /* first data fetch */
        if (self.dataHash == nil) {
            self.dataHash = WhiteDomains.hashSimpleCalculate(
                domains: self.data
            )
        }
    }

    func updateView() {
        let newDataHash = WhiteDomains.hashSimpleCalculate(
            domains: self.data
        )

        if (self.dataHash != newDataHash) {
            self.updateViewAfterDataChanges(
                outlet:   self.outlet,
                rowCount: self.data.count,
                colCount: self.colCount
            )
        }

        #if DEBUG
            print("updateView(): Old data hash = \(String(describing: self.dataHash))")
            print("updateView(): New data hash = \(newDataHash)")
            print("updateView(): Old data hash != New data hash = \(self.dataHash != newDataHash)")
            print("")
        #endif

        self.dataHash = newDataHash
    }

    func deleteItems(rowNums: IndexSet) {
        if (rowNums.isEmpty == false) {
            var pKeys: [String] = []
            for rowNum in rowNums {
                pKeys.append(
                    self.data[rowNum].name
                )
            }
            WhiteDomains.deleteByNames(
                names: pKeys
            )
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.data.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row rowNum: Int) -> NSView? {
        let columnID     = tableColumn!.identifier
        let columnIDText = tableColumn!.identifier.rawValue
        let domain       = self.data[rowNum]

        guard let cell = tableView.makeView(
            withIdentifier: columnID,
            owner: self
        ) as? NSTableCellView else {
            return nil
        }

        switch columnIDText {
            case "name"                                              : cell.textField!.stringValue = domain.name
            case "nameDecoded"                                       : cell.textField!.stringValue = domain.nameDecoded
            case "withSubdomains" where domain.withSubdomains == true: cell.textField!.stringValue = NSLocalizedString("yes", comment: "")
            case "withSubdomains" where domain.withSubdomains != true: cell.textField!.stringValue = NSLocalizedString("no" , comment: "")
            default                                                  : return nil
        }

        return cell
    }

}
