
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

struct About: View {

    @Environment(\.colorScheme) internal var colorScheme
    @Environment(\.openURL) var openURL

    @State private var mainViewSize: CGSize = .zero

    public var body: some View {
        HStack(spacing: 0) {
            self.IconView(self.mainViewSize.height)
                .zIndex(1)
                .overlayPolyfill(alignment: .trailing) {
                    self.ShadowLineView(self.mainViewSize.height)
                        .offset(x: 10)
                }
            self.MainContentView()
                .onGeometryChangePolyfill(
                    type: .inside,
                    size: self.$mainViewSize
                )
        }
        .windowChamelionBackground(
            windowID: ThisApp.WINDOW_ABOUT_ID
        )
    }

    @ViewBuilder private func IconView(_ size: CGFloat) -> some View {
        Image("AboutIcon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(25)
            .frame(width: size, height: size)
    }

    @ViewBuilder private func ShadowLineView(_ height: CGFloat) -> some View {
        ShadowLine(
            length: 10,
            angle: .`270_degrees`,
            opacity: 0.6,
            opacityDark: 0.5
        ).frame(height: height)
    }

    @ViewBuilder private func MainContentView() -> some View {
        VStack(alignment: .leading, spacing: 5) {

            Text(NSApplication.appNameLocalized)
                .font(.system(size: 24, weight: .bold))
                .fixedSize(horizontal: true, vertical: true)
                .lineLimit(1)
                .opacity(0.9)

            if let appVersion = NSApplication.appVersion, let appBuild = NSApplication.appBuild {
                Text(String(format: NSLocalizedString("Version %@ (%@)", comment: ""), appVersion, appBuild))
                    .font(.system(size: 14))
                    .fixedSize(horizontal: true, vertical: true)
                    .lineLimit(1)
                    .opacity(0.7)
                    .padding(.bottom, 15)
            }

            if let pageMarketing = NSApplication.pageMarketing {
                HStack(spacing: 5) { self.ButtonOpenURLView(pageMarketing) }
                    .font(.system(size: 12))
                    .fixedSize(horizontal: true, vertical: true)
                    .lineLimit(1)
                    .padding(.bottom, 5)
            }

            if let pageSupport = NSApplication.pageSupport {
                ButtonCustom(
                    NSLocalizedString("support", comment: ""),
                    colorStyle: self.colorScheme == .dark ? .custom(text: nil, background: Color.NS[\.windowBackgroundColor]) : .common,
                    font: .system(size: 14, weight: .regular),
                    padding: .init(top: 3, leading: 20, bottom: 5, trailing: 20),
                    flexibility: .none,
                    isFlat: false,
                    onClick: {
                        if let url = URL(string: pageSupport) {
                            self.openURL(url)
                        }
                    }
                ).focusable(false)
            }

            if let appCopyright = NSApplication.appCopyright {
                Text(appCopyright)
                    .font(.system(size: 12))
                    .fixedSize(horizontal: true, vertical: true)
                    .lineLimit(1)
                    .opacity(0.5)
                    .padding(.top, 15)
            }

        }
        .padding(.horizontal, 40)
        .padding(.vertical  , 30)
        .background(
            self.colorScheme == .dark ?
                Color.black.opacity(0.5) :
                Color.white.opacity(0.8)
        )
    }

    @ViewBuilder private func ButtonOpenURLView(_ value: String) -> some View {
        Group {
            if let url = URL(string: value) {
                Button { openURL(url) } label: {
                    Text(value)
                        .underline()
                        .foregroundPolyfill(Color.NS[\.linkColor])
                        .focusEffect(RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
                .pointerStyleLinkPolyfill()
            } else {
                Text(value)
            }
        }
        .font(.system(size: 12))
        .fixedSize(horizontal: true, vertical: true)
        .lineLimit(1)
        .focusable(false)
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

#Preview {
    Previewer(spacing: 0) {
        About()
            .padding(1)
            .background(Color.blue)
            .frame(width: 600)
    }
}
