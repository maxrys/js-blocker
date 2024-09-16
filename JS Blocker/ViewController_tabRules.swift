
import SafariServices

class ViewController_tabRules: NSViewController {

    @IBOutlet var tableDomains: NSTableView!
    @IBOutlet var buttonTableDomainsDelete: NSButtonCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
            print("viewDidLoad")
            print("Database path: \(WhiteDomains.storeURL)")
            WhiteDomains.dump()
        #endif
    }

    @IBAction func onClick_buttonTableDomainsDelete(_ sender: NSButtonCell) {
        #if DEBUG
            print("onClick_buttonTableDomainsDelete")
            WhiteDomains.seed()
            WhiteDomains.dump()
        #endif
    }

}
