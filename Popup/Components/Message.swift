
import SwiftUI

struct MessageInfo: Hashable {
    let title: String
    let description: String
    let type: Message.MessageType
}

struct Message: View {

    enum MessageType {

        case info
        case ok
        case error
        case warning

        var colorTitleBackground: Color {
            switch self {
                case .info   : return Color(ENV.COLORNAME_MESSAGE_INFO_TITLE_BACKGROUND)
                case .ok     : return Color(ENV.COLORNAME_MESSAGE_OK_TITLE_BACKGROUND)
                case .warning: return Color(ENV.COLORNAME_MESSAGE_WARNING_TITLE_BACKGROUND)
                case .error  : return Color(ENV.COLORNAME_MESSAGE_ERROR_TITLE_BACKGROUND)
            }
        }

        var colorDescriptionBackground: Color {
            switch self {
                case .info   : return Color(ENV.COLORNAME_MESSAGE_INFO_DESCRIPTION_BACKGROUND)
                case .ok     : return Color(ENV.COLORNAME_MESSAGE_OK_DESCRIPTION_BACKGROUND)
                case .warning: return Color(ENV.COLORNAME_MESSAGE_WARNING_DESCRIPTION_BACKGROUND)
                case .error  : return Color(ENV.COLORNAME_MESSAGE_ERROR_DESCRIPTION_BACKGROUND)
            }
        }
    }

    var title: String
    var description: String
    var type: MessageType

    var body: some View {
        VStack(spacing: 0) {

            Text(NSLocalizedString(self.title, comment: ""))
                .font(.system(size: 14, weight: .bold))
                .color(Color(ENV.COLORNAME_MESSAGE_TEXT))
                .padding(13)
                .frame(maxWidth: .infinity)
                .background(self.type.colorTitleBackground)

            Text(NSLocalizedString(self.description, comment: ""))
                .font(.system(size: 13))
                .color(Color(ENV.COLORNAME_MESSAGE_TEXT))
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(self.type.colorDescriptionBackground)

        }.frame(maxWidth: .infinity)
    }

}

#Preview {
    VStack(spacing: 0) {

        Message(
            title: "Title",
            description: "Description",
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
