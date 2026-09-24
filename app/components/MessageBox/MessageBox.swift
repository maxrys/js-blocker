
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import SwiftUI

typealias MessageBoxID = UInt
typealias MessageID = UInt

enum MessageBoxAddress: Codable {

    case distributed(boxID: MessageBoxID, appName: String)
    case local      (boxID: MessageBoxID)

}

enum MessageType: Codable {

    case info
    case ok
    case warning
    case error

}

enum MessageLifeTime: Codable {

    static let LIFE_TIME_DEFAULT: CFTimeInterval = 3.0

    case time(duration: Double)
    case infinity

}

enum MessageMergePolicy: Codable {

    case replaceOrInsertAtTop
    case replaceOrInsertAtBottom
    case deleteAndInsertAtTop
    case deleteAndInsertAtBottom

}

struct MessageInfo: Equatable, Codable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.ID == rhs.ID
    }

    public var viewID: String {
        "\(self.ID)-\(self.createdAt)"
    }

    public var isPersistent: Bool {
        if case .infinity = self.lifetime { true } else { false }
    }

    public var isExpired: Bool? {
        if case .time(let duration) = self.lifetime {
            let expiresAt = self.createdAt + duration
            return Date.timestamp >= expiresAt
        }
        return nil
    }

    public var progress: Double? {
        if case .time(let duration) = self.lifetime {
            let createdAt = self.createdAt
            let expiresAt = self.createdAt + duration
            return Date.timestamp.progress(
                begin: createdAt, end: expiresAt
            )
        }
        return nil
    }

    public let ID: MessageID
    public let type: MessageType
    public let lifetime: MessageLifeTime
    public let isClosable: Bool
    public let mergePolicy: MessageMergePolicy
    public let title: String
    public let description: String?
    public let createdAt: TimeInterval

    init(
        ID: MessageID? = nil,
        type: MessageType = .info,
        lifetime: MessageLifeTime = .time(duration: MessageLifeTime.LIFE_TIME_DEFAULT),
        isClosable: Bool = true,
        mergePolicy: MessageMergePolicy = .replaceOrInsertAtBottom,
        title: String,
        description: String? = nil
    ) {
        self.type = type
        self.lifetime = lifetime
        self.isClosable = isClosable
        self.mergePolicy = mergePolicy
        self.title = title
        self.description = description
        self.createdAt = Date.timestamp
        self.ID = ID ?? MessageID(Checksums.crc32(
            "\(type)|\(title)|\(description ?? "")"
        ))
    }

    init?(decode json: String) {
        do {
            guard let data = json.data(using: .utf8) else {
                return nil
            }
            self = try JSONDecoder().decode(
                Self.self,
                from: data
            )
        } catch {
            return nil
        }
    }

    func encode() -> String? {
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(self) else {
            return nil
        }
        return String(
            data: data,
            encoding: .utf8
        )
    }

}

