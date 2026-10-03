
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct LifetimePicker: View {

    static let LIFETIME_PERIODS: [TimeInterval: String] = [
        .PERIOD_1_MINUTE : NSLocalizedString("1 minute" , comment: ""),
        .PERIOD_5_MINUTES: NSLocalizedString("5 minutes", comment: ""),
        .PERIOD_1_HOUR   : NSLocalizedString("1 hour"   , comment: ""),
        .PERIOD_1_DAY    : NSLocalizedString("1 day"    , comment: ""),
        .PERIOD_1_WEEK   : NSLocalizedString("1 week"   , comment: ""),
    ]

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    @Binding private var lifetime: TimeInterval?
    @State private var isOpened = false

    private var isActive: Bool {
        self.lifetime != nil
    }

    init(lifetime: Binding<TimeInterval?>) {
        self._lifetime = lifetime
    }

    public var body: some View {
        ButtonRectangle(
            isActive: self.isActive,
            icon: Image("symbol Icon Timer"),
            iconSize: 26,
            iconOffset: CGPoint(x: 0, y: -1),
            onClick: {
                self.isOpened.toggle()
            }
        )
        .overlayPolyfill(alignment: .bottom) {
            self.HintView()
                .padding(.horizontal, -20)
                .offset(y: 20)
        }
        .popover(
            isPresented: self.isEnabled ? self.$isOpened : .constant(false),
            arrowEdge: .bottom
        ) {
            self.PopupView()
        }
    }

    @ViewBuilder private func HintView() -> some View {
        if let lifetime = self.lifetime {
            if let text = Self.LIFETIME_PERIODS[lifetime] {
                Text(text)
                    .font(.system(size: 10))
                    .opacity(0.5)
            }
        }
    }

    @ViewBuilder private func PopupView() -> some View {
        VStack(alignment: .leading, spacing: 0) {

            self.PopupTitleView()
                .overlayPolyfill(alignment: .bottom) {
                    self.PopupTitleShadowView(height: 5)
                        .offset(y: 5 + 1)
                }

            self.PopupListItemView(
                lifetime: nil,
                title: NSLocalizedString("unlimit", comment: "")
            )
            .frame(maxWidth: .infinity)
            .padding(.init(top: 20, leading: 20, bottom: 15, trailing: 20))
            .background(Color.lifetime.popupValueUnlimitBackground)

            VStack(alignment: .leading, spacing: 7) {
                ForEach(Array(Self.LIFETIME_PERIODS.sorted(order: .keyAscending)), id: \.key) { lifetime, title in
                    self.PopupListItemView(
                        lifetime: lifetime,
                        title   : title
                    )
                }
            }.padding(.init(top: 15, leading: 20, bottom: 20, trailing: 20))
        }
    }

    @ViewBuilder private func PopupTitleView() -> some View {
        Text(NSLocalizedString("Lifetime", comment: ""))
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(15)
            .foregroundPolyfill(Color.lifetime.popupTitle)
            .background(Color.lifetime.popupTitleBackground)
    }

    @ViewBuilder private func PopupTitleShadowView(height: CGFloat = 5) -> some View {
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

    @ViewBuilder private func PopupListItemView(lifetime: TimeInterval?, title: String) -> some View {
        let isActive = self.lifetime == lifetime
        RadioButtonSimple(isSelected: isActive) {
            Task { @MainActor in
                self.lifetime = lifetime
                self.isOpened = false
            }
        } lebel: {
            Text(title)
        }
        .disabled(!self.isEnabled)
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct LifetimePicker_Previews: PreviewProvider {
    struct ViewWithState: View {
        @State private var lifetime: TimeInterval? = nil
        public var body: some View {
            VStack(spacing: 30) {
                LifetimePicker(lifetime: self.$lifetime)
                Text("\(self.lifetime?.int64 ?? 0)")
                Spacer()
            }
            .padding(20)
            .frame(width: 200, height: 400)
            .background(Color.popup.ruleExactBackground)
        }
    }
    static public var previews: some View {
        self.ViewWithState()
    }
}
