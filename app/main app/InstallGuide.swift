
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SafariServices
import SwiftUI

struct InstallGuide: View {

    static let IMAGE_INSTALL_GUIDE_PAGE_1 = Image("Install Guide Page 1")
    static let IMAGE_INSTALL_GUIDE_PAGE_2 = Image("Install Guide Page 2")

    @State private var isEnabledExtensionPopup = false

    private var colorTitle: Color {
        Color.installGuide.statusTitle
    }

    private var colorTitleBackground: Color {
        self.isEnabledExtensionPopup ?
            Color.installGuide.statusSuccessTitleBackground :
            Color.installGuide.statusFailureTitleBackground
    }

    private var colorDescriptionBackground: Color {
        self.isEnabledExtensionPopup ?
            Color.installGuide.statusSuccessDescriptionBackground :
            Color.installGuide.statusFailureDescriptionBackground
    }

    private var colorButtonBackground: Color {
        self.isEnabledExtensionPopup ?
            Color.installGuide.statusSuccessButtonBackground :
            Color.installGuide.statusFailureButtonBackground
    }

    public var body: some View {
        VStack(spacing: 20) {

            VStack(spacing: 0) {

                /* MARK: Title */

                Text(
                    self.isEnabledExtensionPopup ?
                        NSLocalizedString("Popup is enabled" , comment: "") :
                        NSLocalizedString("Popup is disabled", comment: "")
                )
                .font(.system(size: 15, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(15)
                .foregroundPolyfill(self.colorTitle)
                .background(self.colorTitleBackground)

                /* MARK: Description */

                ZStack {
                    ButtonCustom(
                        NSLocalizedString("Open Safari Extensions Preferences…", comment: ""),
                        colorStyle: .custom(text: .white, background: self.colorButtonBackground),
                        flexibility: .size(300),
                        onClick: self.onClick_OpenSafariPreferencesForExtension
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(self.colorDescriptionBackground)

            }

            Text(NSLocalizedString("Installation example", comment: ""))
                .font(.system(size: 18, weight: .bold))

            VStack(spacing: 20) {

                let width = 700.0

                Self.IMAGE_INSTALL_GUIDE_PAGE_1
                    .resizable()
                    .frame(width: width, height: width * (417.0 / 1672.0))
                    .shadow(
                        color: .black.opacity(0.5),
                        radius: 5,
                        y: 0
                    )

                Self.IMAGE_INSTALL_GUIDE_PAGE_2
                    .resizable()
                    .frame(width: width, height: width * (579.0 / 1672.0))
                    .shadow(
                        color: .black.opacity(0.5),
                        radius: 5,
                        y: 0
                    )

            }

        }
        .padding(20)
        .onAppear(perform: self.onAppearView)
    }

    private func onAppearView() {
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: EXTENSION_POPUP_NAME, completionHandler: { (state, error) in
            guard let state = state, error == nil else {
                Logger.customLog("viewWillAppear(): Popup state error = \(error!)")
                return
            }
            Task {
                self.isEnabledExtensionPopup = state.isEnabled
            }
        })
    }

    private func onClick_OpenSafariPreferencesForExtension() {
        SFSafariApplication.showPreferencesForExtension(
            withIdentifier: EXTENSION_POPUP_NAME
        )
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct InstallGuide_Previews: PreviewProvider {
    static var previews: some View {
        InstallGuide()
    }
}
