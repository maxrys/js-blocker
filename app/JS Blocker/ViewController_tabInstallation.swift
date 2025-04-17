
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
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: App.POPUP_EXTENSION_NAME, completionHandler: { (state, error) in
            guard let state = state, error == nil else {
                #if DEBUG
                    print("viewWillAppear(): Extension state error = \(error!)")
                #endif
                return
            }
            Task {
                if (state.isEnabled == true) {
                    self.labelExtensionState.stringValue = NSLocalizedString("JS Blocker Extension is enabled" , comment: "")
                    self.boxExtensionState.fillColor = MessageType.ok.colorNSDescriptionBackground
                    self.boxExtensionStateTitle.fillColor = MessageType.ok.colorNSTitleBackground
                    self.buttonOpenSafariExtensionsPreferences.bezelColor = MessageType.ok.colorNSTitleBackground
                } else {
                    self.labelExtensionState.stringValue = NSLocalizedString("JS Blocker Extension is disabled", comment: "")
                    self.boxExtensionState.fillColor = MessageType.error.colorNSDescriptionBackground
                    self.boxExtensionStateTitle.fillColor = MessageType.error.colorNSTitleBackground
                    self.buttonOpenSafariExtensionsPreferences.bezelColor = MessageType.error.colorNSTitleBackground
                }
            }
        })
    }

    @IBAction func onClick_buttonOpenSafariExtensionsPreferences(_ sender: NSButton) {
        SFSafariApplication.showPreferencesForExtension(
            withIdentifier: App.POPUP_EXTENSION_NAME
        )
    }

}
