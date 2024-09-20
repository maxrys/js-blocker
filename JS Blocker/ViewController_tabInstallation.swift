
import SafariServices

class ViewController_tabInstallation: NSViewController {

    @IBOutlet var boxExtensionState: NSBox!
    @IBOutlet var boxExtensionStateTitle: NSBox!
    @IBOutlet var labelExtensionState: NSTextField!
    @IBOutlet var buttonOpenSafariExtensionsPreferences: NSButton!

    override func viewWillAppear() {
        super.viewWillAppear()
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: ENV.APP_POPUP_EXTENSION_NAME, completionHandler: { (state, error) in
            guard let state = state, error == nil else {
                #if DEBUG
                    print("viewWillAppear(): Extension state error = \(error!)")
                #endif
                return
            }
            Task {
                if state.isEnabled == true {
                    self.labelExtensionState.stringValue = NSLocalizedString("JS Blocker Extension is enabled" , comment: "")
                    self.boxExtensionState.fillColor = MessageState.ok.backgroundColor
                    self.boxExtensionStateTitle.fillColor = MessageState.ok.titleBackgroundColor
                    self.buttonOpenSafariExtensionsPreferences.bezelColor = MessageState.ok.titleBackgroundColor
                } else {
                    self.labelExtensionState.stringValue = NSLocalizedString("JS Blocker Extension is disabled", comment: "")
                    self.boxExtensionState.fillColor = MessageState.error.backgroundColor
                    self.boxExtensionStateTitle.fillColor = MessageState.error.titleBackgroundColor
                    self.buttonOpenSafariExtensionsPreferences.bezelColor = MessageState.error.titleBackgroundColor
                }
            }
        })
    }

    @IBAction func onClick_buttonOpenSafariExtensionsPreferences(_ sender: NSButtonCell) {
        SFSafariApplication.showPreferencesForExtension(
            withIdentifier: ENV.APP_POPUP_EXTENSION_NAME
        )
    }

}
