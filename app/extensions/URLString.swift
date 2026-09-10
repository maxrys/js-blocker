
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import SwiftUI

typealias URLString = String
extension URLString {

    func decodeURLString() -> Self {
        guard let components = URLComponents(string: self) else { return self }

        var result = ""

        if let scheme = components.scheme {
            result = "\(scheme)://\(result)"
        }

        if let user = components.user {
            var userAndPass = user.percentDecode
            if let pass = components.password {
                userAndPass += ":\(pass.percentDecode)" }
            result = "\(result)\(userAndPass)@"
        }

        if let host = components.host {
            result = "\(result)\(host.decodePunycode())"
        }

        if let port = components.port {
            result += ":\(port)"
        }

        let path = components.path.percentDecode
        result += path.isEmpty ? "/" : path

        if let query = components.query {
            result += "?\(query.percentDecode)"
        }

        if let fragment = components.fragment {
            result += "#\(fragment.percentDecode)"
        }

        return self.hasSuffix("/") ? result :
            result.trimSuffix("/")
    }

}