fileprivate struct Message: View {

    @State private var progress: Double = 0.0
    @State private var isHoverOnTitle = false
    @State private var timer: Timer.Custom?

    private var colorTitleBackground: Color {
        switch self.info.type {
            case .info   : Color.messageBox.infoTitleBackground
            case .ok     : Color.messageBox.okTitleBackground
            case .warning: Color.messageBox.warningTitleBackground
            case .error  : Color.messageBox.errorTitleBackground
        }
    }

    private var colorDescriptionBackground: Color {
        switch self.info.type {
            case .info   : Color.messageBox.infoDescriptionBackground
            case .ok     : Color.messageBox.okDescriptionBackground
            case .warning: Color.messageBox.warningDescriptionBackground
            case .error  : Color.messageBox.errorDescriptionBackground
        }
    }

    private var colorProgressBackground: Color {
        switch self.info.type {
            case .info   : Color.messageBox.infoProgressBackground
            case .ok     : Color.messageBox.okProgressBackground
            case .warning: Color.messageBox.warningProgressBackground
            case .error  : Color.messageBox.errorProgressBackground
        }
    }

    public let address: MessageBoxAddress
    public let info: MessageInfo

    public var body: some View {
        VStack(spacing: 0) {
            self.TitleView()
            self.DescriptionView()
        }.overlayPolyfill(alignment: .bottom) {
            if !self.info.isPersistent {
                self.ProgressView()
            }
        }
        .onAppear {
            if case .time(let duration) = self.info.lifetime {
                self.progress = 0.0
                self.timer = Timer.Custom(repeats: .count(1), delay: duration, onExpire: self.onTimerExpire)
                withAnimation(.linear(duration: duration)) {
                    self.progress = 1.0
                }
            }
        }
        .onDisappear {
            self.timer?.stopAndReset()
            self.timer = nil
        }
    }

    private func onTimerExpire(timer: Timer.Custom) {
        self.progress = 1.0
        self.timer?.stopAndReset()
        self.timer = nil
        MessageBox.delete(
            address: self.address,
            self.info.ID
        )
    }

    @ViewBuilder private func TitleView() -> some View {
        Text(self.info.title)
            .font(.system(size: 14, weight: .bold))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(13)
            .frame(maxWidth: .infinity)
            .foregroundPolyfill(Color.messageBox.text)
            .background(self.colorTitleBackground)
            .overlayPolyfill(alignment: .topTrailing) {
                if (self.info.isClosable && self.isHoverOnTitle) {
                    self.ButtonCloseView()
                        .offset(x: -12, y: 12)
                }
            }
            .onHover { isHovering in
                self.isHoverOnTitle = isHovering
            }
    }

    @ViewBuilder private func DescriptionView() -> some View {
        if let description = self.info.description {
            Text(description)
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(13)
                .frame(maxWidth: .infinity)
                .foregroundPolyfill(Color.messageBox.text)
                .background(self.colorDescriptionBackground)
        }
    }

    @ViewBuilder private func ProgressView() -> some View {
        GeometryReaderCustom(isIgnoreHeight: true, alignment: .leading) { size in
            Rectangle()
                .fill(self.colorProgressBackground)
                .frame(maxWidth: size.width * self.progress)
                .frame(height: 3)
        }
    }

    @ViewBuilder private func ButtonCloseView() -> some View {
        Button {
            MessageBox.delete(
                address: self.address,
                self.info.ID
            )
        } label: {
            let shape = RoundedRectangle(cornerRadius: 3)
            shape
                .fill(self.colorDescriptionBackground)
                .frame(width: 20, height: 20)
                .overlayPolyfill {
                    Image(systemName: "xmark.square")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundPolyfill(Color.messageBox.text)
                }
                .clipShape   (shape)
                .contentShape(shape)
                .focusEffect (shape)
        }
        .focusable(false)
        .buttonStyle(.plain)
        .shadow(
            color: .black.opacity(0.5),
            radius: 3,
            y: 0
        )
    }

}

struct MessageBox: View {

    static let MESSAGE_NAME_FOR_INSERT_DISTRIBUTED = "messageInsertDistributed"
    static let MESSAGE_NAME_FOR_DELETE_DISTRIBUTED = "messageDeleteDistributed"
    static let MESSAGE_NAME_FOR_INSERT_LOCAL       = "messageInsertLocal"
    static let MESSAGE_NAME_FOR_DELETE_LOCAL       = "messageDeleteLocal"

    static private func notificationNameForInsertDistributed(_ messageBoxID: MessageBoxID, _ appName: String) -> NSNotification.Name { NSNotification.Name("\(Self.MESSAGE_NAME_FOR_INSERT_DISTRIBUTED)-\(appName)-\(messageBoxID)") }
    static private func notificationNameForDeleteDistributed(_ messageBoxID: MessageBoxID, _ appName: String) -> NSNotification.Name { NSNotification.Name("\(Self.MESSAGE_NAME_FOR_DELETE_DISTRIBUTED)-\(appName)-\(messageBoxID)") }
    static private func notificationNameForInsertLocal      (_ messageBoxID: MessageBoxID,                  ) -> NSNotification.Name { NSNotification.Name("\(Self.MESSAGE_NAME_FOR_INSERT_LOCAL)-\(messageBoxID)") }
    static private func notificationNameForDeleteLocal      (_ messageBoxID: MessageBoxID,                  ) -> NSNotification.Name { NSNotification.Name("\(Self.MESSAGE_NAME_FOR_DELETE_LOCAL)-\(messageBoxID)") }

    static public func insert(address: MessageBoxAddress, _ message: MessageInfo) {
        switch address {
            case .distributed(let boxID, let appName): NotificationCenter.default.postDistributed(name: Self.notificationNameForInsertDistributed(boxID, appName), object: message.encode())
            case .local      (let boxID)             : NotificationCenter.default.post           (name: Self.notificationNameForInsertLocal      (boxID         ), object: message.encode())
        }
    }

    static public func delete(address: MessageBoxAddress, _ ID: MessageID) {
        switch address {
            case .distributed(let boxID, let appName): NotificationCenter.default.postDistributed(name: Self.notificationNameForDeleteDistributed(boxID, appName), object: String(ID))
            case .local      (let boxID)             : NotificationCenter.default.post           (name: Self.notificationNameForDeleteLocal      (boxID         ), object: String(ID))
        }
    }

