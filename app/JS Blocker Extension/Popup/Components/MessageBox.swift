
/* ################################################################## */
/* ### Copyright © 2024—2025 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct Message: Hashable {

    let type: MessageType
    let title: String
    let description: String

    init(type: MessageType, title: String, description: String = "") {
        self.title = title
        self.description = description
        self.type = type
    }

}

struct MessageBox: View {

    typealias MessagesCollection = [
        UInt: (
            message: Message,
            expirationTimer: RealTimer?
        )
    ]

    static let EVENT_NAME_FOR_MESSAGE_INSERT = "messageInsert"
    static var MESSAGE_LIFE_TIME: Double = 1.0
    static var counter: UInt = 0

    @State private var messages: MessagesCollection

    private let publisherForInsert = EventsDispatcher.shared.publisher(
        Self.EVENT_NAME_FOR_MESSAGE_INSERT
    )!

    init(messages: MessagesCollection = [:]) {
        self.messages = messages
    }

    func onTimerTick(offset: Double, timer: RealTimer) {
        timer.stopAndReset()
        self.messages[timer.tag] = nil
    }

    var body: some View {
        VStack (spacing: 0) {
            ForEach(self.messages.sorted(by: { (lhs, rhs) in lhs.key < rhs.key }), id: \.key) { id, item in
                VStack(spacing: 0) {
                    Text(NSLocalizedString(item.message.title, comment: ""))
                        .font(.system(size: 14, weight: .bold))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(13)
                        .frame(maxWidth: .infinity)
                        .background(item.message.type.colorTitleBackground)
                    if (!item.message.description.isEmpty) {
                        Text(NSLocalizedString(item.message.description, comment: ""))
                            .font(.system(size: 13))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(13)
                            .frame(maxWidth: .infinity)
                            .background(item.message.type.colorDescriptionBackground)
                    }
                }
                .color(Color(MessageType.ColorNames.text.rawValue))
                .frame(maxWidth: .infinity)
            }
        }.onReceive(self.publisherForInsert) { publisher in
            if let message = publisher.object as? Message {
                Self.counter += 1
                let id = Self.counter
                let expirationTimer = RealTimer(
                    tag: id,
                    onTick: self.onTimerTick
                )
                self.messages[id] = (
                    message: message,
                    expirationTimer: expirationTimer
                )
                expirationTimer.start(
                    tickInterval: Self.MESSAGE_LIFE_TIME
                )
            }
        }
    }

    static func insert(type: MessageType, title: String, description: String = "") {
        EventsDispatcher.shared.send(
            MessageBox.EVENT_NAME_FOR_MESSAGE_INSERT,
            object: Message(
                type       : type,
                title      : title,
                description: description
            )
        )
    }

}

struct Message_Previews2: PreviewProvider {
    static var previews: some View {
        ScrollView {
            MessageBox(messages: [
                0: (message: Message(type: .info   , title: "Info"   ), expirationTimer: nil),
                1: (message: Message(type: .ok     , title: "Ok"     ), expirationTimer: nil),
                2: (message: Message(type: .warning, title: "Warning"), expirationTimer: nil),
                3: (message: Message(type: .error  , title: "Error"  ), expirationTimer: nil),
                4: (message: Message(type: .info   , title: "Lorem ipsum dolor sit amet", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."), expirationTimer: nil),
                5: (message: Message(type: .ok     , title: "Lorem ipsum dolor sit amet", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."), expirationTimer: nil),
                6: (message: Message(type: .warning, title: "Lorem ipsum dolor sit amet", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."), expirationTimer: nil),
                7: (message: Message(type: .error  , title: "Lorem ipsum dolor sit amet", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."), expirationTimer: nil),
            ])
        }
        .frame(maxWidth: 300)
        .padding(10)
    }
}
