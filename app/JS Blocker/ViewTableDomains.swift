
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SafariServices

class ViewTableDomains: NSTableView, NSTableViewDataSource, NSTableViewDelegate {

    let colCount: Int = 3
    var data: [WhiteDomains] = []
    var dataHash: Int?
    var filterByName: String?
    var outlet: NSTableView!
    var onChange: () -> Void = {}

    func relateWithOutlet(outlet: NSTableView) {
        self.outlet = outlet
    }

    func reload() {
        WhiteDomains.context.reset()
        self.data = WhiteDomains.selectAll(
            filter: self.filterByName
        )

        let newDataHash = WhiteDomains.hashOfSet(self.data)
        if (self.dataHash == nil || self.dataHash != newDataHash) {
            self.updateViewAfterDataChanges(
                outlet  : self.outlet,
                rowCount: self.data.count,
                colCount: self.colCount
            )
            #if DEBUG
                if (self.dataHash == nil) { print("ViewTableDomains.reload(): Data Hash is NIL") }
                if (self.dataHash != nil) { print("ViewTableDomains.reload(): Data Hash is changed from \"\(self.dataHash ?? 0)\" to \"\(newDataHash)\"") }
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
                    button.tag = rowNum
                } else {
                    cell.subviews.removeAll()
                    let button = NSButton(frame: NSRect(x: 0, y: 2, width: 20, height: 20))
                        button.target = self
                        button.action = #selector(onClickToLink)
                        button.bezelStyle = .badge
                        button.image = NSImage(systemSymbolName: "safari", accessibilityDescription: nil)
                        button.tag = rowNum
                    cell.addSubview(button)
                }
            default:
                return nil
        }

        return cell
    }

    @objc func onClickToLink(_ sender: NSButton) {
        let domain = self.data[sender.tag]
        if let url = URL(string: "https://\(domain.name)") {
            NSWorkspace.shared.open(url)
        }
    }

}
