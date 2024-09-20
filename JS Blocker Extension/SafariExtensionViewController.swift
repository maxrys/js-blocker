
import SafariServices

enum BlockState: String {
    case domain
    case domainWithSubdomains
    case nothing

    var isJSAllowed: Bool {
        return self == .domain ||
               self == .domainWithSubdomains
    }
}

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

    enum ViewHeightValue: Int {
        case def         = 450
        case withMessage = 550
    }

    static let ViewWidthValue = 450
    static var domainNameCurrent: String?
    static var pageCurrent: SFSafariPage?
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(
            width : SafariExtensionViewController.ViewWidthValue,
            height: ViewHeightValue.def.rawValue)
        return shared
    }()

    static func blockStateInfoGet(domainName: String) -> (BlockState, WhiteDomains?) {
        if let domainInfo = WhiteDomains.selectByName(name: domainName) {
            if domainInfo.withSubdomains != true {return (state: .domain              , info: domainInfo)}
            if domainInfo.withSubdomains == true {return (state: .domainWithSubdomains, info: domainInfo)}
        } else if let domainInfo = WhiteDomains.selectByName(name: domainName.deleteWwwPrefixIfExists()) {
            if domainInfo.withSubdomains == true {
                return (state: .domainWithSubdomains, info: domainInfo)
            }
        }
        return (state: .nothing, info: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
            print("viewDidLoad(): DB path = \(WhiteDomains.storeURL)")
            WhiteDomains.dump()
        #endif
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.formInit()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if SafariExtensionViewController.domainNameCurrent != nil {
            self.formUpdate()
        }
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

    func ruleShow(group: NSBox, label: NSTextField, rule: String?, isActive: Bool = false) {
        if rule == nil {label.stringValue = NSLocalizedString("...loading...", comment: "")}
        if rule != nil {label.stringValue = rule!.decodePunycode()}
        if isActive == true {label.textColor   = NSColor(named: "Domain Active Text Color"  ) ?? .textColor}
        if isActive == true {group.borderColor = NSColor(named: "Domain Active Border Color") ?? .textColor}
        if isActive != true {label.textColor   = .textColor}
        if isActive != true {group.borderColor = .textBackgroundColor}
    }

    func formInit() {
        self.ruleShow(group: self.groupRule             , label: self.labelRule              , rule: nil)
        self.ruleShow(group: self.groupRuleWithSubdomain, label: self.labelRuleWithSubdomains, rule: nil)
        self.buttonInsertRule.accessSet(false)
        self.buttonInsertRuleWithSubdomains.accessSet(false)
        self.buttonDeleteRule.accessSet(false)
        self.messageHide()
    }

    func formUpdate() {
        if let domainName = SafariExtensionViewController.domainNameCurrent {

            let rule               =      domainName
            let ruleWithSubdomains = "*.\(domainName.deleteWwwPrefixIfExists())"
            let (state, _) = SafariExtensionViewController.blockStateInfoGet(domainName: domainName)

            // special case for "www.domain" (rule: "*.domain") when exists rule for "domain" (rule: "domain")
            var hasMirror: Bool? = nil
            if domainName.hasWwwPrefix() {
                if let noWwwDomainInfo = WhiteDomains.selectByName(name: domainName.deleteWwwPrefixIfExists()), noWwwDomainInfo.withSubdomains == false {
                    hasMirror = true
                }
            }

            switch state {
                case .domain:
                    self.ruleShow(group: self.groupRule             , label: self.labelRule              , rule: rule              , isActive: true)
                    self.ruleShow(group: self.groupRuleWithSubdomain, label: self.labelRuleWithSubdomains, rule: ruleWithSubdomains, isActive: false)
                    self.buttonInsertRule.accessSet(false)
                    self.buttonInsertRuleWithSubdomains.accessSet(false)
                    self.buttonDeleteRule.accessSet(true)
                case .domainWithSubdomains:
                    self.ruleShow(group: self.groupRule             , label: self.labelRule              , rule: rule              , isActive: false)
                    self.ruleShow(group: self.groupRuleWithSubdomain, label: self.labelRuleWithSubdomains, rule: ruleWithSubdomains, isActive: true)
                    self.buttonInsertRule.accessSet(false)
                    self.buttonInsertRuleWithSubdomains.accessSet(false)
                    self.buttonDeleteRule.accessSet(true)
                case .nothing:
                    self.ruleShow(group: self.groupRule             , label: self.labelRule              , rule: rule              , isActive: false)
                    self.ruleShow(group: self.groupRuleWithSubdomain, label: self.labelRuleWithSubdomains, rule: ruleWithSubdomains, isActive: false)
                    self.buttonInsertRule.accessSet(true)
                    self.buttonInsertRuleWithSubdomains.accessSet(hasMirror == true ? false : true)
                    self.buttonDeleteRule.accessSet(false)
            }

            let domainParents = WhiteDomains.selectParents(
                name: domainName.deleteWwwPrefixIfExists()
            )

            if !domainParents.isEmpty {
                var parents: [String] = []
                for parent in domainParents {
                    parents.append(
                        "*.\(parent.name)"
                    )
                }
                self.messageShow(
                    title: NSLocalizedString("Inherited permissions detected from:", comment: ""),
                    description: parents.joined(separator: " | ")
                )
            }

        }
    }

    func pageUpdate() {
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: ENV.APP_RULES_EXTENSION_NAME, completionHandler: { error in
            if let error = error {
                #if DEBUG
                    print("pageUpdate(): Extension reload error = \(error.localizedDescription)")
                #endif
            } else {
                #if DEBUG
                    print("pageUpdate(): Extension has been reloaded.")
                #endif
                if let page       = SafariExtensionViewController.pageCurrent,
                   let domainName = SafariExtensionViewController.domainNameCurrent {
                    // Task {
                    //     try await Task.sleep(nanoseconds: 1_000_000_000)
                    //     page.reload()
                    // }
                       let domainHasParents = WhiteDomains.selectParents(name: domainName).isEmpty == false
                       let (state, _) = SafariExtensionViewController.blockStateInfoGet(domainName: domainName)
                       page.dispatchMessageToScript(
                           withName: "reloadPageMsg",
                           userInfo: [
                               "timestamp": Date().timeIntervalSince1970,
                               "domain"   : domainName,
                               "result"   : state.isJSAllowed || domainHasParents
                           ]
                       )
                } else {
                    #if DEBUG
                        print("pageUpdate(): Page not found")
                    #endif
                }
            }
        })
    }

    @IBAction func onClick_buttonRuleInsert(_ sender: NSButton) {
        if let domainName = SafariExtensionViewController.domainNameCurrent {
            WhiteDomains.insert(
                name: domainName,
                withSubdomains: false
            )
            self.formUpdate()
            self.pageUpdate()
            #if DEBUG
                WhiteDomains.dump()
            #endif
        }
    }

    @IBAction func onClick_buttonRuleInsertWithSubdomains(_ sender: NSButton) {
        if let domainName = SafariExtensionViewController.domainNameCurrent {
            WhiteDomains.insert(
                name: domainName.deleteWwwPrefixIfExists(),
                withSubdomains: true,
                skippedWww: domainName.hasWwwPrefix()
            )
            self.formUpdate()
            self.pageUpdate()
            #if DEBUG
                WhiteDomains.dump()
            #endif
        }
    }

    @IBAction func onClick_buttonRuleDelete(_ sender: NSButton) {
        if let domainName = SafariExtensionViewController.domainNameCurrent {
            if let domainInfo = WhiteDomains.selectByName(name: domainName) {
                domainInfo.delete()
                self.formUpdate()
                self.pageUpdate()
                #if DEBUG
                    WhiteDomains.dump()
                #endif
            } else if let domainInfo = WhiteDomains.selectByName(name: domainName.deleteWwwPrefixIfExists()) {
                domainInfo.delete()
                self.formUpdate()
                self.pageUpdate()
                #if DEBUG
                    WhiteDomains.dump()
                #endif
            }
        }
    }

}
