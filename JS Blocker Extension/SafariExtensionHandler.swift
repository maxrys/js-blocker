
import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {

    override func beginRequest(with context: NSExtensionContext) {
    }

    override func popoverWillShow(in window: SFSafariWindow) {
        // when: info.plist → SFSafariToolbarItem → Action = Popover
    }

    override func toolbarItemClicked(in window: SFSafariWindow) {
        // when: info.plist → SFSafariToolbarItem → Action = Command
    }

    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        validationHandler(true, "")
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        // when: info.plist → SFSafariToolbarItem → Action = Popover
        return SafariExtensionViewController.shared
    }

}
