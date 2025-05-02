
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices

class TableDomainsController: NSTableView, NSTableViewDataSource, NSTableViewDelegate {

    let colCount: Int = 3
    var data: [WhiteDomains] = []
    var dataHash: Int?
    var filterByName: String?
    var onChange: () -> Void = {}
    var onClickToLink: (String) -> Void = { _ in }

    override func awakeFromNib() {
        self.delegate   = self
        self.dataSource = self
        super.awakeFromNib()
    }

    func reload() {
        WhiteDomains.context.reset()
        self.data = WhiteDomains.selectAll(
            filter: self.filterByName
        )
        let newDataHash = WhiteDomains.hashOfSet(self.data)
        if (self.dataHash == nil || self.dataHash != newDataHash) {
            self.updateViewAfterDataChanges(
                rowCount: self.data.count,
                colCount: self.colCount
            )
            #if DEBUG
                if (self.dataHash == nil) { print("TableDomainsController.reload(): Data Hash is NIL") }
                if (self.dataHash != nil) { print("TableDomainsController.reload(): Data Hash is changed from \"\(self.dataHash ?? 0)\" to \"\(newDataHash)\"") }
            #endif
            self.dataHash = newDataHash
            self.onChange()
        }
    }

    func deleteItems(rowNums: IndexSet) {
        if (rowNums.count > 0) {
            var primaryKeys: [String] = []
            for rowNum in rowNums {
                primaryKeys.append(
                    self.data[rowNum].name
                )
            }
            WhiteDomains.deleteByNames(
                names: primaryKeys
            )
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.data.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row rowNum: Int) -> NSView? {
        guard let cell = tableView.makeView(
            withIdentifier: tableColumn!.identifier,
            owner: self
        ) as? NSTableCellView else {
            return nil
        }

        let domain = self.data[rowNum]

        switch tableColumn!.identifier.rawValue {
            case "name"       : cell.textField!.stringValue = domain.name
            case "nameDecoded": cell.textField!.stringValue = domain.nameDecoded
            case "isGlobal"   : cell.textField!.stringValue = NSLocalizedString(domain.isGlobal ? "yes" : "no", comment: "")
            case "link":
                if let button = cell.subviews.first as? NSButton {
                    button.tag    = rowNum
                    button.target = self
                    button.action = #selector(
                        self.onClickToLinkInternal
                    )
                }
            default:
                return nil
        }

        return cell
    }

    @objc func onClickToLinkInternal(_ sender: NSButton) {
        self.onClickToLink(
            self.data[sender.tag].name
        )
    }

}
