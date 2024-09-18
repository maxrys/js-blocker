
import SafariServices

class ViewController_tabInstallation: NSViewController {

    @IBOutlet var boxExtensionState: NSBox!
    @IBOutlet var boxExtensionStateTitle: NSBox!
    @IBOutlet var labelExtensionState: NSTextField!
    @IBOutlet var buttonOpenSafariExtensionsPreferences: NSButton!

    override func viewWillAppear() {
        super.viewWillAppear()
    }

    @IBAction func onClick_buttonOpenSafariExtensionsPreferences(_ sender: NSButtonCell) {
        #if DEBUG
            print("onClick_buttonOpenSafariExtensionsPreferences")
        #endif
    }

}
