
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

import os
import AppKit
import CoreData

public class Migrations {

    static func migration_001() {
        if case .failure = Migration_001.selectIsCompleted() {
            if (AllowedDomains.selectCount() == 0 && WhiteDomains.selectCount() > 0) {
                for source in WhiteDomains.selectAll() {
                    let result = AllowedDomains.insert(
                        name     : source.name,
                        type     : source.isGlobal ? MATCH_TYPE_STRING_WILDCARD : MATCH_TYPE_STRING_EXACT,
                        expiresAt: source.expiresAt,
                        createdAt: source.createdAt,
                        isVersioningDisabled: true
                    )
                    if case .success = result { Logger.customLog("migration_001(): success for record (name = \(source.name), type = \(source.isGlobal ? MATCH_TYPE_STRING_WILDCARD : MATCH_TYPE_STRING_EXACT), expiresAt = \(source.expiresAt))") }
                    if case .failure = result { Logger.customLog("migration_001(): failure for record (name = \(source.name), type = \(source.isGlobal ? MATCH_TYPE_STRING_WILDCARD : MATCH_TYPE_STRING_EXACT), expiresAt = \(source.expiresAt))") }
                }
            }
            _ = Migration_001.insertIsCompleted()
        }
    }

}
