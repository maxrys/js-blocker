
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import SafariServices
import SwiftUI

struct InstallPopup: View {

    @State private var isEnabledExtension = false

    private var colorTitleBackground: Color {
        self.isEnabledExtension ?
            Color.installPopup.statusSuccessTitleBackground :
            Color.installPopup.statusFailureTitleBackground
    }


    private var colorDescriptionBackground: Color {
        self.isEnabledExtension ?
            Color.installPopup.statusSuccessDescriptionBackground :
            Color.installPopup.statusFailureDescriptionBackground
    }

    private var colorButtonBackground: Color {
        self.isEnabledExtension ?
            Color.installPopup.statusSuccessButtonBackground :
            Color.installPopup.statusFailureButtonBackground
    }

    public var body: some View {
        VStack(spacing: 20) {

            VStack(spacing: 0) {

                /* MARK: Title */

                Text(
                    self.isEnabledExtension ?
                        NSLocalizedString("JS \"Blocker Extension\" is enabled" , comment: "") :
                        NSLocalizedString("JS \"Blocker Extension\" is disabled", comment: "")
                )
                .font(.system(size: 15, weight: .bold))
                .foregroundPolyfill(Color.white)
                .frame(maxWidth: .infinity)
                .padding(15)
                .background(self.colorTitleBackground)

                /* MARK: Description */

                ZStack {
                    ButtonCustom(
                        NSLocalizedString("Open Safari Extensions Preferences…", comment: ""),
                        colorStyle: .custom(text: .white, background: self.colorButtonBackground),
                        flexibility: .size(300),
                        onClick: self.onClick_OpenSafariPreferences
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(self.colorDescriptionBackground)

            }

            Text(NSLocalizedString("Installation example", comment: ""))
                .font(.system(size: 18, weight: .bold))

            Image("Installation Guide")
                .resizable()
                .frame(width: 600, height: 357)
                .shadow(
                    color: .black.opacity(0.5),
                    radius: 5,
                    y: 0
                )

        }
        .padding(20)
        .background(Color.installPopup.background)
        .onAppear(perform: self.onAppearView)
    }

    private func onAppearView() {
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: EXTENSION_NAME, completionHandler: { (state, error) in
            guard let state = state, error == nil else {
                Logger.customLog("viewWillAppear(): Extension state error = \(error!)")
                return
            }
            Task {
                self.isEnabledExtension = state.isEnabled
            }
        })
    }

    private func onClick_OpenSafariPreferences() {
        SFSafariApplication.showPreferencesForExtension(
            withIdentifier: EXTENSION_NAME
        )
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct InstallPopup_Previews: PreviewProvider {
    static var previews: some View {
        InstallPopup()
    }
}
