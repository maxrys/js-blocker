
/* ############################################################# */
/* ### Copyright © 2026 Maxim Rysevets. All rights reserved. ### */
/* ############################################################# */

import Foundation

extension NotificationCenter {

    func postDistributed(name: NSNotification.Name, object: String?, deliverImmediately: Bool = true) {
        DistributedNotificationCenter
            .default()
            .postNotificationName(
                name, object: object, deliverImmediately: deliverImmediately
            )
    }

}
