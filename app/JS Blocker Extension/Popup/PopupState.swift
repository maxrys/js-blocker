
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

class PopupState: ObservableObject {

    @Published var rulesForLocal: [String]
    @Published var rulesForGlobal: [String]
    @Published var isActiveLocalRule: Bool
    @Published var isActiveGlobalRule: Bool
    @Published var isEnabledLocalRule: Bool
    @Published var isEnabledGlobalRule: Bool
    @Published var isEnabledRuleCancel: Bool
    @Published var messages: [MessageInfo]

    init(rulesForLocal: [String] = [], rulesForGlobal: [String] = [], isActiveLocalRule: Bool = false, isActiveGlobalRule: Bool = false, isEnabledLocalRule: Bool = false, isEnabledGlobalRule: Bool = false, isEnabledRuleCancel: Bool = false, messages: [MessageInfo] = []) {
        self.rulesForLocal       = rulesForLocal
        self.rulesForGlobal      = rulesForGlobal
        self.isActiveLocalRule   = isActiveLocalRule
        self.isActiveGlobalRule  = isActiveGlobalRule
        self.isEnabledLocalRule  = isEnabledLocalRule
        self.isEnabledGlobalRule = isEnabledGlobalRule
        self.isEnabledRuleCancel = isEnabledRuleCancel
        self.messages            = messages
    }

    func reset() {
        self.rulesForLocal       = []
        self.rulesForGlobal      = []
        self.isActiveLocalRule   = false
        self.isActiveGlobalRule  = false
        self.isEnabledLocalRule  = false
        self.isEnabledGlobalRule = false
        self.isEnabledRuleCancel = false
        self.messages.removeAll()
    }

}
