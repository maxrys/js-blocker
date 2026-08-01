
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct LifetimeInfo: View {

    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var popupState = PopupState.shared
    @State private var isShowLifetimeDetailed = false

    private func lifetimeStringLocalized(_ timeLeft: TimeInterval) -> String {
        TimeInterval.wholeParts(interval: timeLeft).ifNil(defaultValue: NOT_APPLICABLE) { lifetimeWholeParts in
            switch (TimeInterval.ScaleSize(interval: timeLeft)) {
                case .week  : return String(format: NSLocalizedString("%d week"  , comment: ""), lifetimeWholeParts.weeks  )
                case .day   : return String(format: NSLocalizedString("%d day"   , comment: ""), lifetimeWholeParts.days   )
                case .hour  : return String(format: NSLocalizedString("%d hour"  , comment: ""), lifetimeWholeParts.hours  )
                case .minute: return String(format: NSLocalizedString("%d minute", comment: ""), lifetimeWholeParts.minutes)
                case .second: return String(format: NSLocalizedString("%d second", comment: ""), lifetimeWholeParts.seconds)
            }
        }
    }

    public var body: some View {
        if case .valid(let timeLeft, let progress) = self.popupState.expireStatus {
            VStack(spacing: 10) {

                ProgressSimple(value: progress)
                    .frame(width: 200)

                HStack(spacing: 5) {

                    if (timeLeft > TimeInterval.PERIOD_1_MINUTE) {
                        Color.clear.frame(width: 14, height: 14)
                    }

                    Text(String(format: NSLocalizedString("lifetime: %@", comment: ""), self.lifetimeStringLocalized(timeLeft)))
                        .font(.system(size: 10))

                    if (timeLeft > TimeInterval.PERIOD_1_MINUTE) {
                        self.OpenerView()
                            .popover(isPresented: self.$isShowLifetimeDetailed, arrowEdge: .trailing) {
                                self.PopupView(timeLeft)
                            }
                            .onHover { isHovering in
                                self.isShowLifetimeDetailed = isHovering
                            }
                    }

                }

            }
        }
    }

    @ViewBuilder private func OpenerView() -> some View {
        Image(systemName: "questionmark.circle")
            .font(.system(size: 12))
            .foregroundPolyfill(
                Color.lifetime.infoOpener
            )
    }

    @ViewBuilder private func PopupView(_ timeLeft: TimeInterval) -> some View {
        VStack(spacing: 0) {

            self.PopupTitle()
                .overlayPolyfill(alignment: .bottom) {
                    self.PopupTitleShadow(height: 5)
                        .offset(y: 5 + 1)
                }

            VStack(spacing: 10) {
                if let lifetimeWholeParts = TimeInterval.wholeParts(interval: timeLeft) {
                    if (lifetimeWholeParts.weeks   > 0) { Text( String(format: NSLocalizedString("%d week"  , comment: ""), lifetimeWholeParts.weeks  ) ) }
                    if (lifetimeWholeParts.days    > 0) { Text( String(format: NSLocalizedString("%d day"   , comment: ""), lifetimeWholeParts.days   ) ) }
                    if (lifetimeWholeParts.hours   > 0) { Text( String(format: NSLocalizedString("%d hour"  , comment: ""), lifetimeWholeParts.hours  ) ) }
                    if (lifetimeWholeParts.minutes > 0) { Text( String(format: NSLocalizedString("%d minute", comment: ""), lifetimeWholeParts.minutes) ) }
                    if (lifetimeWholeParts.seconds > 0) { Text( String(format: NSLocalizedString("%d second", comment: ""), lifetimeWholeParts.seconds) ) }
                }
            }.padding(20)

        }
    }

    @ViewBuilder private func PopupTitle(height: CGFloat = 5) -> some View {
        Text(NSLocalizedString("lifetime", comment: ""))
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 30)
            .padding(.vertical  , 15)
            .foregroundPolyfill(Color.lifetime.popupTitle)
            .background(Color.lifetime.popupTitleBackground)
    }

    @ViewBuilder private func PopupTitleShadow(height: CGFloat = 5) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.lifetime.popupTitleBorder)
                .frame(height: 1)
            ShadowLine(
                length: height,
                opacity: 0.3,
                opacityDark: 0.5
            )
        }
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct LifetimeInfo_ExpireNoLimit_Previews: PreviewProvider {
    static var previews: some View {
        Previewer(spacing: 10) { DomainRulePanel(panelType: .exact).background(Color.popup.ruleExactBackground) }
            .frame(width: Popup.FRAME_WIDTH)
            .onAppear {
                PopupState.shared.match = .exact(item: DEMO_ITEM__EXACT__EXPIRE_NO_LIMIT)
                PopupState.shared.ruleExact = DEMO_RULE__EXACT_TOPDOMAIN
                PopupState.shared.rulesWildcard = DEMO_RULES__WILDCARD_TOPDOMAIN
            }
    }
}

struct LifetimeInfo_ExpireValid_Previews: PreviewProvider {
    static var previews: some View {
        Previewer(spacing: 10) { DomainRulePanel(panelType: .exact).background(Color.popup.ruleExactBackground) }
            .frame(width: Popup.FRAME_WIDTH)
            .onAppear {
                PopupState.shared.match = .exact(item: DEMO_ITEM__EXACT__EXPIRE_VALID)
                PopupState.shared.ruleExact = DEMO_RULE__EXACT_TOPDOMAIN
                PopupState.shared.rulesWildcard = DEMO_RULES__WILDCARD_TOPDOMAIN
            }
    }
}

struct LifetimeInfo_ExpireExpired_Previews: PreviewProvider {
    static var previews: some View {
        Previewer(spacing: 10) { DomainRulePanel(panelType: .exact).background(Color.popup.ruleExactBackground) }
            .frame(width: Popup.FRAME_WIDTH)
            .onAppear {
                PopupState.shared.match = .exact(item: DEMO_ITEM__EXACT__EXPIRE_EXPIRED)
                PopupState.shared.ruleExact = DEMO_RULE__EXACT_TOPDOMAIN
                PopupState.shared.rulesWildcard = DEMO_RULES__WILDCARD_TOPDOMAIN
            }
    }
}
