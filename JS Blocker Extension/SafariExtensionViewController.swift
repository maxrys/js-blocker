
import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {

    @IBOutlet var boxMessage: NSBox!
    @IBOutlet var boxMessageTitle: NSBox!
    @IBOutlet var labelMessageTitle: NSTextField!
    @IBOutlet var labelMessageDescription: NSTextField!

    @IBOutlet var groupRule: NSBox!
    @IBOutlet var labelRule: NSTextField!
    @IBOutlet var buttonInsertRule: NSButton!

    @IBOutlet var groupRuleWithSubdomain: NSBox!
    @IBOutlet var labelRuleWithSubdomains: NSTextField!
    @IBOutlet var buttonInsertRuleWithSubdomains: NSButton!

    @IBOutlet var buttonDeleteRule: NSButton!

    var currentDomainName: String!

    static let ViewWidthValue = 450

    enum ViewHeightValue: Int {
        case def         = 450
        case withMessage = 550
    }

    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(
            width : SafariExtensionViewController.ViewWidthValue,
            height: ViewHeightValue.def.rawValue)
        return shared
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
            print("Database path: \(WhiteDomains.storeURL)")
            WhiteDomains.dump()
        #endif
    }

    override func viewWillAppear() {
        super.viewWillAppear()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    func viewSetSize(width: Int, height: Int) {
        SafariExtensionViewController.shared.preferredContentSize = NSSize(width: width, height: height)
    }

    func messageShow(title: String, description: String, state: MessageState = .info, height: ViewHeightValue = ViewHeightValue.withMessage) {
        self.boxMessage.fillColor                = state.backgroundColor
        self.boxMessageTitle.fillColor           = state.titleBackgroundColor
        self.labelMessageTitle.stringValue       = title
        self.labelMessageDescription.stringValue = description
        SafariExtensionViewController.shared.preferredContentSize = NSSize(
            width : SafariExtensionViewController.ViewWidthValue,
            height: height.rawValue
        )
    }

    func messageHide() {
        self.boxMessage.fillColor                = MessageState.info.backgroundColor
        self.boxMessageTitle.fillColor           = MessageState.info.titleBackgroundColor
        self.labelMessageTitle.stringValue       = NSLocalizedString("...title..."      , comment: "")
        self.labelMessageDescription.stringValue = NSLocalizedString("...description...", comment: "")
        SafariExtensionViewController.shared.preferredContentSize = NSSize(
            width : SafariExtensionViewController.ViewWidthValue,
            height: ViewHeightValue.def.rawValue
        )
    }

    @IBAction func onClick_buttonRuleInsert(_ sender: NSButton) {
        #if DEBUG
            print("onClick_buttonAllowDomain")
            self.messageShow(title: "some title", description: "some description")
            SFContentBlockerManager.reloadContentBlocker(withIdentifier: "maxrys.js-blocker.rules", completionHandler: { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
        #endif
    }

    @IBAction func onClick_buttonRuleInsertWithSubdomains(_ sender: NSButton) {
        #if DEBUG
            self.messageHide()
            print("onClick_buttonAllowDomainWithSubdomains")
        #endif
    }

    @IBAction func onClick_buttonRuleDelete(_ sender: NSButton) {
        #if DEBUG
            print("onClick_buttonCancelPermission")
        #endif
    }

}