    private var publisherForInsert: NotificationCenter.Publisher {
        switch self.address {
            case .distributed(let boxID, let appName): DistributedNotificationCenter.default.publisher(for: Self.notificationNameForInsertDistributed(boxID, appName))
            case .local      (let boxID)             :            NotificationCenter.default.publisher(for: Self.notificationNameForInsertLocal      (boxID         ))
        }
    }

    private var publisherForDelete: NotificationCenter.Publisher {
        switch self.address {
            case .distributed(let boxID, let appName): DistributedNotificationCenter.default.publisher(for: Self.notificationNameForDeleteDistributed(boxID, appName))
            case .local      (let boxID)             :            NotificationCenter.default.publisher(for: Self.notificationNameForDeleteLocal      (boxID         ))
        }
    }

    @ObservedObject private var messages = ValueState<[MessageInfo]>([])

    public let address: MessageBoxAddress

    private func messageInsert(_ newInfo: MessageInfo, atTop: Bool = false) {
        if (atTop) { self.messages.value.insert(newInfo, at: 0) }
        else       { self.messages.value.append(newInfo) }
    }

    private func messageReplace(_ newInfo: MessageInfo) -> Bool {
        if let index = self.messages.value.firstIndex(where: { info in info.ID == newInfo.ID }) {
            self.messages.value[index] = newInfo
            return true
        }
        return false
    }

    private func messageDelete(_ ID: MessageID) {
        if let index = self.messages.value.firstIndex(where: { info in info.ID == ID }) {
            self.messages.value.remove(at: index)
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(self.messages.value, id: \.viewID) { info in
                Message(
                    address: self.address,
                    info: info
                )
            }
        }
        .onReceive(self.publisherForInsert) { publisher in
            if let messageString = publisher.object as? String {
                if let info = MessageInfo(decode: messageString) {
                    switch (info.mergePolicy) {
                        case .replaceOrInsertAtTop   : if !self.messageReplace(info) { self.messageInsert(info, atTop: true) }
                        case .replaceOrInsertAtBottom: if !self.messageReplace(info) { self.messageInsert(info) }
                        case .deleteAndInsertAtTop   : self.messageDelete(info.ID);    self.messageInsert(info, atTop: true)
                        case .deleteAndInsertAtBottom: self.messageDelete(info.ID);    self.messageInsert(info)
                    }
                }
            }
        }
        .onReceive(self.publisherForDelete) { publisher in
            if let IDString = publisher.object as? String {
                if let ID = MessageID(IDString) {
                    self.messageDelete(ID)
                }
            }
        }
    }

}



/* ############################################################# */
/* ########################## PREVIEW ########################## */
/* ############################################################# */

struct MessageBox_Previews: PreviewProvider {

    static let DEMO_LONG_TITLE       = NSLocalizedString("Lorem ipsum dolor sit amet consectetur adipiscing elit.", comment: "")
    static let DEMO_LONG_DESCRIPTION = NSLocalizedString("Lorem ipsum dolor sit amet consectetur adipiscing elit. Quisque faucibus ex sapien vitae pellentesque sem placerat. In id cursus mi pretium tellus duis convallis.", comment: "")
    static let messageBoxMainAddress: MessageBoxAddress = .local(boxID: MessageBoxID(0))

    static public var previews: some View {
        MessageBox(address: messageBoxMainAddress)
            .frame(width: 250)
            .onAppear {
                MessageBox.insert(address: messageBoxMainAddress, .init(type: .info   , lifetime: .infinity, isClosable: true, mergePolicy: .replaceOrInsertAtBottom, title: Self.DEMO_LONG_TITLE, description: Self.DEMO_LONG_DESCRIPTION))
                MessageBox.insert(address: messageBoxMainAddress, .init(type: .ok     , lifetime: .infinity, isClosable: true, mergePolicy: .replaceOrInsertAtBottom, title: Self.DEMO_LONG_TITLE, description: Self.DEMO_LONG_DESCRIPTION))
                MessageBox.insert(address: messageBoxMainAddress, .init(type: .warning, lifetime: .infinity, isClosable: true, mergePolicy: .replaceOrInsertAtBottom, title: Self.DEMO_LONG_TITLE, description: Self.DEMO_LONG_DESCRIPTION))
                MessageBox.insert(address: messageBoxMainAddress, .init(type: .error  , lifetime: .infinity, isClosable: true, mergePolicy: .replaceOrInsertAtBottom, title: Self.DEMO_LONG_TITLE, description: Self.DEMO_LONG_DESCRIPTION))
            }
    }

}
