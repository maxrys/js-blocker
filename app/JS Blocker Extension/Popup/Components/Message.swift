
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct MessageInfo: Hashable {
    let title: String
    let description: String
    let type: MessageType
}

struct Message: View {

    var title: String
    var description: String = ""
    var type: MessageType

    var body: some View {
        VStack(spacing: 0) {

            Text(NSLocalizedString(self.title, comment: ""))
                .font(.system(size: 14, weight: .bold))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .color(Color(MessageType.ColorNames.text.rawValue))
                .padding(13)
                .frame(maxWidth: .infinity)
                .background(self.type.colorTitleBackground)

            if (self.description.isEmpty == false) {
                Text(NSLocalizedString(self.description, comment: ""))
                    .font(.system(size: 13))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .color(Color(MessageType.ColorNames.text.rawValue))
                    .padding(13)
                    .frame(maxWidth: .infinity)
                    .background(self.type.colorDescriptionBackground)
            }

        }.frame(maxWidth: .infinity)
    }

}

struct Message_Previews1: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {

            Message(
                title: "Long title. Long title. Long title. Long title. Long title. Long title.",
                description: "Long Description. Long Description. Long Description. Long Description. Long Description. Long Description.",
                type: .info
            )

            Message(
                title: "Title",
                description: "Description",
                type: .ok
            )

            Message(
                title: "Title",
                description: "Description",
                type: .warning
            )

            Message(
                title: "Title",
                description: "Description",
                type: .error
            )

        }.frame(width: 300)
    }
}

struct Message_Previews2: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {

            Message(
                title: "Message",
                type: .info
            )

            Message(
                title: "Message",
                type: .ok
            )

            Message(
                title: "Message",
                type: .warning
            )

            Message(
                title: "Message",
                type: .error
            )

        }.frame(width: 300)
    }
}
