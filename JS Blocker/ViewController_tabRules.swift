
import SafariServices

class ViewController_tabRules: NSViewController {

    @IBOutlet var tableDomains: NSTableView!
    @IBOutlet var buttonTableDomainsDelete: NSButtonCell!

    var tableDomainsController : ViewController_tableWhiteDomains!

    override func viewDidLoad() {
        super.viewDidLoad()

        #if DEBUG
            print("viewDidLoad(): DB path = \(WhiteDomains.storeURL)")
            WhiteDomains.dump()
        #endif

        self.tableDomainsController = ViewController_tableWhiteDomains()
        self.tableDomainsController.relateWithOutlet(outlet: self.tableDomains)
        self.tableDomainsController.updateData()
        self.tableDomains.relateWithController(
            delegate:   tableDomainsController,
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
            name: ViewController_tableWhiteDomains.selectionDidChangeNotification,
            object: nil
        )
    }

    @objc func viewDidBecomeActive(){
        self.tableDomainsController.updateData()
        self.tableDomainsController.updateView()
    }

    @objc func tableDomainsSelectionDidChange() {
        self.buttonTableDomainsDelete.isEnabled = !self.tableDomains.selectedRowIndexes.isEmpty
    }

    @IBAction func onClick_buttonTableDomainsDelete(_ sender: NSButtonCell) {
        self.tableDomainsController.deleteItems(rowNums: self.tableDomains.selectedRowIndexes)
        self.tableDomainsController.updateData()
        self.tableDomainsController.updateView()
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: ENV.APP_RULES_EXTENSION_NAME, completionHandler: { error in
            if let error = error {
                #if DEBUG
                    print("onClick_buttonTableDomainsDelete(): Extension reload error = \(error.localizedDescription)")
                #endif
            } else {
                #if DEBUG
                    print("onClick_buttonTableDomainsDelete(): Extension has been reloaded.")
                #endif
            }
        })
    }

}
