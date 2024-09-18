
import SafariServices

class ViewController_tabRules: NSViewController {

    @IBOutlet var tableDomains: NSTableView!
    @IBOutlet var buttonTableDomainsDelete: NSButtonCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
            print("viewDidLoad")
        #endif
    }

    @IBAction func onClick_buttonTableDomainsDelete(_ sender: NSButtonCell) {
        #if DEBUG
            print("onClick_buttonTableDomainsDelete")
        #endif
    }

}
