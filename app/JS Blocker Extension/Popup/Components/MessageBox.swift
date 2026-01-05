
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

struct Message: Hashable {

    enum LifeTime {
        case infinity
        case time(Double)
    }

    static var LIFE_TIME: Double = 1.0

    let type: MessageType
    let title: String
    let description: String
    let expireAfter: Double?

    init(type: MessageType, title: String, description: String = "", expireAfter: Double? = Self.LIFE_TIME) {
        self.type = type
        self.title = title
        self.description = description
        self.expireAfter = expireAfter
    }

}

struct MessageBox: View {

    typealias MessagesCollection = [UInt: (
        message: Message,
        expirationTimer: RealTimer?
    )]

    static let EVENT_NAME_FOR_MESSAGE_INSERT = "messageInsert"
    static var counter: UInt = 0

    @State private var messages = MessagesCollection()

    private let publisherForInsert = EventsDispatcher.shared.publisher(
        Self.EVENT_NAME_FOR_MESSAGE_INSERT
    )!

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
                if let time = message.expireAfter {
                    expirationTimer.start(
                        tickInterval: time
                    )
                }
            }
        }
    }

    static func insert(type: MessageType, title: String, description: String = "", lifeTime: Message.LifeTime = .time(Message.LIFE_TIME)) {
        var expireAfter: Double?
        switch lifeTime {
            case .time(let time): expireAfter = time
            case .infinity      : break
        }
        EventsDispatcher.shared.send(
            MessageBox.EVENT_NAME_FOR_MESSAGE_INSERT,
            object: Message(
                type: type,
                title: title,
                description: description,
                expireAfter: expireAfter
            )
        )
    }

    func onTimerTick(offset: Double, timer: RealTimer) {
        timer.stopAndReset()
        self.messages[timer.tag] = nil
    }

}

#Preview {
    ScrollView {
        Button("show") {
            MessageBox.insert(type: .info   , title: "Info"   , lifeTime: .infinity)
            MessageBox.insert(type: .ok     , title: "Ok"     , lifeTime: .infinity)
            MessageBox.insert(type: .warning, title: "Warning", lifeTime: .infinity)
            MessageBox.insert(type: .error  , title: "Error"  , lifeTime: .infinity)
            MessageBox.insert(type: .info   , title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", lifeTime: .time(3))
            MessageBox.insert(type: .ok     , title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", lifeTime: .time(4))
            MessageBox.insert(type: .warning, title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", lifeTime: .time(5))
            MessageBox.insert(type: .error  , title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", lifeTime: .time(6))
        }
        MessageBox()
    }
    .frame(maxWidth: 300)
    .padding(10)
}
