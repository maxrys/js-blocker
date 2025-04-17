
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
    @Published var indecesForLocal: [Int]
    @Published var indecesForGLobal: [Int]
    @Published var messages: [MessageInfo]
    @Published var timer: RealTimer!

    init(rulesForLocal: [String] = [], rulesForGlobal: [String] = [], isActiveLocalRule: Bool = false, isActiveGlobalRule: Bool = false, isEnabledLocalRule: Bool = false, isEnabledGlobalRule: Bool = false, isEnabledRuleCancel: Bool = false, indecesForLocal: [Int] = [], indecesForGLobal: [Int] = [], messages: [MessageInfo] = [], onTick: @escaping (Double) -> Void = { _ in }) {
        self.rulesForLocal       = rulesForLocal
        self.rulesForGlobal      = rulesForGlobal
        self.isActiveLocalRule   = isActiveLocalRule
        self.isActiveGlobalRule  = isActiveGlobalRule
        self.isEnabledLocalRule  = isEnabledLocalRule
        self.isEnabledGlobalRule = isEnabledGlobalRule
        self.isEnabledRuleCancel = isEnabledRuleCancel
        self.indecesForLocal     = indecesForLocal
        self.indecesForGLobal    = indecesForGLobal
        self.messages            = messages
        self.timer               = RealTimer(onTick: onTick)
    }

    func reset() {
        self.rulesForLocal       = []
        self.rulesForGlobal      = []
        self.isActiveLocalRule   = false
        self.isActiveGlobalRule  = false
        self.isEnabledLocalRule  = false
        self.isEnabledGlobalRule = false
        self.isEnabledRuleCancel = false
        self.indecesForLocal     = []
        self.indecesForGLobal    = []
        self.messages.removeAll()
    }

}
