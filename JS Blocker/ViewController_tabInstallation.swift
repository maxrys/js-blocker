
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

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
                    self.boxExtensionState.fillColor = MessageState.ok.colorDescriptionBackground
                    self.boxExtensionStateTitle.fillColor = MessageState.ok.colorTitleBackground
                    self.buttonOpenSafariExtensionsPreferences.bezelColor = MessageState.ok.colorTitleBackground
                } else {
                    self.labelExtensionState.stringValue = NSLocalizedString("JS Blocker Extension is disabled", comment: "")
                    self.boxExtensionState.fillColor = MessageState.error.colorDescriptionBackground
                    self.boxExtensionStateTitle.fillColor = MessageState.error.colorTitleBackground
                    self.buttonOpenSafariExtensionsPreferences.bezelColor = MessageState.error.colorTitleBackground
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
