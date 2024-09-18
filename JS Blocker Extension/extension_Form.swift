
import SafariServices

extension NSButton {

    func accessSet(_ state: Bool) {
        self.isEnabled = state
        self.resetCursorRects()
    }

    override open func resetCursorRects() {
        // set "hand" cursor
        if self.isEnabled {self.addCursorRect   (self.bounds, cursor: NSCursor.pointingHand)}
        else              {self.removeCursorRect(self.bounds, cursor: NSCursor.pointingHand)}
    }

}
